//
//  KrakenVolumeCard.swift
//  dashboard
//
//  Created by km on 02/01/2024.
//

import SwiftUI

struct KrakenVolumeCard: View {
    @EnvironmentObject var book: OrderBookData

    var body: some View {
        let bp = "\(book.stats.totalBidVolumePerc) %"
        let ap = "\(book.stats.totalAskVolumePerc) %"
        let bpraw = "\(book.stats.totalBidRawVolumePerc) %"
        let apraw = "\(book.stats.totalAskRawVolumePerc) %"

        VStack {
            Text(ap > bp ? "SELL" : "BUY")
            HStack(alignment: .center) {
                VStack {
                    Text(bp).foregroundColor(.blue)
                    Text(bpraw).foregroundColor(.gray).font(.caption)
                }
                VStack {
                    Text(ap).foregroundColor(.red)
                    Text(apraw).foregroundColor(.gray).font(.caption)
                }
            }
            Text(apraw > bpraw ? "SELL" : "BUY")
        }
        .frame(width: 200)
    }
}

#Preview {
    KrakenVolumeCard()
}
