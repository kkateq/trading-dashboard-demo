//
//  BybitPairView.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import SwiftUI

struct BybitPairView: View {
    var pair: String
    var bybitbook_ws: Bybitbook
    var bybittrades_ws: BybitLastTrade
    
    @State var isBookSocketReady: Bool = false
    @State var isTradesSocketReady: Bool = false
    
    init(pair: String) {
        self.pair = pair
        self.bybitbook_ws = Bybitbook(self.pair)
        self.bybittrades_ws = BybitLastTrade(self.pair)
    }
    
    func setBookReady(_ publishedBook: BybitOrderBook!) {
        if !isBookSocketReady && publishedBook != nil {
            isBookSocketReady = true
        }
    }
    
    func setTradesReady(_ publishedBook: BybitRecentTradeData!) {
        if !isTradesSocketReady && publishedBook != nil {
            isTradesSocketReady = true
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if isBookSocketReady && isTradesSocketReady {
                HStack {
                    BybitOrderBookView()
                        .environmentObject(bybitbook_ws.book)
                        .environmentObject(bybittrades_ws.recentTrades)
                    BybitTimesAndSalesView()
                        .environmentObject(bybittrades_ws.recentTrades)
                }
                
            } else {
                Text("Connecting...")
                    .font(.title3).foregroundStyle(.blue)
            }
        }.onReceive(bybitbook_ws.$book, perform: setBookReady)
            .onReceive(bybittrades_ws.$recentTrades, perform: setTradesReady)
    }
}

#Preview {
    BybitPairView(pair: "test")
}
