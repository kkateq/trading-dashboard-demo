//
//  OrderBook.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct OrderBookView: View {

    @Binding var volume: Double
    @Binding  var scaleInOut: Bool
    @Binding  var validate: Bool
    @Binding  var useRest: Bool
    
    @EnvironmentObject var book: OrderBookData
    @EnvironmentObject var manager: Manager
    
    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2)
    ]
    
    func sellLimit(price: String) async {
        await manager.sellLimit(pair: book.pair, vol: volume, price: Double(price)!, scaleInOut: scaleInOut, validate: validate)
    }
    
    func buyLimit(price: String) async {
        await manager.buyLimit(pair: book.pair, vol: volume, price: Double(price)!, scaleInOut: scaleInOut, validate: validate)
    }
    
    var body: some View {
        VStack {
            let bp = "\(book.stats.totalBidVolumePerc) %"
            let ap = "\(book.stats.totalAskVolumePerc) %"
            LazyVGrid(columns: layout, spacing: 2) {
                Text("\(book.pair)").font(.title3)
                Text(bp).foregroundColor(.blue)
                VStack {
                    if book.isValid {
                        Text("Valid").foregroundColor(Color("Green"))
                    } else {
                        Text("Invalid").foregroundColor(Color("Red"))
                    }
                }
                Text(ap).foregroundColor(.red)
                Text("Depth: \(book.depth)")
            }
            ScrollView {
                LazyVGrid(columns: layout, spacing: 2) {
                    ForEach(book.allList) { record in
                       
                        let vol = String(format: "%.0f", round(Double(record.volume)!))
                        let price = "\(round(10000 * Double(record.price)!) / 10000)"
                        
                        if record.type == BookRecordType.ask {
                            PositionCell(position: "")
                            EmptyCell()
                            PriceCell(price: price)
                            AskCell(volume: vol, price: price, onSellLimit: sellLimit)
                            PositionCell(position: "")
                            
                        } else {
                            PositionCell(position: "")
                            BidCell(volume: vol, price: price, onBuyLimit: buyLimit)
                            PriceCell(price: price)
                            EmptyCell()
                            PositionCell(position: "")
                        }
                    }
                }
            }.overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 1))
        }
        .frame(width: 530)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray, lineWidth: 2)
        )
    }
}

//struct OrderBook_Previews: PreviewProvider {
//    static var previews: some View {
//        OrderBookView(volume: 2, scaleInOut: false, validate: true, useRest: false)
//    }
//}
