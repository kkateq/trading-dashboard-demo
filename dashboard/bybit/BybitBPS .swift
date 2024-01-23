//
//  BybitBPS .swift
//  dashboard
//
//  Created by km on 22/01/2024.
//

import SwiftUI

struct BybitBPS: View {
    var pair: String
    @State var totalSells: Double = 0.0
    @State var totalBuys: Double = 0.0
    @State var sellSpeed: Double = 0.0
    @State var buySpeed: Double = 0.0
    var bybittrades_ws: BybitLastTrade
    
    init(pair: String) {
        self.pair = pair
        self.bybittrades_ws = BybitLastTrade(self.pair)
    }
    
    func prevMinute() -> Int {
        let now = Date()

        let components = DateComponents(minute: -1)
        let oneMinute = Calendar.current.date(byAdding: components, to: now)
        
        return Int(oneMinute!.timeIntervalSince1970)

    }
    
    func updateAllData(_ d: [BybitRecentTradeRecord], _ type: BybitTradeSide) {
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
            self.sellSpeed =  self.totalSells / Double(records.count)
        } else {
            self.totalBuys = records.reduce(0) { $0 + $1.value }
            self.buySpeed =  self.totalBuys / Double(records.count)
        }
    }
    
    func updateData(_ d: BybitRecentTradeData!) {
        if let data = d {
            self.updateAllData(data.sells, .sell)
            
            self.updateAllData(data.buys, .buy)
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("\(Int(self.sellSpeed))").font(.title).foregroundStyle(.pink)
                    Text("sells/sec").font(.caption)
                }
                HStack {
                    Text("\(Int(self.buySpeed))").font(.title).foregroundStyle(.blue)
                    Text("buys/sec").font(.caption)
                }
            }
            VStack {
                Text("total sells \(Int(self.totalSells))")
                Text("total buys \(Int(self.totalBuys))")
            }
        }.onReceive(self.bybittrades_ws.$recentTrades, perform: updateData)
            .padding()
          

    }
}

#Preview {
    BybitBPS(pair: "")
}
