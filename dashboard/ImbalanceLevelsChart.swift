//
//  ImbalanceChart.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import Charts
import SwiftUI

// https://davidsevangelista.github.io/post/basic_statistics_order_imbalance/
// https://osquant.com/papers/key-insights-limit-order-book/

struct VolumePoint: Identifiable {
    var id = UUID()
    var volume: Double
    var color: String!
    var type: String
}

struct ImbalanceLevelsChart: View {

    @EnvironmentObject var book: OrderBookData
    @State var points: [VolumePoint] = []

    func getBidVolume(_ stats: Stats, _ prevStats: Stats!, _ l: Int) -> Double {
        if let pr = prevStats {
            if stats.bestBid > pr.bestBid {
                return stats.bestBidVolume + book.getBidVolume(levels: l)
            } else if stats.bestBid == pr.bestBid {
                return stats.bestBidVolume - pr.bestBidVolume + book.getBidVolume(levels: l)
            } else if stats.bestBid < pr.bestBid {
                return -1 * pr.bestBidVolume + book.getBidVolume(levels: l)
            }
        }
        return stats.bestBidVolume
    }

    func getAskVolume(_ stats: Stats, _ prevStats: Stats!, _ l: Int) -> Double {
        if let pr = prevStats {
            if stats.bestAsk < pr.bestAsk {
                return stats.bestAskVolume + book.getAskVolume(levels: l)
            } else if stats.bestAsk == pr.bestAsk {
                return stats.bestAskVolume - pr.bestAskVolume + book.getAskVolume(levels: l)
            } else if stats.bestAsk > pr.bestAsk {
                return -1 * pr.bestAskVolume + book.getAskVolume(levels: l)
            }
        }
        return stats.bestAskVolume
    }


    func updateChart(_: Stats!) {
        if book.statsHistory.count > 2 {
            let prevStats = book.statsHistory[book.statsHistory.count - 2]
            if let st = book.stats {
                
                points = []
                let diff5 = getBidVolume(st, prevStats, 5) - getAskVolume(st, prevStats, 5)
                let diff10 = getBidVolume(st, prevStats, 10) - getAskVolume(st, prevStats, 10)
                let diff25 = getBidVolume(st, prevStats, 25) - getAskVolume(st, prevStats, 25)
                
                points.append(VolumePoint(volume: abs(diff5), color: diff5 > 0 ? "Green": "Red", type: "Level5"))
                
                points.append(VolumePoint(volume: abs(diff10), color: diff10 > 0 ? "Green": "Red", type: "Level10"))
                
                points.append(VolumePoint(volume: abs(diff25), color: diff25 > 0 ? "Green": "Red", type: "Level25"))
            }
        }
    }

    let markColors: [Color] = [.pink, .blue]
    var body: some View {
        VStack {
            Text("Imbalance levels")
            ScrollView {
                Chart {
                    ForEach(points) { point in
                        BarMark(
                            x: .value("Type", point.type),
                            y: .value("Imbalance", point.volume)
                            //                            stacking: .normalized

                        ).foregroundStyle(by: .value("Shape Color", point.color))
                    }
                }
                .onReceive(book.$stats, perform: updateChart)
                .chartYAxis(.hidden)
                .chartForegroundStyleScale([
                    "Green": Color("BidChartColor"), "Red": Color("AskChartColor"),
                ])
                .frame(width: 710, height: 200)
                .padding()
            }
        }
    }
}

#Preview {
    ImbalanceLevelsChart()
}
