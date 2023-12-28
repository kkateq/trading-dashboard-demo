//
//  VolumeChart2.swift
//  dashboard
//
//  Created by km on 28/12/2023.
//

import Charts
import SwiftUI

struct BarValue: Identifiable {
    var color: String
    var type: String
    var count: Double
    var id = UUID()
}

struct VolumeChart2: View {
    @EnvironmentObject var book: OrderBookData
    @State var data: [BarValue] = []

    func updateChart(_ s: Stats!) {
//        let totalAskPerc = round(100 * book.stats.totalAskVol/(book.stats.totalAskVol + book.stats.totalBidVol))
//
//        let total5AskPerc = round(100 * book.stats.totalAskVol5/(book.stats.totalAskVol5 + book.stats.totalBidVol5))
//
//        let total10AskPerc = round(100 * book.stats.totalAskVol10/(book.stats.totalAskVol10 + book.stats.totalBidVol10))
//
//        data = [
//            .init(color: "Green", type: "Total", count: 100 - totalAskPerc),
//            .init(color: "Red", type: "Total", count: totalAskPerc),
//            .init(color: "Green", type: "5 levels", count: 100 - total5AskPerc),
//            .init(color: "Red", type: "5 levels", count: total5AskPerc),
//            .init(color: "Green", type: "10 levels", count: 100 - total10AskPerc),
//            .init(color: "Red", type: "10 levels", count: total10AskPerc),
//        ]
    }

    var body: some View {
        Chart {
            ForEach(data) { shape in
                BarMark(
                    x: .value("Type", shape.type),
                    y: .value("Total Count", shape.count)
                )
                .foregroundStyle(by: .value("Shape Color", shape.color))
            }
        }
        .chartForegroundStyleScale([
            "Green": Color("Green"), "Red": Color("Red"),
        ])
        .onReceive(book.$stats, perform: updateChart)
        .frame(height: 100)
    }
}

#Preview {
    VolumeChart2()
}
