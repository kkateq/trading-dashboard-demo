//
//  PositionRecomendation.swift
//  dashboard
//
//  Created by km on 29/12/2023.
//

import SwiftUI

struct PositionRecomendation: View {
    @EnvironmentObject var book: KrakenOrderBookData
    @State var recommendationHistory: [Int] = []
    @State var buyPerc: Double = 0
    @State var sellPerc: Double = 0
    
    @State var recommendation: Int = 100
    
    func updateChart(_ publishedStats: KrakenStats!) {
        if publishedStats.totalAskVol > publishedStats.totalBidVol && publishedStats.totalAskVolRaw > publishedStats.totalBidVolRaw {
            recommendation = 0
        } else {
            recommendation = 1
        }
        recommendationHistory.append(recommendation)
        let sells = Double(recommendationHistory.filter({$0 == 0}).count)
        let buys = Double(recommendationHistory.filter({$0 == 1}).count)
        let total = buys + sells
        buyPerc = buys / total
        sellPerc = sells / total
    }
    
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if recommendation == 0 {
                        Text("SELL").font(.largeTitle).foregroundStyle(Color("Red"))
                        
                    } else {
                        Text("BUY").font(.largeTitle).foregroundStyle(Color("Green"))
                    }
                    HStack {
                        Text("\(Int(sellPerc * 100)) %").font(.caption).foregroundStyle(Color("Red"))
                        Spacer()
                        Text("\(Int(buyPerc * 100)) %").font(.caption).foregroundStyle(Color("Green"))
                    }
                }
               
            }.frame(height: 50)
        }.onReceive(book.$stats, perform: updateChart)
    }
}

#Preview {
    PositionRecomendation()
}
