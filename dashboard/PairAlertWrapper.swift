//
//  PairAlertWrapper.swift
//  dashboard
//
//  Created by km on 23/01/2024.
//

import SwiftUI

struct PairAlertWrapper: View {
    var pair: String
    var bybitbook_ws: Bybitbook
    var bybittrades_ws: BybitLastTrade
    
    @State var isBookSocketReady: Bool = false
    @State var isInfoReady: Bool = false
    @State var isTradesSocketReady: Bool = false
    
    init(pair: String) {
        self.pair = pair
        self.bybitbook_ws = Bybitbook(self.pair, 1)
        self.bybittrades_ws = BybitLastTrade(self.pair)
    }

    func setBookReady(_ publishedBook: BybitOrderBook!) {
        if !isBookSocketReady && publishedBook != nil {
            isBookSocketReady = true
        }
    }

    func setInfoReady(_ info: BybitInstrumentInfo!) {
        if !isInfoReady && info != nil {
            isInfoReady = true
        }
    }
    
    func setTradesReady(_ publishedBook: BybitRecentTradeData!) {
        if !isTradesSocketReady && publishedBook != nil {
            isTradesSocketReady = true
        }
    }

    var body: some View {
        VStack {
            if isBookSocketReady && isInfoReady && isTradesSocketReady {
                PairAlertCard(pair: pair)
                    .environmentObject(bybitbook_ws.book)
                    .environmentObject(bybitbook_ws.info)
                    .environmentObject(bybittrades_ws.recentTrades)
            } else {
                Text("Connecting ...")
            }
        }.onReceive(bybitbook_ws.$book, perform: setBookReady)
            .onReceive(bybitbook_ws.$info, perform: setInfoReady)
            .onReceive(bybittrades_ws.$recentTrades, perform: setTradesReady)
    }
}

#Preview {
    PairAlertWrapper(pair: "")
}
