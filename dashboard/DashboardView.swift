//
//  DashboardView.swift
//  dashboard
//
//  Created by km on 28/12/2023.
//

import SwiftUI

struct DashboardView: View {
    var pair: String 
    var kraken_ws: Krakenbook
    var kraken_recent_trade_ws: KrakenRecentTrades
    var manager: KrakenOrderManager
    @State var isReady: Bool = false

    
    func setReady(_ publishedBook: OrderBookData!) -> Void {
        if !isReady && publishedBook != nil {
            isReady = true
        }
    }
    
    init(pair: String) {
        self.pair = pair
        self.kraken_ws = Krakenbook(pair, 25)
        self.kraken_recent_trade_ws = KrakenRecentTrades(pair)
        self.manager = KrakenOrderManager()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                HStack {
                    if isReady {
                        PairHomeView(volume: Constants.pairSettings[pair]!.minimumOrderVolume).environmentObject(kraken_ws.book).environmentObject(manager).environmentObject(kraken_recent_trade_ws.trades)
                    } else {
                        VStack {
                            Text("Connecting ... ").font(.title).foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 1200, maxWidth: .infinity, minHeight: 1000, maxHeight: .infinity, alignment: .leading)
        .padding([.top, .bottom, .leading, .trailing], 2)
        .onReceive(kraken_ws.$book) { setReady($0) }
    }
}

#Preview {
    DashboardView(pair: "MATIC/USD")
}
