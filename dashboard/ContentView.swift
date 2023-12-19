//
//  ContentView.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var kraken_ws = Krakenbook("MATIC/USD", 25)
    @StateObject var manager = Manager()
    

    var body: some View {
        HStack(alignment: .top) {
            HStack {
                if kraken_ws.book != nil {
                    OrderBookView().environmentObject(kraken_ws.book)
                    if kraken_ws.isBookInitialized {
                        OrderForm(pegValue: kraken_ws.book.stats.pegValue, bestBid: kraken_ws.book.stats.bestBid, bestAsk: kraken_ws.book.stats.bestAsk).environmentObject(manager)
                    }
                } else {
                    Text("Connecting ... ")
                }
            }

            
        }
        .frame(minWidth: 1200, maxWidth: .infinity, minHeight: 1000, maxHeight: .infinity, alignment: .leading)
        .padding([.top, .bottom, .leading, .trailing], 2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
