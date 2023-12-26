//
//  PriceCell.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct PriceCell: View {
    var price: String
    var depth: Int
    var level: Int
    var up: Bool
    var body: some View {
        let isAskPeg = (level == depth - 1)
        let isBidPeg = (level == depth)
        let color = isAskPeg ? Color("Red") : (isBidPeg ? Color("Green") : .white)
        Text(price)
            .frame(width: 100, height: 25, alignment: .center)
            .font(.system(.title3))
            .background(Rectangle().fill(up ? Color("GreenTransparent") : Color("RedTransparent")))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(color, lineWidth: 2)
            )
    }
}

struct PriceCell_Previews: PreviewProvider {
    static var previews: some View {
        PriceCell(price: "0.5656", depth: 25, level: 1, up: false)
    }
}
