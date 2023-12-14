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
            ForEach(book.allList) { record in

                if record.type == BookRecordType.ask {
                    HStack(spacing: 0) {
                        Text("").frame(width: 125)
                        Divider()
                        Text(record.price).frame(width: 125)
                        Divider()
                        Text(record.volume).frame(width: 125).foregroundColor(.pink)
                    }
                } else {
                    HStack(spacing: 0) {
                        Text(record.volume).frame(width: 125).foregroundColor(.blue)
                        Divider()
                        Text(record.price).frame(width: 125)
                        Divider()
                        Text("").frame(width: 125)
                    }
                }
                Divider()
            }

            VStack {
                HStack {
                    let bp = "\(book.stats.totalBidVolumePerc) %"
                    let ap = "\(book.stats.totalAskVolumePerc) %"

                    Text(bp).foregroundColor(.blue)
                    VStack {
                        if book.isValid {
                            Text("Valid").foregroundColor(.green)
                        } else {
                            Text("Invalid").foregroundColor(.red).font(.caption)
                        }
                    }

                    Text(ap).foregroundColor(.red)
                }
            }
        }
    }
}

struct OrderBook_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookView()
    }
}
