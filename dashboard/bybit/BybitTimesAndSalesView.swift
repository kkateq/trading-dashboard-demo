//
//  BybitTimesAndSalesView.swift
//  dashboard
//
//  Created by km on 05/01/2024.
//

import SwiftUI

struct BybitTimesAndSalesView: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    
    let cellWidth = 100
    let cellHeight = 20
    let layout = [
        GridItem(.fixed(70), spacing: 2),
        GridItem(.fixed(30), spacing: 2),
//        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(30), spacing: 2)
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: layout, spacing: 2) {
                    ForEach(recentTrades.list.reversed()) { record in
                        let color = record.side == .sell ? Color("Red") : Color("Blue")
                        let bgColor:Color = .white
                        Text("\(formatPrice(price: record.price, pair: record.pair))")
                            .foregroundStyle(color)
                            .frame(width: 70, height: 20, alignment: .leading)
                            .background(bgColor)
                        Text("\(record.side == .buy ? "BUY" : "SELL")")
                            .foregroundStyle(color)
                            .frame(width: 30, height: 20, alignment: .leading)
                            .background(bgColor)
//                        Text("\(record.time)")
//                            .foregroundStyle(color)
                        Text("\(formatVolume(volume: record.volume, pair: record.pair))")
                            .foregroundStyle(color)
                            .frame(width: 30, height: 20, alignment: .leading)
                            .background(bgColor)
                        
                    }
                }
            }
        }.frame(width: 160)
            .background(Color("Background"))
            .font(.caption)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            )
    }
}

#Preview {
    BybitTimesAndSalesView()
}
