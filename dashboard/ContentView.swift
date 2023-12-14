//
//  ContentView.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var kraken_ws = KrakenWS("MATIC/USD", 25)
    
    var body: some View {
        HStack {
            VStack {
                if kraken_ws.book != nil {
                    OrderBookView().environmentObject(kraken_ws.book)
                } else {
                    Text("Connecting ... ")
                }
            }
            VStack {
                OrdersView()
                PositionsView()
            }
        }
        .frame(minWidth: 800, maxWidth: .infinity, minHeight: 1000, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
