//
//  BybitPriceCell.swift
//  dashboard
//
//  Created by km on 16/01/2024.
//

import SwiftUI

struct BybitPriceCell: View {
    @EnvironmentObject var book: BybitOrderBook
    var price: Double
    var priceStr: String
    var side: BybitBookRecordType
    var body: some View {
        let isAskPeg = price == book.stats.bestAsk
        let isBidPeg = price == book.stats.bestBid
        let color = isAskPeg ? Color("Red") : (isBidPeg ? Color("Green") : Color("Background"))
        
        HStack {
            Text(formatPrice(price: price, pair: book.pair))
                .font(.title3)
                .frame(width: 100, alignment: .center)
            BybitLastTradeCell(price: priceStr)
        }
        .frame(width: 150, height: 25)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 1)
                .stroke(color, lineWidth: 1)
        )
    }
}

