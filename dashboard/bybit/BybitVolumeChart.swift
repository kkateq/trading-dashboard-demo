//
//  BybitVolumeChart.swift
//  dashboard
//
//  Created by km on 16/01/2024.
//

import Charts
import SwiftUI
import Accelerate

struct BybitChartValue: Identifiable {
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

struct BybitVolumeChart: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    @EnvironmentObject var book: BybitOrderBook
    @State var data: [BybitChartValue] = []
    @State var speedAvgBuy: Double = 0
    @State var speedAvgSell: Double = 0

    func updateChart(_ list: [BybitRecentTradeRecord]) {
        var p: [BybitChartValue] = []
        var sells: [String: (Double, Int)] = [:]
        var buys: [String: (Double, Int)] = [:]
        var prevBuyTime = 0
        var prevSellTime = 0
        let last100 = list.suffix(500)
        for record in last100 {
            if record.side == .buy {
                if let exb = buys[record.priceStr] {
                    if exb.1 - prevBuyTime < 500 {
                        buys[record.priceStr] = (exb.0 + record.volume, record.time)
                    } else {
                        buys[record.priceStr] = (record.volume, record.time)
                    }
                } else {
                    buys[record.priceStr] = (record.volume, record.time)
                }
                prevBuyTime = record.time
            } else {
                if let exs = sells[record.priceStr] {
                    if exs.1 - prevSellTime < 500 {
                        sells[record.priceStr] = (exs.0 + record.volume, record.time)
                    } else {
                        sells[record.priceStr] = (record.volume, record.time)
                    }
                } else {
                    sells[record.priceStr] = (record.volume, record.time)
                }
                prevSellTime = record.time
            }
        }

        speedAvgSell = vDSP.mean(sells.map { $0.value.0 })
        speedAvgBuy = vDSP.mean(buys.map { $0.value.0 })

        for value in buys {
            p.append(BybitChartValue(pair: book.pair, price: value.key, volume: value.value.0, side: .buy, ts: value.value.1))
        }
        for value in sells {
            p.append(BybitChartValue(pair: book.pair, price: value.key, volume: value.value.0, side: .sell, ts: value.value.1))
        }

        p.sort(by: { $0.time < $1.time })

        data = p
    }

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    func getFrameWidth(volume: Double) -> CGFloat {
        if volume <= 10 {
            return 2
        }
        if volume > 10 && volume < 50 {
            return 5
        }

        if volume > 50 && volume < 100 {
            return 10
        }
        if volume > 100 && volume < 150 {
            return 15
        }

        return CGFloat(Int(volume / 10))
    }

    var body: some View {
        VStack {
            VStack {
                Chart {
                    PointMark(
                        x: .value("Time", Date()),
                        y: .value("Price", book.stats.bestAsk)
                    )
                    .symbol {
                        Circle()
                            .fill(Color("AskChartColor"))
                            .frame(width: getFrameWidth(volume: book.stats.bestAskVolume))
                    }

                    PointMark(
                        x: .value("Time", Date()),
                        y: .value("Price", book.stats.bestBid)
                    )
                    .symbol {
                        Circle()
                            .fill(Color("BidChartColor"))
                            .frame(width: getFrameWidth(volume: book.stats.bestBidVolume))
                    }

                    ForEach(data) { record in
                        LineMark(
                            x: .value("Time", record.time),
                            y: .value("Price", record.price)
                        )
                        .interpolationMethod(.stepStart)
                    }

                    ForEach(data) { record in
                        PointMark(
                            x: .value("Time", record.time),
                            y: .value("Price", record.price)
                        )
                        .symbol {
                            Circle()
                                .fill(record.side == .buy ? Color("GreenLight") : Color("RedLight"))
                                .frame(width: getFrameWidth(volume: record.volume))
                        }
                    }

                    ForEach(PriceLevelManager.manager.levels(pair: book.pair)) { mark in
                        RuleMark(y: .value("Price", Double(mark.price)!))
                            .foregroundStyle(mark.color.0)
                            .lineStyle(.init(lineWidth: mark.color.1))
                            .annotation(position: .top,
                                        alignment: .topTrailing) {
                                Text(mark.price)
                            }
                    }

                    RuleMark(y: .value("Price", roundPrice(price: book.stats.bestAsk, pair: book.pair)))
                        .foregroundStyle(.red)

                        .annotation(position: .top,
                                    alignment: .topLeading) {
                            Text("\(book.stats.bestAsk)")
                        }
                    RuleMark(y: .value("Price", roundPrice(price: book.stats.bestBid, pair: book.pair)))
                        .foregroundStyle(.green)

                        .annotation(position: .bottom,
                                    alignment: .bottomLeading) {
                            Text("\(book.stats.bestBid)")
                        }
                }

                //        .chartForegroundStyleScale([
                //            "Green": Color("BidChartColor"), "Red": Color("AskChartColor"),
                //        ])
                //
                .padding()
                .onReceive(recentTrades.$list, perform: updateChart)
                .frame(width: 1200, height: 350)
//                .fixedSize(horizontal: false, vertical: true)
//                .chartScrollableAxes(.horizontal)
                .aspectRatio(1, contentMode: .fit)
                .chartYScale(
                    domain: .automatic(includesZero: false)
                )
            }

        }.overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray, lineWidth: 2)
        )
        HStack {
//            VStack {
//                VStack {
//                    Text("BUYs / 500 ms").font(.caption)
//                    Text("\(Int(speedAvgBuy))").font(.title).foregroundStyle(.green)
//                }
//                VStack {
//                    Text("SELLs / 500 ms").font(.caption)
//                    Text("\(Int(speedAvgSell))").font(.title).foregroundStyle(.red)
//                }
//            }
//            Spacer()
          
        }
    }
}

#Preview {
    BybitVolumeChart()
}
