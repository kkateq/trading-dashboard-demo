//
//  PriceCell.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct PriceCell: View {
    var price: String
    var body: some View {
        Text(price)
            .frame(width: 100, height: 25, alignment: .center)
            .font(.system(.title3))
            .background(Rectangle().fill(Color.white))
    }
}


struct PriceCell_Previews: PreviewProvider {
    static var previews: some View {
        PriceCell(price: "0.5656")
    }
}
