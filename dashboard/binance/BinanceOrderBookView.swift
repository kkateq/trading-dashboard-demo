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
            ScrollView {
                LazyVGrid(columns: layout, spacing: 2) {
                    ForEach(book.allList) { record in
                        let isAskPeg = record.pr == book.stats.bestAsk
                        let isBidPeg = record.pr == book.stats.bestBid

                        let color = isAskPeg ? Color("Red") : (isBidPeg ? Color("Green") : Color("Background"))
                        if record.type == BinanceBookRecordType.ask {
                            EmptyCell()
                            Text(formatPrice(price: record.pr, pair: book.pair))
                                .frame(width: 100, height: 25, alignment: .center)
                                .font(.title3)
                                .background(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1)
                                        .stroke(color, lineWidth: 1)
                                )
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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1)
                                        .stroke(color, lineWidth: 1)
                                )
                            EmptyCell()
                        }
                        if isAskPeg {
                            Text("\(Int(book.stats.totalBidRawVolumePerc))%")
                                .frame(width: 100, height: 25)
                                .foregroundStyle(.blue)
                                .background(.white)
                                .font(.title3)

                            BinanceLastTradeCell()

                            Text("\(Int(book.stats.totalAskRawVolumePerc))%")
                                .frame(width: 100, height: 25)
                                .foregroundStyle(.red)
                                .background(.white)
                                .font(.title3)
                        }
                    }
                }
            }.overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 1))
        }
        .frame(width: 330)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.blue, lineWidth: 2)
        )
    }
}

#Preview {
    BinanceOrderBookView()
}
