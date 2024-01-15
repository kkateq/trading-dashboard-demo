//
//  BybitPriceVolumeChart.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import SwiftUI
import Charts


struct BybitBarValue: Identifiable {
//    var color: String
    var price: String
    var volume: Double
    var id = UUID()
    init(price: String, volume: Double, id: UUID = UUID()) {
        self.price = price
        self.volume = volume
        self.id = id
    }
}

struct BybitPriceVolumeChart: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    @EnvironmentObject var book: BybitOrderBook
    @State var data: [BybitBarValue] = []

    
    func updateChart(_ updatedList: [BybitRecentTradeRecord] ) -> Void {
        var res:[String:Double] = [:]
        
        for e in updatedList {
            let price = formatPrice(price: e.price, pair: e.pair)
            let volume = e.volume
            if res.contains(where: {$0.key == price}) {
                res[price] = res[price]! + volume
            } else {
                res[price] = volume
            }
        }
        
        data = res.keys.map({ BybitBarValue(price: $0, volume: res[$0]!)}).sorted(by: {Double($0.price)! > Double($1.price)!})
    }
    let yValues = stride(from: 0, to: 2, by: 0.0001).map { $0 }
    var body: some View {
        Chart {
            ForEach(data) { shape in
                
                BarMark(
                    x: .value("Volume", shape.volume),
                    y: .value("Price", shape.price),
                    width: .automatic
         
                )  .annotation(position: .trailing) {
                    Text("\(Int(shape.volume))")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            
            }
            RuleMark(y: .value("Ask", formatPrice(price: book.stats.bestAsk, pair: book.pair)))
                            .foregroundStyle(.red)
            RuleMark(y: .value("Bid", formatPrice(price: book.stats.bestBid, pair: book.pair)))
                            .foregroundStyle(.green)
        }

        .chartYAxis {
            AxisMarks(preset: .extended, position: .leading) { _ in
                AxisValueLabel(horizontalSpacing: 15)
                    .font(.footnote)
            }
        }
        .onReceive(recentTrades.$list, perform: updateChart)
        .frame(width: 300, height: 1150)
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    BybitPriceVolumeChart()
}
