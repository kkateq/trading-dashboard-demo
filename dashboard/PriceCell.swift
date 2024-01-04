//
//  PriceCell.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct PriceCell: View {
    @EnvironmentObject var book: KrakenOrderBookData

    var price: String
    var depth: Int
    var up: Bool

    var bgColor: Color {
        let up = book.isUp()
        if let isUp = up {
            return isUp ? Color("GreenTransparent") : Color("RedTransparent")
        } else {
            return Color("Transparent")
        }
    }

    var body: some View {
        let isAskPeg = (Double(price)! == book.stats.bestAsk)
        let isBidPeg = (Double(price)! == book.stats.bestBid)

        let color = isAskPeg ? Color("Red") : (isBidPeg ? Color("Green") : .white)
        Text(price)
            .frame(width: 100, height: 25, alignment: .center)
            .font(.system(.title3))
            .background(Rectangle().fill(bgColor))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(color, lineWidth: 2)
            )
    }
}

struct PriceCell_Previews: PreviewProvider {
    static var previews: some View {
        PriceCell(price: "0.5656", depth: 25, up: false)
    }
}
