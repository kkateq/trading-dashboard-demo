//
//  BidAskSellsBuysChart.swift
//  dashboard
//
//  Created by km on 17/01/2024.
//

import Charts
import SwiftUI

struct TradeChartValue: Identifiable {
    var color: String
    var side: BybitTradeSide
    var price: Double
    var time: Date
    var volume: Double
    var id = UUID()
    init(pair: String, price: String, volume: Double, side: BybitTradeSide, ts: Int) {
        self.price = roundPrice(price: Double(price)!, pair: pair)
        self.volume = volume
        self.side = side
        self.color = side == .buy ? "Green" : "Red"
        self.time = getDate(timestamp: ts)
    }
}

struct BidAskSellsBuysChart: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    @EnvironmentObject var book: BybitOrderBook
    @State var data: [TradeChartValue] = []

    func updateChart(_ list: [BybitRecentTradeRecord]) {
        var p: [TradeChartValue] = []
        for record in list {
            p.append(TradeChartValue(pair: book.pair, price: record.priceStr, volume: record.volume, side: record.side, ts: record.time))
        }
        p.sort(by: { $0.time < $1.time })
        data = p
    }

    func getFrameWidth(volume: Double) -> CGFloat {
        if volume < 1 {
            return 2
        }
        if volume > 100 {
            return 20
        }

        return CGFloat(Int(volume))
    }

    var body: some View {
        VStack {
            Chart {
                ForEach(data) { record in

                    PointMark(
                        x: .value("Time", record.time),
                        y: .value("Price", record.price)
                    )
                    .symbol {
                        Circle()
                            .fill(record.side == .buy ? .green : .red)
                            .frame(width: getFrameWidth(volume: record.volume))
                    }
                }
                RuleMark(y: .value("Price", book.stats.bestAsk))
                    .foregroundStyle(.red)
               
                    .annotation(position: .top,
                                alignment: .topTrailing) {
                        Text("\(book.stats.bestAsk)")
                    }
                RuleMark(y: .value("Price", book.stats.bestBid))
                    .foregroundStyle(.green)
               
                    .annotation(position: .top,
                                alignment: .topTrailing) {
                        Text("\(book.stats.bestBid)")
                    }
            }
        }.onReceive(recentTrades.$list, perform: updateChart)
            .frame(width: 1200, height: 550)
            .fixedSize(horizontal: false, vertical: false)
//            .chartScrollableAxes(.horizontal)
            .chartYScale(
                domain: .automatic(includesZero: false)
            )
    }
}

#Preview {
    BidAskSellsBuysChart()
}
