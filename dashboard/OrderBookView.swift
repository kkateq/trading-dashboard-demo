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
            List {
                ForEach(book.all.values) { record in
                    if record.type == BookRecordType.ask {
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
                    
                    else {
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
