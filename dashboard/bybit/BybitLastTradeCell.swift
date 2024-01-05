//
//  BybitLastTradeCell.swift
//  dashboard
//
//  Created by km on 05/01/2024.
//

import SwiftUI

struct BybitLastTradeCell: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData

    @State var volume: Double = 0
    @State var isBuy = false

    func updateLastTrade(_ record: BybitRecentTradeRecord!) {
        if record != nil {
            volume = record.volume
            isBuy = record.side == .buy
        }
    }

    var body: some View {
        Text("\(formatVolume(volume: volume, pair: recentTrades.lastTrade.pair))")
            .onReceive(recentTrades.$lastTrade, perform: updateLastTrade)
            .frame(width: 100, height: 25)
            .font(.title3)
            .foregroundColor(.white)
            .background(isBuy ? Color("GreenDarker") : Color("RedDarker"))
    }
}

#Preview {
    BybitLastTradeCell()
}
