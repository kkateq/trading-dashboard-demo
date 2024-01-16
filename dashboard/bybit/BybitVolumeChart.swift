//
//  BybitVolumeChart.swift
//  dashboard
//
//  Created by km on 16/01/2024.
//

import Charts
import SwiftUI

struct BybitChartValue: Identifiable {
    var color: String
    var side: BybitTradeSide
    var price: String
    var time: Date
    var volume: Double
    var id = UUID()
    init(price: String, volume: Double, side: BybitTradeSide, ts: Int) {
        self.price = price
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

    func updateChart(_ lastTradesBatch: [String: (Double, BybitTradeSide, Int)]) {
        for (price, value) in lastTradesBatch {
            data.append(BybitChartValue(price: price, volume: value.0, side: value.1, ts: value.2))
        }
        data.sort(by: { $0.time < $1.time })
    }
    
    func getFrameWidth(volume: Double) -> CGFloat {
        if volume < 100 {
            return 20
        }
        if volume >= 100 && volume < 200 {
            return 30
        }
        if volume >= 200 {
            return 40
        }
        
        return 10
    }

    var body: some View {
        let largeVolume = 50.0
        Chart {
            ForEach(data) { record in
                LineMark(
                    x: .value("Time", record.time),
                    y: .value("Price", record.price)
                )
                .interpolationMethod(.stepStart)
            }

            ForEach(data) { record in
                if record.volume > largeVolume {
                    PointMark(
                        x: .value("Time", record.time),
                        y: .value("Price", record.price)
                    )
                    .symbol {
                        Circle()
                            .fill(record.side == .buy ? .green : .red)
                            .frame(width: getFrameWidth(volume: record.volume))
                            .shadow(radius: 2)
                    }
                }
            }

//            RuleMark(y: .value("Ask", formatPrice(price: book.stats.bestAsk, pair: book.pair)))
//                .foregroundStyle(.red)
//            RuleMark(y: .value("Bid", formatPrice(price: book.stats.bestBid, pair: book.pair)))
//                .foregroundStyle(.green)
        }

//        .chartForegroundStyleScale([
//            "Green": Color("BidChartColor"), "Red": Color("AskChartColor"),
//        ])
//
//        .chartYAxis {
//            AxisMarks(preset: .extended, position: .leading) { _ in
//                AxisValueLabel(horizontalSpacing: 15)
//                    .font(.footnote)
//            }
//        }
        .onReceive(recentTrades.$lastTradesBatch, perform: updateChart)
        .frame(width: 1000, height: 750)
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    BybitVolumeChart()
}
