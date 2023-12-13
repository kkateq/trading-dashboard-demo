//
//  ContentView.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var kraken_ws = KrakenWS("MATIC/USD", 10)
    
    var body: some View {
        VStack {
            if kraken_ws.book != nil {
                OrderBookView().environmentObject(kraken_ws.book)
            } else {
                Text("Connecting ... ")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
