//
//  BybitOrderBookView.swift
//  dashboard
//
//  Created by km on 05/01/2024.
//

import SwiftUI

struct BybitOrderBookView: View {
    @EnvironmentObject var book: BybitOrderBook
    @State var prevBid: Double = 0
    @State var isUp = true
    @State var volume: Double = 0
    @State var isBuy = false
    
    let cellWidth = 100
    let cellHeight = 25
    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2)
    ]

    func updateDirection(stats: BybitStats!) {
        if prevBid > 0 {
            isUp = stats.bestBid > prevBid
        }
        prevBid = stats.bestBid
    }
    


    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: layout, spacing: 2) {
                    ForEach(book.allList) { record in
                        let isAskPeg = record.pr == book.stats.bestAsk
                        let isBidPeg = record.pr == book.stats.bestBid

                        let color = isAskPeg ? Color("Red") : (isBidPeg ? Color("Green") : .white)
                        if record.type == BybitBookRecordType.ask {
                            EmptyCell()
                            Text(formatPrice(price: record.pr, pair: book.pair))
                                .frame(width: 100, height: 25, alignment: .center)
                                .font(.title3)
                                .background(isUp ? Color("GreenTransparent") : Color("RedTransparent"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(color, lineWidth: 2)
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
                                .background(isUp ? Color("GreenTransparent") : Color("RedTransparent"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(color, lineWidth: 2)
                                )
                            EmptyCell()
                        }
                        if isAskPeg {
                            Text("\(Int(book.stats.totalBidRawVolumePerc))%")
                                .frame(width: 100, height: 25)
                                .foregroundStyle(.blue)
                                .background(.white)
                                .font(.title3)
                      
                            BybitLastTradeCell()
                            
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
                .stroke(.gray, lineWidth: 2)
        )
        .onReceive(book.$stats, perform: updateDirection)

    }
}

#Preview {
    BybitOrderBookView()
}
