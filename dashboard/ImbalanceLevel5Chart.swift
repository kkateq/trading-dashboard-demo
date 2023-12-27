//
//  ImbalanceChart.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import Charts
import SwiftUI


//https://davidsevangelista.github.io/post/basic_statistics_order_imbalance/
//https://osquant.com/papers/key-insights-limit-order-book/

struct ImbalanceLevel5Chart: View {
    @EnvironmentObject var book: OrderBookData
    
    func getBidVolume(_ stats: Stats, _ prevStats: Stats!) -> Double {
        if let pr = prevStats {
            if stats.bestBid > pr.bestBid {
                return stats.bestBidVolume + stats.totalBidVol1_5
            } else if stats.bestBid == pr.bestBid {
                return stats.bestBidVolume - pr.bestBidVolume + stats.totalBidVol1_5
            } else if stats.bestBid < pr.bestBid {
                return -1 * (pr.bestBidVolume + pr.totalBidVol1_5)
            }
        }
        return stats.bestBidVolume
    }

    func getAskVolume(_ stats: Stats, _ prevStats: Stats!) -> Double {
        if let pr = prevStats {
            if stats.bestAsk < pr.bestAsk {
                return stats.bestAskVolume + stats.totalAskVol1_5
            } else if stats.bestAsk == pr.bestAsk {
                return stats.bestAskVolume - pr.bestAskVolume  + stats.totalAskVol1_5
            } else if stats.bestAsk > pr.bestAsk {
                return -1 * (pr.bestAskVolume + pr.totalAskVol1_5)
            }
        }
        return stats.bestAskVolume
    }

    func getPoints() -> [ImbalancePoint] {
        var res: [ImbalancePoint] = []
        if book.statsHistory.count > 2 {
            var sum: Double = 0
            var prevStats: Stats! = nil
            for stats in book.statsHistory {
             
                if prevStats != nil {
                    let askV = getAskVolume(stats, prevStats)
                    let bidV = getBidVolume(stats, prevStats)
                    sum += bidV - askV
                    res.append(ImbalancePoint(time: stats.time, imbalance: sum))
                }
                prevStats = stats
            }
        }

        return res
    }
    let markColors: [Color] = [.pink, .blue]
    var body: some View {
        
        VStack {
            Text("Imbalance 5 levels")
            ScrollView {
                Chart(getPoints()) {
                    PointMark(
                        x: .value("Time", $0.time),
                        y: .value("Imbalance", $0.imbalance)
                        
                        
                    ).foregroundStyle($0.imbalance > 0 ? .green : .red)
                                      
                }
                .frame(width: 710, height: 200)
                .padding()
            }
        }
    }
}

#Preview {
    ImbalanceLevel5Chart()
}
