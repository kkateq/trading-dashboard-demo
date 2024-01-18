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
    let cellHeight = 35
    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(150), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2)
    ]

    func sellLimit(price: String) async {
        await manager.sellLimit(symbol: book.pair, vol: volume, price: Double(price)!, scaleInOut: scaleInOut, stopLoss: stopLossEnabled ? sellStopLoss : nil, takeProfit: takeProfitEnabled ? sellTakeProfit : nil)
    }

    func buyLimit(price: String) async {
        await manager.buyLimit(symbol: book.pair, vol: volume, price: Double(price)!, scaleInOut: scaleInOut, stopLoss: stopLossEnabled ? buyStopLoss : nil, takeProfit: takeProfitEnabled ? buyTakeProfit : nil)
    }

    var body: some View {
        VStack {

            ScrollView {
                LazyVGrid(columns: layout, spacing: 2) {
                    ForEach(book.allList) { record in
                        let isAskPeg = record.pr == book.stats.bestAsk
                        if record.type == BybitBookRecordType.ask {
                            RecentTrade(price: record.price, side: .buy, pair: book.pair)
                            EmptyCell(width: 100)
                            BybitPriceCell(price: record.pr, priceStr: record.price, side: .ask)
                            VolumeCell(volume: record.vol, maxVolume: book.stats.maxVolume, type: .ask, price: record.price, onLimit: sellLimit)
                            RecentTrade(price: record.price, side: .sell, pair: book.pair)

                        } else {
                            RecentTrade(price: record.price, side: .buy, pair: book.pair)
                            VolumeCell(volume: record.vol, maxVolume: book.stats.maxVolume, type: .bid, price: record.price, onLimit: buyLimit)
                            BybitPriceCell(price: record.pr, priceStr: record.price, side: .bid)
                            EmptyCell(width: 100)
                            RecentTrade(price: record.price, side: .sell, pair: book.pair)
                        }
                        if isAskPeg {
                            EmptyCell(width: 100)

                            Text("\(Int(book.stats.totalBidVolumePerc))%")
                                .frame(width: 100, height: 25)
                                .foregroundStyle(.blue)
                                .background(.white)
                                .font(.title3)

                            Text("\(book.stats.bestAsk - book.stats.bestBid)")   
                                .frame(width: 150, height: 25)
                                .foregroundStyle(.black)
                                .background(.white)
                                .font(.title3)

                            Text("\(Int(book.stats.totalAskVolumePerc))%")
                                .frame(width: 100, height: 25)
                                .foregroundStyle(.red)
                                .background(.white)
                                .font(.title3)
                            EmptyCell(width: 100)
                        }
                    }
                }
            }.overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 1))
        }
        .frame(width: 580)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray, lineWidth: 2)
        )
    }
}

// #Preview {
//    BybitOrderBookView()
// }
