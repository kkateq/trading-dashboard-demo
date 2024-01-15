//
//  BuySellTransactionsChart.swift
//  dashboard
//
//  Created by km on 12/01/2024.
//

import Charts
import SwiftUI

struct BybitLineValue: Identifiable {
    var volume: Double
    var time: Date
    var id = UUID()
    init(volume: Double, time: Date) {
        self.volume = volume
        self.time = time
    }
}

struct BuySellTransactionsChart: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData

    @State var sells: [BybitLineValue] = []
    @State var buys: [BybitLineValue] = []
    @State var sellCum: Double = 0
    @State var buyCum: Double = 0

    func updateChart(_ lastTrade: BybitRecentTradeRecord!) {
        if let e = lastTrade {
            if e.side == .buy {
                buyCum += e.volume

                if e.volume > 10 {
                    buys.append(BybitLineValue(volume: buyCum, time: getDate(timestamp: e.time)))
                }

            } else {
                sellCum += e.volume
                if e.volume > 10 {
                    sells.append(BybitLineValue(volume: sellCum, time: getDate(timestamp: e.time)))
                }
            }
        }

        if buys.count > 10000 {
            buys = buys.suffix(1300)
        }
        if sells.count > 10000 {
            sells = sells.suffix(1300)
        }
    }

    func updateCumValues(_ trades: [BybitRecentTradeRecord]) {
        for tr in trades {
            if tr.side == .buy {
                buyCum += tr.volume
            } else {
                sellCum += tr.volume
            }
        }
    }

    var cumSellPerc: Int {
        let total = sellCum + buyCum
        if total > 0 {
            return Int((sellCum / total) * 100)
        } else {
            return 0
        }
    }

    var cumBuyPerc: Int {
        let total = sellCum + buyCum
        if total > 0 {
            return Int((buyCum / total) * 100)
        } else {
            return 0
        }
    }

    var body: some View {
        VStack {
            Text("Sell&Bid Executed Cumulative")
            HStack {
                Spacer()
                Text("\(cumSellPerc)% (\(Int(sellCum)))")
                    .foregroundStyle(.red)
                Text("  ")
                Text("\(cumBuyPerc)% (\(Int(buyCum)))")
                    .foregroundStyle(.blue)
                Spacer()
            }
            Chart {
                ForEach(sells) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("Volume", point.volume),
                        series: .value("Side", "SELL")
                    ).foregroundStyle(Color("Red"))
                        .lineStyle(.init(lineWidth: 3))
                     
                }

                ForEach(buys) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("Volume", point.volume),
                        series: .value("Side", "BUYS")
                    ).foregroundStyle(Color("Green"))
                        .lineStyle(.init(lineWidth: 3))
                       
                }

            }.frame(width: 710, height: 200)
        }
        .onReceive(recentTrades.$lastTrade, perform: updateChart)
        .onReceive(recentTrades.$list, perform: updateCumValues)
    }
}

#Preview {
    BuySellTransactionsChart()
}
