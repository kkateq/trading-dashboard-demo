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
    
    func imbalance(_ stats: Stats) -> Double {
        return ((stats.bestBidVolume - stats.bestAskVolume) / (stats.bestBidVolume + stats.bestAskVolume))
    }

    func getPoints(_ statsList: [Stats]!) -> [Point] {
        var res: [Point] = []
        for stats in statsList {
            res.append(Point(x: stats.time, y: imbalance(stats)))
        }

        return res
    }
    
    func updateChart(_ publishedStats: Stats!) -> Void {
//        withAnimation(.easeOut(duration: 0.08)) {
        self.points = getPoints(book.statsHistory)
//        }
    }


    var body: some View {
        VStack {
            Text("Imbalance Best Bid VS Best Ask")
            ScrollView {
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
                    .onReceive(book.$stats) { updateChart($0) }
                    .chartYScale(domain: -1.0 ... 1.0)
                    .padding()
            } .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 1))
        
        }
       
    }
       
}

#Preview {
    ImbalanceChart()
}
