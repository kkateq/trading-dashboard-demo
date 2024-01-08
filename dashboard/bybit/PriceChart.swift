//
//  PriceChart.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import SwiftUI
import Charts

struct LineValue: Identifiable {
    var price: Double
    var time: Date
    var id = UUID()
}

struct PriceChart: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    @State var data: [LineValue] = []

    func updateChart(_ updatedList: [BybitRecentTradeRecord]) {
        var res: [LineValue] = []
        for e in updatedList.reversed() {
            res.append(LineValue(price: e.price, time: Date(timeIntervalSince1970: TimeInterval(e.time))))
        }
        data = res
    }

    var body: some View {
        Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Price", point.price)
                )
            
                
            }
        }.onReceive(recentTrades.$list, perform: updateChart)
            .frame(width: 300, height: 500)
//            .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    PriceChart()
}
