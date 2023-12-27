//
//  OrderBook.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI



struct OrderBookView: View {
    @Binding var volume: Double
    @Binding var scaleInOut: Bool
    @Binding var validate: Bool
    @Binding var useRest: Bool
    @Binding var stopLoss: Bool
    @Binding var stopLossPerc: Double
    
    @EnvironmentObject var book: OrderBookData

    @EnvironmentObject var manager: KrakenOrderManager
    
    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2)
    ]
    
    func sellLimit(price: String) async {
        await manager.sellLimit(pair: book.pair, vol: volume, price: Double(price)!, scaleInOut: scaleInOut, validate: validate, stopLoss: stopLoss, stopLossPerc: stopLossPerc)
    }
    
    func buyLimit(price: String) async {
        await manager.buyLimit(pair: book.pair, vol: volume, price: Double(price)!, scaleInOut: scaleInOut, validate: validate, stopLoss: stopLoss, stopLossPerc: stopLossPerc)
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
            VStack {
                ZStack {
                    ScrollView {
                        LazyVGrid(columns: layout, spacing: 2) {
                            ForEach(0 ..< book.allList.count) { index in
                                let record = book.allList[index]
                                let price = formatPrice(price: record.pr)
                                
                                if record.type == BookRecordType.ask {
                                    NoteCell()
                                    EmptyCell()
                                    PriceCell(price: price, depth: book.depth, level: index, up: book.recentPeg < book.stats.pegValue)
                                    VolumeCell(volume: record.vol, maxVolume: book.stats.maxVolume, type: .ask, price: price, onLimit: sellLimit)
                                    NoteCell()
                                   
                                } else {
                                    NoteCell()
                                    VolumeCell(volume: record.vol, maxVolume: book.stats.maxVolume, type: .bid, price: price, onLimit: buyLimit)
                                    PriceCell(price: price, depth: book.depth, level: index, up: book.recentPeg < book.stats.pegValue)
                                    EmptyCell()
                                    NoteCell()
                                }
                            }
                        }
                    }.overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(.gray, lineWidth: 1))
                    
                    GridOverlay()
                }
            }
        }
        .frame(width: 530)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray, lineWidth: 2)
        )
    }
}
