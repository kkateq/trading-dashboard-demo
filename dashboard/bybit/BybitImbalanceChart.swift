//
//  ImbalanceChart.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import Charts
import SwiftUI

struct BybitImbalanceChart: View {
    @EnvironmentObject var book: BybitOrderBook
    @State private var points: [Point] = []
    @State private var points5: [Point] = []
    @State private var points10: [Point] = []

    func imbalance(_ stats: BybitStats) -> Double {
        return ((stats.bestBidVolume - stats.bestAskVolume) / (stats.bestBidVolume + stats.bestAskVolume))
    }

    func imbalance5(_ stats: BybitStats) -> Double {
        return ((stats.totalBidVol5 - stats.totalAskVol5) / (stats.totalBidVol5 + stats.totalAskVol5))
    }

    func imbalance10(_ stats: BybitStats) -> Double {
        return ((stats.totalBidVol10 - stats.totalAskVol10) / (stats.totalBidVol10 + stats.totalAskVol10))
    }

    func updateChart(_ publishedStats: BybitStats!) {
//        if points.count > 500 {
//            points = points.dropFirst(200)
//        }
//        if points.count > 500 {
//            points = points.dropFirst(200)
//        }
//        if points.count > 500 {
//            points = points.dropFirst(200)
//        }
        points.append(Point(x: publishedStats.time, y: imbalance(publishedStats)))
        points5.append(Point(x: publishedStats.time, y: imbalance5(publishedStats)))
        points10.append(Point(x: publishedStats.time, y: imbalance10(publishedStats)))
    }

    var body: some View {
        VStack {
            VStack {
                Text("Imbalance Best Bid VS Best Ask")

                Chart {
                    ForEach(points) { point in
                        LineMark(
                            x: .value("Time", point.x),
                            y: .value("Imbalance", point.y)
                        )
                        .foregroundStyle(.linearGradient(
                            colors: [.red, .blue, .green],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        )
                    }
                    RuleMark(
                        y: .value("Threshold", -0.33)
                    )
                    .foregroundStyle(.green)
                    RuleMark(
                        y: .value("Threshold", 0.33)
                    )
                    .foregroundStyle(.purple)
                }.frame(width: 710, height: 200)

                    .chartYScale(domain: -1.0 ... 1.0)
                    .padding()
            }
            VStack {
                Text("Imbalance top 5 volume")

                Chart {
                    ForEach(points5) { point in
                        LineMark(
                            x: .value("Time", point.x),
                            y: .value("Imbalance", point.y)
                        )
                        .foregroundStyle(.linearGradient(
                            colors: [.red, .blue, .green],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        )
                    }
                    RuleMark(
                        y: .value("Threshold", -0.33)
                    )
                    .foregroundStyle(.green)
                    RuleMark(
                        y: .value("Threshold", 0.33)
                    )
                    .foregroundStyle(.purple)
                }.frame(width: 710, height: 200)

                    .chartYScale(domain: -1.0 ... 1.0)
                    .padding()
            }
            VStack {
                Text("Imbalance top 10 volume")

                Chart {
                    ForEach(points10) { point in
                        LineMark(
                            x: .value("Time", point.x),
                            y: .value("Imbalance", point.y)
                        )
                        .foregroundStyle(.linearGradient(
                            colors: [.red, .blue, .green],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        )
                    }
                    RuleMark(
                        y: .value("Threshold", -0.33)
                    )
                    .foregroundStyle(.green)
                    RuleMark(
                        y: .value("Threshold", 0.33)
                    )
                    .foregroundStyle(.purple)
                }.frame(width: 710, height: 200)

                    .chartYScale(domain: -1.0 ... 1.0)
                    .padding()
            }
        }.onReceive(book.$stats) { updateChart($0) }
    }
}

#Preview {
    BybitImbalanceChart()
}
