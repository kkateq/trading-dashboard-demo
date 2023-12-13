//
//  OrderBook.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct OrderBook: View {
    @StateObject var kraken_ws = KrakenWS("MATIC/USD", 25)

    var body: some View {
        VStack {
            Spacer()
            Text(kraken_ws.isConnected ? "book is ready" : "Connecting ...")
            Spacer()
        }
    }
}

struct OrderBook_Previews: PreviewProvider {
    static var previews: some View {
        OrderBook()
    }
}
