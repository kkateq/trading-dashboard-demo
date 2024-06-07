//
//  BybitBPS .swift
//  dashboard
//
//  Created by km on 22/01/2024.
//

import SwiftUI

struct BybitBPS: View {
    var pair: String
    var sendAlert: Bool = false
    @State var totalSells: Double = 0.0
    @State var totalBuys: Double = 0.0
    @State var sellSpeed: Double = 0.0
    @State var buySpeed: Double = 0.0
    @EnvironmentObject var recentTrades: BybitRecentTradeData

    func prevMinute() -> Int {
        let now = Date()

        let components = DateComponents(minute: -1)
        let oneMinute = Calendar.current.date(byAdding: components, to: now)

        return Int(oneMinute!.timeIntervalSince1970)
    }

    func updateData(_ d: [BybitRecentTradeRecord], _ type: BybitTradeSide) {
        let data = d
        var records: [String: Double] = [:]
        let prevMinute = prevMinute()
        for v in data {
            if v.time > prevMinute {
                let key = "\(formatTimestamp(v.time, "hh:mm:ss"))"
                if let exb = records[key] {
                    records[key] = exb + v.volume
                } else {
                    records[key] = v.volume
                }
            }
        }

        if type == .sell {
            self.totalSells = records.reduce(0) { $0 + $1.value }
            self.sellSpeed = self.totalSells / Double(records.count)
        } else {
            self.totalBuys = records.reduce(0) { $0 + $1.value }
            self.buySpeed = self.totalBuys / Double(records.count)
        }
        
    
    }

    func updateBuysData(_ data: [BybitRecentTradeRecord]) {
        self.updateData(data, .buy)
    }

    func updateSellsData(_ data: [BybitRecentTradeRecord]) {
        self.updateData(data, .sell)
    }
    
    func getSellFr() -> Int {
        if sellSpeed > 0 && totalSells > 0 {
            return Int(self.totalSells/self.sellSpeed)
        } else {
            return 0
        }
    }
    
    func getBuyFr() -> Int {
        if buySpeed > 0 && totalBuys > 0 {
            return Int(self.totalBuys/self.buySpeed)
        } else {
            return 0
        }
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Speed").font(.caption).foregroundStyle(.gray)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("sells/sec").font(.caption)
                            Text("\(Int(self.sellSpeed))").font(.title).foregroundStyle(.pink)
                        }
                        VStack(alignment: .leading) {
                            Text("buys/sec").font(.caption)
                            Text("\(Int(self.buySpeed))").font(.title).foregroundStyle(.blue)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Total").font(.caption).foregroundStyle(.gray)
                    HStack {
                        VStack(alignment: .leading){
                            Text("Sells").font(.caption)
                            Text("\(Int(self.totalSells))").font(.title).foregroundStyle(.black)
                        }
                        VStack(alignment: .leading) {
                            Text("Buys").font(.caption)
                            Text("\(Int(self.totalBuys))").font(.title).foregroundStyle(.black)
                        }
                    }
                }
            }
            VStack(alignment: .leading) {
                Text("Experimental").font(.caption).foregroundStyle(.gray)
                HStack {
                    VStack(alignment: .leading){
                        Text("Sells prop").font(.caption)
                        Text("\(getSellFr())").font(.title).foregroundStyle(.black)
                    }
                    VStack(alignment: .leading) {
                        Text("Buys prop").font(.caption)
                        Text("\(getBuyFr())").font(.title).foregroundStyle(.black)
                    }
                }
            }
        }.onReceive(self.recentTrades.$sells, perform: updateSellsData)
            .onReceive(self.recentTrades.$buys, perform: updateBuysData)
          
    }
}

#Preview {
    BybitBPS(pair: "")
}
