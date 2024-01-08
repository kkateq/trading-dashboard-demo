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
//    var bybitprivate_ws: BybitPrivateManager
    
    @State var isBookSocketReady: Bool = false
    @State var isTradesSocketReady: Bool = false
    
    init(pair: String) {
        self.pair = pair
        self.bybitbook_ws = Bybitbook(self.pair)
        self.bybittrades_ws = BybitLastTrade(self.pair)
//        self.bybitprivate_ws = BybitPrivateManager()
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
                        
                    BybitTimesAndSalesView()
                    
                    BybitPriceVolumeChart()
                    
                 
                } .environmentObject(bybittrades_ws.recentTrades)
                    .environmentObject(bybitbook_ws.book)
                
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
