//
//  OrderBook.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct OrderBookView: View {
    @EnvironmentObject var book: OrderBookData

    var body: some View {
        VStack {
            Spacer()

            ForEach(book.asks.values) { record in
                HStack(spacing: 10) {
                    Spacer().frame(width: 12)
                    Text("").frame(width: 125)
                    Divider()
                    Text(record.price).frame(width: 125)
                    Divider()
                    Text(record.volume).frame(width: 125).foregroundColor(.red)
                    Spacer().frame(width: 12)
                }
            }

            ForEach(book.bids.values) { record in
                HStack(spacing: 10) {
                    Spacer().frame(width: 12)
                    Text(record.volume).frame(width: 125).foregroundColor(.green)
                    Divider()
                    Text(record.price).frame(width: 125)
                    Divider()
                    Text("").frame(width: 125)
                    Spacer().frame(width: 12)
                }
            }
          
            VStack {
                if book.isValid {
                    Text("Valid").foregroundColor(.green)
                } else {
                    Text("Invalid").foregroundColor(.red)
                }
            }
            Spacer()
        }
    }
}

struct OrderBook_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookView()
    }
}
