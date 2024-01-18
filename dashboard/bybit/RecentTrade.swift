//
//  RecentTrade.swift
//  dashboard
//
//  Created by km on 16/01/2024.
//

import SwiftUI

struct RecentTrade: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    var price: String
    var side: BybitTradeSide
    var pair: String
    
    func getRecentTrade() -> String {
        let dict = side == .sell ? recentTrades.priceDictSellsTemp : recentTrades.priceDictBuysTemp
        if let pr = dict[price] {
            return "\(Int(pr))"
        }
        
        return ""
    }
    
    var body: some View {
        Text("\(getRecentTrade())")
            .frame(width: 100, height: 25, alignment: .center)
            .background(.white)
            .foregroundColor(side == .sell ? Color("Red") : Color("Blue"))
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .stroke(Color("Background"), lineWidth: 1))
    }
}
