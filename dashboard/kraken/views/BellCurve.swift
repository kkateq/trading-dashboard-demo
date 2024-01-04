//
//  BellCurve.swift
//  dashboard
//
//  Created by km on 29/12/2023.
//

import Charts
import SwiftUI

struct BellCurve: View {
    @EnvironmentObject var book: KrakenOrderBookData

    @State var askData: [KrakenVolumeDistributionElement]!
    @State var bidData: [KrakenVolumeDistributionElement]!

    func updateChart(_ publishedStats: KrakenStats!) {
        askData = publishedStats.ask_groups.map { key, values in
            KrakenVolumeDistributionElement(
                index: key,
                range: publishedStats.ask_bins[key],
                frequency: values.count
            )
        }

        bidData = publishedStats.bid_groups.map { key, values in
            KrakenVolumeDistributionElement(
                index: key,
                range: publishedStats.bid_bins[key],
                frequency: values.count
            )
        }
    }

    var body: some View {
        VStack {
            Text("Bell curve volume distribution")
            HStack {
                Text("ask - \(String(format: "%.0f", round(book.stats.askVolumeCutOff)))").foregroundStyle(.pink)
                Text(" - ")
                Text("bid - \(String(format: "%.0f",round(book.stats.bidVolumeCutOff)))").foregroundStyle(.blue)
            }
            HStack {
                if let askdataset = askData {
                    VStack(alignment: .leading) {
                        Text("Asks")
                        Chart(askdataset, id: \.index) { element in
                            BarMark(
                                x: .value(
                                    "Volume",
                                    element.range
                                ),
                                y: .value(
                                    "Frequency",
                                    element.frequency
                                )
                            ).foregroundStyle(Color("Red"))
                        }
                        .chartXScale(
                            domain: .automatic(includesZero: false)
                        )
                    }
                }
                if let biddataset = bidData {
                    VStack(alignment: .leading) {
                        Text("Bids")
                        Chart(biddataset, id: \.index) { element in
                            BarMark(
                                x: .value(
                                    "Volume",
                                    element.range
                                ),
                                y: .value(
                                    "Frequency",
                                    element.frequency
                                )
                            ).foregroundStyle(Color("Blue"))
                        }
                        .chartXScale(
                            domain: .automatic(includesZero: false)
                        )
                    }
                }
                
            }
        }.onReceive(book.$stats, perform: updateChart)
            .frame(height: 150)
    }
}

#Preview {
    BellCurve()
}
