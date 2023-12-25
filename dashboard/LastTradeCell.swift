//
//  LastTradeCell.swift
//  dashboard
//
//  Created by km on 23/12/2023.
//

import SwiftUI

struct LastTradeCell: View {
    var trade: TradeRecord!

    var body: some View {
        VStack {
            if let lastTrade = trade {
                let volume = String(format: "%.0f", round(lastTrade.volume))
                HStack {
                    Text(lastTrade.priceStr)
                        .frame(width: 100, height: 25, alignment: .leading)
                        .background(.white)
                    Text(volume)
                        .frame(width: 100, height: 25, alignment: .trailing)
                        .font(.system(.title3))
                        .foregroundColor(.black).font(.system(.title3))
                        .background(Rectangle().fill(lastTrade.side == "s" ? Color("RedLight") : Color("GreenLight")))
                }

            } else {
                Text("No recent").frame(width: 200, height: 25, alignment: .trailing)
                    .background(Rectangle().fill(Color.white))
            }
        }
    }
}

#Preview {
    LastTradeCell( /* price: "0.9999" */ )
}
