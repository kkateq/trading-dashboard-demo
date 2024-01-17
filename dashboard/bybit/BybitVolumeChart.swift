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

struct Mark: Identifiable {
    var price: String
    var id = UUID()
    
    init(price: String, id: UUID = UUID()) {
        self.price = price
        self.id = id
    }
}

struct BybitVolumeChart: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    @EnvironmentObject var book: BybitOrderBook
    @State var data: [BybitChartValue] = []
    @State var priceMark: String = "0"
    @State var marks: [Mark] = []

    func updateChart(_ list: [BybitRecentTradeRecord]) {
        var p:[BybitChartValue] = []
        for record in list {
            p.append(BybitChartValue(price: record.priceStr, volume: record.volume, side: record.side, ts: record.time))
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
        VStack {
            VStack {
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
                    ForEach(marks) { mark in
                        RuleMark(y: .value("Price", formatPrice(price: mark.price, pair: book.pair)))
                            .foregroundStyle(.black)
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
                .onReceive(recentTrades.$list, perform: updateChart)
                .frame(width: 1000, height: 750)
                .fixedSize(horizontal: true, vertical: false)
            }
           
        }.overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray, lineWidth: 2)
        )
        VStack {
            HStack {
                Text("Mark:")
                TextField("Mark", text: $priceMark)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            Button(action: {
                Task {
                    self.marks.append(Mark(price: priceMark))
                }
            }) {
                HStack {
                    Text("Add Mark")
                }
            }
        }
    }
}

#Preview {
    BybitVolumeChart()
}
