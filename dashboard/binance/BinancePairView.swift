//
//  BinancePairView.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import SwiftUI

struct BinancePairView: View {
    var pair: String
    var depth: Int = 25
    var binance_ws: Binancebook
    @State var isReady: Bool = false

    func setReady(_ publishedBook: BinanceOrderBook!) {
        if !isReady && publishedBook != nil {
            isReady = true
        }
    }
    
    init(pair: String) {
        self.pair = pair
        self.binance_ws = Binancebook(Constants.PAIRS_ISO_NAMES_REV[pair]!, depth)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if isReady {
                BinanceOrderBookView()
                    .environmentObject(binance_ws.book)
                    .environmentObject(binance_ws)
            } else {
                Text("Connecting...")
                    .font(.title3).foregroundStyle(.blue)
            }
        }.onReceive(binance_ws.$book, perform: setReady)
    }
}

#Preview {
    BinancePairView(pair: "MATICUSDT")
}
