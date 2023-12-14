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
        let layout = [
            GridItem(.fixed(100), spacing: 2),
            GridItem(.fixed(100), spacing: 2),
            GridItem(.fixed(100), spacing: 2),
            GridItem(.fixed(100), spacing: 2),
            GridItem(.fixed(100), spacing: 2)
        ]
        VStack {
            ScrollView {
                LazyVGrid(columns: layout, spacing: 2) {
                    ForEach(book.allList) { record in
                       
                        let vol = String(format: "%.0f", round(Double(record.volume)!))
                        let price = "\(round(10000 * Double(record.price)!) / 10000)"
                        
                        if record.type == BookRecordType.ask {
                            PositionCell(position: "")
                            EmptyCell()
                            PriceCell(price: price)
                            VolumeCell(volume: vol, side: BookRecordType.ask)
                            PositionCell(position: "")
                            
                        } else {
                            PositionCell(position: "")
                            VolumeCell(volume: vol, side: BookRecordType.bid)
                            PriceCell(price: price)
                            EmptyCell()
                            PositionCell(position: "")
                        }
                    }
                }
            }.overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray, lineWidth: 2)
            )
              
            LazyVGrid(columns: layout, spacing: 2) {
                let bp = "\(book.stats.totalBidVolumePerc) %"
                let ap = "\(book.stats.totalAskVolumePerc) %"
                Text("\(book.pair)").font(.title3)
                Text(bp).foregroundColor(.blue)
                  
                VStack {
                    if book.isValid {
                        Text("Valid").foregroundColor(.green)
                    } else {
                        Text("Invalid").foregroundColor(.red)
                    }
                }.frame(width: 100)
                  
                Text(ap).foregroundColor(.red)
                Text("Depth: \(book.depth)")
            }
        }
    }
}

struct OrderBook_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookView()
    }
}
