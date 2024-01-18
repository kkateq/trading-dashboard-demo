//
//  BybitLastTradeCell.swift
//  dashboard
//
//  Created by km on 05/01/2024.
//

import SwiftUI

struct BybitLastTradeCell: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    var price: String
    @State var volume: Double = 0
    @State var lastPrice: String = ""


    var body: some View {
        if  let lastTrade = recentTrades.lastTradesBatch[price] {
            let text = Int(lastTrade.0)
            let bgColor = lastTrade.1 == .buy ? Color("GreenDarker") : Color("RedDarker")
            
            Text("\(text)")
                .frame(width: 46, height: 25)
                .font(.caption)
                .foregroundColor(bgColor)
                .background(.white)
        } else {
            Text("")
                .frame(width: 46, height: 25)
                .background(.white)
        }
    }
}
