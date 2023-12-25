//
//  RecentTrades.swift
//  dashboard
//
//  Created by km on 23/12/2023.
//

import SwiftUI

struct RecentTradesView: View {
    @EnvironmentObject var recentTrades: RecentTradesData
    @EnvironmentObject var book: OrderBookData

    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2)
    ]
    var body: some View {
        VStack {
            
            HStack{
                Text("Recent trades").font(.title3)
                LastTradeCell(trade: recentTrades.lastTrade)
               
            }.frame(width: 320, height: 25)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(.gray, lineWidth: 2)
                )
            ScrollView {
                LazyVGrid(columns: layout, spacing: 2) {
                    ForEach(recentTrades.alltrades) { trade in
                        RecentTradeCell(trade: trade, recentTrades: recentTrades, book: book)
                    }
                }
            }
        }.frame(width: 320)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            )
    }
}

#Preview {
    RecentTradesView()
}
