//
//  VolumeChart.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import Charts
import SwiftUI

struct VolumeChart: View {
    @EnvironmentObject var book: OrderBookData

    var body: some View {
        let total = [
            (name: "ASK", volume: book.stats.totalAskVol),
            (name: "BID", volume: book.stats.totalBidVol),
        ]
        let total5 = [
            (name: "ASK", volume: book.stats.totalAskVol5),
            (name: "BID", volume: book.stats.totalBidVol5),
        ]
        let total10 = [
            (name: "ASK", volume: book.stats.totalAskVol10),
            (name: "BID", volume: book.stats.totalBidVol10),
        ]

        HStack {
            VStack {
                Text("Top 25")
                Chart {
                    ForEach(total, id: \.name) {
                        SectorMark(
                            angle: .value("Volume", $0.volume)
                        )
                        .foregroundStyle(by: .value("Type", $0.name))
                    }
                }
            }
            VStack {
                Text("Top 10")
                Chart {
                    ForEach(total10, id: \.name) {
                        SectorMark(
                            angle: .value("Volume", $0.volume)
                        )
                        .foregroundStyle(by: .value("Type", $0.name))
                    }
                } .foregroundStyle(.linearGradient(
                    colors: [.red, .green],
                    startPoint: .bottom,
                    endPoint: .top
                ))
            }
            VStack {
                Text("Top 5")
                Chart {
                    ForEach(total5, id: \.name) {
                        SectorMark(
                            angle: .value("Volume", $0.volume)
                        )
                        .foregroundStyle(by: .value("Type", $0.name))
                    }
                }
            }
        }
    }
}

#Preview {
    VolumeChart()
}
