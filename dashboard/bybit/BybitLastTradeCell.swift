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
    @State var lastPrice: String
    @State var isBuy = false

    func updateLastTrade(_ record: BybitRecentTradeRecord!) {
        if record != nil {
            volume = record.volume
            lastPrice = record.priceStr
            isBuy = record.side == .buy
        }
    }

    var body: some View {
        let text = price == lastPrice ? formatVolume(volume: volume, pair: recentTrades.lastTrade.pair) : ""
        Text(text)
            .onReceive(recentTrades.$lastTrade, perform: updateLastTrade)
            .frame(width: 50, height: 25)
            .font(.title3)
            .foregroundColor(.white)
            .background(isBuy ? Color("GreenDarker") : Color("RedDarker"))
    }
}
