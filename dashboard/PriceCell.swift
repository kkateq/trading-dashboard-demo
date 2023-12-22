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
    var body: some View {
        let isAskPeg = (level == depth - 1)
        let isBidPeg = (level == depth)
        let color = isAskPeg ? Color("RedTransparent"): (isBidPeg ? Color("GreenTransparent"): .white)
        Text(price)
            .frame(width: 100, height: 25, alignment: .center)
            .font(.system(.title3))
            .background(Rectangle().fill(color))
           
    }
}


struct PriceCell_Previews: PreviewProvider {
    static var previews: some View {
        PriceCell(price: "0.5656", depth: 25, level: 1)
    }
}
