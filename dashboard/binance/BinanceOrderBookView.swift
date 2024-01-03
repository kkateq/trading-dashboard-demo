//
//  BinanceOrderBookView.swift
//  dashboard
//
//  Created by km on 02/01/2024.
//

import SwiftUI

struct BinanceOrderBookView: View {
    @EnvironmentObject var book: BinanceOrderBook

    let cellWidth = 100
    let cellHeight = 25
    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2)
    ]

    var body: some View {
        VStack {
            LazyVGrid(columns: layout, spacing: 2) {
                Text("\(book.pair)").font(.title3)

                HStack {
                    Text("\(Int(book.stats.totalAskRawVolumePerc))% - ").foregroundStyle(.red)
                    Text("\(Int(book.stats.totalBidRawVolumePerc))%").foregroundStyle(.blue)
                }

                Text("Depth: \(book.depth)")
            }
            VStack {
                ZStack {
                    ScrollView {
                        LazyVGrid(columns: layout, spacing: 2) {
                            ForEach(book.allList) { record in

                                if record.type == BookRecordType.ask {
                                    EmptyCell()
                                    Text(formatPrice(price: record.pr, pair: book.pair))
                                        .frame(width: 100, height: 25, alignment: .center)
                                        .font(.title3)
                                        .background(.white)
                                    Text(formatVolume(volume: record.vol, pair: book.pair))
                                        .frame(width: 100, height: 25, alignment: .leading)
                                        .font(.title3)
                                        .foregroundColor(Color("AskTextColor"))
                                        .background(.white)

                                } else {
                                    Text(formatVolume(volume: record.vol, pair: book.pair))
                                        .frame(width: 100, height: 25, alignment: .trailing)
                                        .font(.title3)
                                        .foregroundColor(Color("BidTextColor"))
                                        .background(.white)
                                    Text(formatPrice(price: record.pr, pair: book.pair))
                                        .frame(width: 100, height: 25, alignment: .center)
                                        .font(.title3)
                                        .background(.white)
                                    EmptyCell()
                                }
                            }
                        }
                    }.overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(.gray, lineWidth: 1))

                    GridOverlay()
                }
            }
        }
        .frame(width: 330)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray, lineWidth: 2)
        )
    }
}

#Preview {
    BinanceOrderBookView()
}
