//
//  OrderBook.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct OrderBookView: View {
    @EnvironmentObject var book: OrderBookData
    @EnvironmentObject var manager: Manager
    
    @State private var scaleInOut = true
    @State private var validate = true
    
    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2)
    ]
    
    func sellLimit(vol: String, price: String) async -> Void {
        await manager.sellLimit(pair: book.pair, vol: Double(vol)!, price: Double(price)!, scaleInOut: scaleInOut, validate: validate)
    }
    
    func buyLimit(vol: String, price: String) async -> Void {
        await manager.buyLimit(pair: book.pair, vol: Double(vol)!, price: Double(price)!, scaleInOut: scaleInOut, validate: validate)
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
              
            VStack {
                HStack {
                    Toggle("Validate orders", isOn: $validate)
                        .toggleStyle(.checkbox)
                    Spacer()
                    Toggle("Scale In/Out", isOn: $scaleInOut)
                        .toggleStyle(.checkbox)
                }
            }.padding([.trailing, .leading, .bottom], 4)
           
        }
        .frame(width: 530)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray, lineWidth: 2)
        )
    }
}

struct OrderBook_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookView()
    }
}
