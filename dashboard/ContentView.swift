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
            VStack {
                if kraken_ws.book != nil {
//                    OrderBookView().environmentObject(kraken_ws.book)
                    OrderForm(pegValue: kraken_ws.book.stats.pegValue).environmentObject(manager)
                } else {
                    Text("Connecting ... ")
                }
            }

            
        }
        .frame(minWidth: 1200, maxWidth: .infinity, minHeight: 1000, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
