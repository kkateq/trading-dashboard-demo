//
//  BybitPriceVolumeChart.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import SwiftUI
import Charts


struct BybitBarValue: Identifiable {
    var color: String
    var side: BybitTradeSide
    var price: String
    var volume: Double
    var id = UUID()
    init(price: String, volume: Double, side: BybitTradeSide) {
        self.price = price
        self.volume = volume
        self.side = side
        self.color = side == .buy ? "Green" : "Red"
    }
}

struct BybitPriceVolumeChart: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    @EnvironmentObject var book: BybitOrderBook
    @State var data: [BybitBarValue] = []

    
    func updateChart(_ updatedList: [BybitRecentTradeRecord] ) -> Void {
        var res:[BybitBarValue] = []
        
        
        recentTrades.priceDictBuys.forEach { key, value in
            res.append(BybitBarValue(price: key, volume: value, side: .buy))
        }
        
        recentTrades.priceDictSells.forEach { key, value in
            res.append(BybitBarValue(price: key, volume: value, side: .sell))
        }
        
        data = res.sorted(by: {Double($0.price)! > Double($1.price)!})
    }
    
    let yValues = stride(from: 0, to: 2, by: 0.0001).map { $0 }
    var body: some View {
        VStack {
            Button(action: {
                Task {
                    recentTrades.clean()
                }
            }) {
                HStack {
                    Text("Clear recent")
                }.frame(width: 200, height: 30)
                    .foregroundColor(Color.white)
                    .background(Color.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .imageScale(.large)
            }.buttonStyle(PlainButtonStyle())
            Chart {
                ForEach(data) { shape in
                    
                    BarMark(
                        x: .value("Volume", shape.volume),
                        y: .value("Price", shape.price),
                        width: .automatic
                        
                    )  
                    //                .annotation(position: .trailing) {
                    //                    Text("\(Int(shape.volume))")
                    //                        .foregroundColor(.secondary)
                    //                        .font(.caption)
                    //                }
                    .foregroundStyle(by: .value("Shape Color", shape.color))
                    
                    
                }
                RuleMark(y: .value("Ask", formatPrice(price: book.stats.bestAsk, pair: book.pair)))
                    .foregroundStyle(.red)
                RuleMark(y: .value("Bid", formatPrice(price: book.stats.bestBid, pair: book.pair)))
                    .foregroundStyle(.green)
            }
            .chartForegroundStyleScale([
                "Green": Color("BidChartColor"), "Red": Color("AskChartColor"),
            ])
            
            .chartYAxis {
                AxisMarks(preset: .extended, position: .leading) { _ in
                    AxisValueLabel(horizontalSpacing: 15)
                        .font(.footnote)
                }
            }
            
            .onReceive(recentTrades.$sells, perform: updateChart)
            .frame(width: 300, height: 1150)
            .fixedSize(horizontal: true, vertical: false)
        }
    }
}

#Preview {
    BybitPriceVolumeChart()
}
