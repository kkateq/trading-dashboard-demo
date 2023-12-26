//
//  ImbalanceChart.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import Charts
import SwiftUI

struct ImbalancePoint: Identifiable {
    var id = UUID()
    var time: Date
    var imbalance: Double
}

struct ImbalanceChart2: View {
    @EnvironmentObject var book: OrderBookData

    func getBidVolume(_ stats: Stats, _ prevStats: Stats!) -> Double {
        if let pr = prevStats {
            if stats.bestBid > pr.bestBid {
                return stats.bestBidVolume
            } else if stats.bestBid == pr.bestBid {
                return stats.bestBidVolume - pr.bestBidVolume
            } else if stats.bestBid < pr.bestBid {
                return -1 * pr.bestBidVolume
            }
        }
        return stats.bestBidVolume
    }

    func getAskVolume(_ stats: Stats, _ prevStats: Stats!) -> Double {
        if let pr = prevStats {
            if stats.bestAsk < pr.bestAsk {
                return stats.bestAskVolume
            } else if stats.bestAsk == pr.bestAsk {
                return stats.bestAskVolume - pr.bestAskVolume
            } else if stats.bestAsk > pr.bestAsk {
                return -1 * pr.bestAskVolume
            }
        }
        return stats.bestAskVolume
    }

    func getPoints() -> [ImbalancePoint] {
        var res: [ImbalancePoint] = []
        if book.statsHistory.count > 2 {
            var prevStats: Stats! = nil
            for stats in book.statsHistory {
                
                if prevStats != nil {
                    let askV = getAskVolume(stats, prevStats)
                    let bidV = getBidVolume(stats, prevStats)
                    
                    res.append(ImbalancePoint(time: stats.time, imbalance: bidV - askV))
                }
                prevStats = stats
            }
        }

        return res
    }

    var body: some View {
        VStack {
            ScrollView {
                Chart(getPoints()) {
                    AreaMark(
                        x: .value("Time", $0.time),
                        y: .value("Imbalance", $0.imbalance)
                    )
                    .foregroundStyle(.linearGradient(
                        colors: [.red, .blue, .green],
                        startPoint: .bottom,
                        endPoint: .top
                    ))}
                
                .frame(width: 710, height: 500)
                .padding()
            }
        }
    }
}

#Preview {
    ImbalanceChart()
}
