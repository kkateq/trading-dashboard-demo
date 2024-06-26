//
//  PriceChartView.swift
//  dashboard
//
//  Created by km on 20/12/2023.
//

import Charts
import SwiftUI

struct Candle: Hashable {
    let open: Double
    let close: Double
    let low: Double
    let high: Double
}

struct CandlestickMark<X: Plottable, Y: Plottable>: ChartContent {
    let x: PlottableValue<X>
    let low: PlottableValue<Y>
    let high: PlottableValue<Y>
    let open: PlottableValue<Y>
    let close: PlottableValue<Y>

    init(
        x: PlottableValue<X>,
        low: PlottableValue<Y>,
        high: PlottableValue<Y>,
        open: PlottableValue<Y>,
        close: PlottableValue<Y>
    ) {
        self.x = x
        self.low = low
        self.high = high
        self.open = open
        self.close = close
    }

    var body: some ChartContent {
        RectangleMark(x: x, yStart: low, yEnd: high, width: 1)
            .foregroundStyle(.red)
        RectangleMark(x: x, yStart: open, yEnd: close, width: 16)
            .foregroundStyle(.red)
    }
}

struct PriceChartView: View {
    var service = KrakenOHLC("MATIC/USD", Kraken.OHLCInterval.i1min)

    let candles: [Candle] = [
        .init(open: 3, close: 6, low: 1, high: 8),
        .init(open: 4, close: 7, low: 2, high: 9),
        .init(open: 5, close: 8, low: 3, high: 10)
    ]

    var body: some View {
//        if let list = service.nodes {
//            Chart {
//                ForEach(list) { node in
//                    CandlestickMark(
//                        x: .value("index", node.time),
//                        low: .value("low", node.low),
//                        high: .value("high", node.high),
//                        open: .value("open", node.open),
//                        close: .value("close", node.close)
//                    )
//                    .foregroundStyle(.green)
//                }
//            }
//        }
//        else {
            Text("No data")
//        }
    }
}

struct PriceChartView_Previews: PreviewProvider {
    static var previews: some View {
        PriceChartView()
    }
}
