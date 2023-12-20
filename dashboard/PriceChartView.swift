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

struct PriceChartView: View {
    let candles: [Candle] = [
        .init(open: 3, close: 6, low: 1, high: 8),
        .init(open: 4, close: 7, low: 2, high: 9),
        .init(open: 5, close: 8, low: 3, high: 10)
    ]

    var body: some View {
        Chart {
            ForEach(Array(zip(candles.indices, candles)), id: \.1) { index, candle in
                RectangleMark(
                    x: .value("index", index),
                    yStart: .value("low", candle.low),
                    yEnd: .value("high", candle.high),
                    width: 4
                )

                RectangleMark(
                    x: .value("index", index),
                    yStart: .value("open", candle.open),
                    yEnd: .value("close", candle.close),
                    width: 16
                )
                .foregroundStyle(.red)
            }
        }
    }
}

struct PriceChartView_Previews: PreviewProvider {
    static var previews: some View {
        PriceChartView()
    }
}
