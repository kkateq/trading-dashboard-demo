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

            ForEach(book.allList) { record in
                if record.type == BookRecordType.ask {
                    HStack(spacing: 10) {
                      
                        Text("").frame(width: 125)
                        Divider()
                        Text(record.price).frame(width: 125)
                        Divider()
                        Text(record.volume).frame(width: 125).foregroundColor(.red)
                        
                    }
                } else  {
                    HStack(spacing: 10) {
                    
                        Text(record.volume).frame(width: 125).foregroundColor(.green)
                        Divider()
                        Text(record.price).frame(width: 125)
                        Divider()
                        Text("").frame(width: 125)
                     
                    }
                }
            }
          
            VStack {
                if book.isValid {
                    Text("Valid").foregroundColor(.green)
                } else {
                    Text("Invalid").foregroundColor(.red)
                }
            }
            VStack {
                HStack {
                    let bp = "\(book.stats.totalBidVolumePerc) %"
                    let ap = "\(book.stats.totalAskVolumePerc) %"
                    Text(bp).foregroundColor(.blue)
                    Spacer()
                    Text(ap).foregroundColor(.red)
                }
            }
            Spacer()
        }
    }
}

struct OrderBook_Previews: PreviewProvider {
    static var previews: some View {
        let book = OrderBookData("MATIC/USD", 10)
        
        OrderBookView().environmentObject(book)
    }
}
