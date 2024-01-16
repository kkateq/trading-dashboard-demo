//
//  BybitOrderBookView.swift
//  dashboard
//
//  Created by km on 05/01/2024.
//

import SwiftUI

struct BybitOrderBookView: View {
    @EnvironmentObject var book: BybitOrderBook
    @EnvironmentObject var manager: BybitPrivateManager

    @Binding var volume: Double
    @Binding var scaleInOut: Bool

    @Binding var stopLossEnabled: Bool
    @Binding var takeProfitEnabled: Bool
    @Binding var sellStopLoss: Double!
    @Binding var buyStopLoss: Double!
    @Binding var sellTakeProfit: Double!
    @Binding var buyTakeProfit: Double!
    
    let cellWidth = 100
    let cellHeight = 25
    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2)
    ]
    
    func sellLimit(price: String) async {
        await manager.sellLimit(symbol: book.pair, vol: volume, price: Double(price)!, scaleInOut: scaleInOut, stopLoss: stopLossEnabled ? sellStopLoss : nil, takeProfit: takeProfitEnabled ? sellTakeProfit: nil)
    }
    
    func buyLimit(price: String) async {
        await manager.buyLimit(symbol: book.pair, vol: volume, price: Double(price)!, scaleInOut: scaleInOut, stopLoss: stopLossEnabled ? buyStopLoss : nil, takeProfit: takeProfitEnabled ? buyTakeProfit: nil)
    }


    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: layout, spacing: 2) {
                    ForEach(book.allList) { record in
                        let isAskPeg = record.pr == book.stats.bestAsk
                        let isBidPeg = record.pr == book.stats.bestBid

                        let color = isAskPeg ? Color("Red") : (isBidPeg ? Color("Green") : Color("Background"))
                        if record.type == BybitBookRecordType.ask {
                            RecentTrade(price: record.price, side: .buy, pair: book.pair)
                            EmptyCell()
                            Text(formatPrice(price: record.pr, pair: book.pair))
                                .frame(width: 100, height: 25, alignment: .center)
                                .font(.title3)
                                .background(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1)
                                        .stroke(color, lineWidth: 1)
                                )
                            VolumeCell(volume: record.vol, maxVolume: book.stats.maxVolume, type: .ask, price: record.price, onLimit: sellLimit)
                            RecentTrade(price: record.price, side: .sell, pair: book.pair)

                        } else {
                            RecentTrade(price: record.price, side: .buy, pair: book.pair)
                            VolumeCell(volume: record.vol, maxVolume: book.stats.maxVolume, type: .bid, price: record.price, onLimit: buyLimit)
                            Text(formatPrice(price: record.pr, pair: book.pair))
                                .frame(width: 100, height: 25, alignment: .center)
                                .font(.title3)
                                .background(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1)
                                        .stroke(color, lineWidth: 1)
                                )
                            EmptyCell()
                            RecentTrade(price: record.price, side: .sell, pair: book.pair)
                        }
                        if isAskPeg {
                            EmptyCell()
                            Text("\(Int(book.stats.totalBidRawVolumePerc))%")
                                .frame(width: 100, height: 25)
                                .foregroundStyle(.blue)
                                .background(.white)
                                .font(.title3)

                            BybitLastTradeCell()

                            Text("\(Int(book.stats.totalAskRawVolumePerc))%")
                                .frame(width: 100, height: 25)
                                .foregroundStyle(.red)
                                .background(.white)
                                .font(.title3)
                            EmptyCell()
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

//#Preview {
//    BybitOrderBookView()
//}
