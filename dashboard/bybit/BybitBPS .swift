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
            self.sellSpeed =  self.totalSells / Double(records.count)
        } else {
            self.totalBuys = records.reduce(0) { $0 + $1.value }
            self.buySpeed =  self.totalBuys / Double(records.count)
        }
    }
    
    func updateSellData(_ d: [BybitRecentTradeRecord]) {
        self.updateData(d, .sell)
    }
    
    
    func updateBuyData(_ d: [BybitRecentTradeRecord]) {
        self.updateData(d, .buy)
    }
    
    var body: some View {
        HStack {
            VStack {
                Text("\(Int(self.sellSpeed)) sells/sec")
                Text("\(Int(self.buySpeed)) buys/sec")
            }
            VStack {
                Text("total sells \(Int(self.totalSells))")
                Text("total buys \(Int(self.totalBuys))")
            }
        }.onReceive(recentTrades.$sells, perform: updateSellData)
            .onReceive(recentTrades.$buys, perform: updateBuyData)

    }
}

#Preview {
    BybitBPS(pair: "")
}
