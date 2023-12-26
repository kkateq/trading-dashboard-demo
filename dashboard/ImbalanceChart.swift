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

    func imbalance(_ stats: Stats) -> Double {
        return ((stats.bestBidVolume - stats.bestAskVolume) / (stats.bestBidVolume + stats.bestAskVolume))
    }

    func getPoints() -> [Point] {
        var res: [Point] = []
        for stats in book.statsHistory {
            res.append(Point(x: stats.time, y: imbalance(stats)))
        }

        return res
    }

    let stops = [
        Gradient.Stop(color: .red, location: -1.0),
        Gradient.Stop(color: .red, location: -0.33),
        Gradient.Stop(color: .blue, location: -0.3301),
        Gradient.Stop(color: .blue, location: 0.33001),
        Gradient.Stop(color: .green, location: 0.33),
        Gradient.Stop(color: .green, location: 1.0)
    ]

    var body: some View {
        VStack {
            ScrollView {
                Chart {
                    ForEach(getPoints()) { point in
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
                }.frame(width: 710, height: 500)
                   
                    .chartYScale(domain: -1.0 ... 1.0)
                    .padding()
            } .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 1))
            .padding()
        }
       
    }
       
}

#Preview {
    ImbalanceChart()
}
