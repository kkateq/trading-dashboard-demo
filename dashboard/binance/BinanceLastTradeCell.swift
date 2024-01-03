//
//  BinanceLastTrade.swift
//  dashboard
//
//  Created by km on 03/01/2024.
//

import SwiftUI

struct BinanceLastTradeCell: View {
    @EnvironmentObject var binance_ws: Binancebook

    @State var volume: Double = 0
    @State var isBuy = false

    func updateLastTrade(trade: BinanceLastTrade!) {
        if trade != nil {
            volume = Double(trade.volume)!
            isBuy = trade.isBuy
        }
    }

    var body: some View {
        Text("\(formatVolume(volume: volume, pair: binance_ws.pair))")
            .frame(width: 100, height: 25)
            .font(.title3)
            .foregroundColor(.white)

            .onReceive(binance_ws.$lastTrade, perform: updateLastTrade)
            .background(isBuy ? Color("GreenDarker") : Color("RedDarker"))

        
    }
}

#Preview {
    BinanceLastTradeCell()
}
