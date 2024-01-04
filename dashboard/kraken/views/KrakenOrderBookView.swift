//
//  OrderBook.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct KrakenOrderBookView: View {
    @Binding var volume: Double
    @Binding var scaleInOut: Bool
    @Binding var validate: Bool
    @Binding var useRest: Bool
    @Binding var stopLossEnabled: Bool
    @Binding var sellStopLoss: Double!
    @Binding var buyStopLoss: Double!
    
    @EnvironmentObject var book: KrakenOrderBookData

    @EnvironmentObject var manager: KrakenOrderManager
    
    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2)
    ]
    
    func sellLimit(price: String) async {
        await manager.sellLimit(pair: book.pair, vol: volume, price: Double(price)!, scaleInOut: scaleInOut, validate: validate, stopLoss: stopLossEnabled ? sellStopLoss : nil)
    }
    
    func buyLimit(price: String) async {
        await manager.buyLimit(pair: book.pair, vol: volume, price: Double(price)!, scaleInOut: scaleInOut, validate: validate, stopLoss: stopLossEnabled ? buyStopLoss : nil)
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: layout, spacing: 2) {
                Text("\(book.pair)").font(.title3)

                VStack {
                    if book.isValid {
                        Text("Valid").foregroundColor(Color("Green"))
                    } else {
                        Text("Invalid").foregroundColor(Color("Red"))
                    }
                }

                Text("Depth: \(book.depth)")
            }
            VStack {
                ZStack {
                    ScrollView {
                        LazyVGrid(columns: layout, spacing: 2) {
                            ForEach(book.allList) { record in
                            
                                let price = formatPrice(price: record.pr)
                                
                                if record.type == KrakenBookRecordType.ask {
                                    EmptyCell()
                                    PriceCell(price: price, depth: book.depth, up: book.recentPeg < book.stats.pegValue)
                                    VolumeCell(volume: record.vol, maxVolume: book.stats.maxVolume, type: .ask, price: price, onLimit: sellLimit)
                                 
                                } else {
                                    VolumeCell(volume: record.vol, maxVolume: book.stats.maxVolume, type: .bid, price: price, onLimit: buyLimit)
                                    PriceCell(price: price, depth: book.depth, up: book.recentPeg < book.stats.pegValue)
                                    EmptyCell()
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
        .frame(width: 330)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray, lineWidth: 2)
        )
    }
}
