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

    @EnvironmentObject var book: KrakenOrderBookData
    @State var points: [VolumePoint] = []

    func getBidVolume(_ stats: KrakenStats, _ prevStats: KrakenStats!, _ totalBidLevelsVolume: Double) -> Double {
        if let pr = prevStats {
            if stats.bestBid > pr.bestBid {
                return stats.bestBidVolume + totalBidLevelsVolume
            } else if stats.bestBid == pr.bestBid {
                return stats.bestBidVolume - pr.bestBidVolume + totalBidLevelsVolume
            } else if stats.bestBid < pr.bestBid {
                return -1 * pr.bestBidVolume + totalBidLevelsVolume
            }
        }
        return stats.bestBidVolume
    }

    func getAskVolume(_ stats: KrakenStats, _ prevStats: KrakenStats!, _ totalAskLevelsVolume: Double) -> Double {
        if let pr = prevStats {
            if stats.bestAsk < pr.bestAsk {
                return stats.bestAskVolume + totalAskLevelsVolume
            } else if stats.bestAsk == pr.bestAsk {
                return stats.bestAskVolume - pr.bestAskVolume + totalAskLevelsVolume
            } else if stats.bestAsk > pr.bestAsk {
                return -1 * pr.bestAskVolume + totalAskLevelsVolume
            }
        }
        return stats.bestAskVolume
    }


    func updateChart(_: KrakenStats!) {
        if book.statsHistory.count > 2 {
            let prevStats = book.statsHistory[book.statsHistory.count - 2]
            if let st = book.stats {
                
                points = []
                let diff5 = getBidVolume(st, prevStats, st.totalBidVol5) - getAskVolume(st, prevStats, st.totalAskVol5)
                let diff10 = getBidVolume(st, prevStats, st.totalBidVol10) - getAskVolume(st, prevStats, st.totalAskVol10)
                let diff25 = getBidVolume(st, prevStats, st.totalBidVol) - getAskVolume(st, prevStats, st.totalAskVol)
                
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
