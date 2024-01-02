//
//  ImbalanceChart.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import Charts
import SwiftUI

struct Point: Identifiable {
    var id = UUID()
    var x: Date
    var y: Double
}

struct ImbalanceChart: View {
    @EnvironmentObject var book: OrderBookData
    @State private var points: [Point] = []
    @State private var points5: [Point] = []
    @State private var points10: [Point] = []

    func imbalance(_ stats: Stats) -> Double {
        return ((stats.bestBidVolume - stats.bestAskVolume) / (stats.bestBidVolume + stats.bestAskVolume))
    }

    func imbalance5(_ stats: Stats) -> Double {
        return ((stats.totalBidVol5 - stats.totalAskVol5) / (stats.totalBidVol5 + stats.totalAskVol5))
    }

    func imbalance10(_ stats: Stats) -> Double {
        return ((stats.totalBidVol10 - stats.totalAskVol10) / (stats.totalBidVol10 + stats.totalAskVol10))
    }

    func getPoints(_ statsList: [Stats]!) -> [Point] {
        var res: [Point] = []
        for stats in statsList {
            res.append(Point(x: stats.time, y: imbalance(stats)))
        }

        return res
    }

    func getPoints5(_ statsList: [Stats]!) -> [Point] {
        var res: [Point] = []
        for stats in statsList {
            res.append(Point(x: stats.time, y: imbalance5(stats)))
        }

        return res
    }

    func getPoints10(_ statsList: [Stats]!) -> [Point] {
        var res: [Point] = []
        for stats in statsList {
            res.append(Point(x: stats.time, y: imbalance10(stats)))
        }

        return res
    }

    func updateChart(_ publishedStats: Stats!) {
//        withAnimation(.easeOut(duration: 0.08)) {
        points = getPoints(book.statsHistory)
        points5 = getPoints5(book.statsHistory)
        points10 = getPoints10(book.statsHistory)

//        }
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
    ImbalanceChart()
}
