//
//  BinanceDashboardView.swift
//  dashboard
//
//  Created by km on 03/01/2024.
//

import SwiftUI

struct DashboardView: View {
    var pair: String
    var binance_ws: Binancebook
    @State var isReady: Bool = false

    
    func setReady(_ publishedBook: BinanceOrderBook!) -> Void {
        if !isReady && publishedBook != nil {
            isReady = true
        }
    }
    
    init(pair: String) {
        self.pair = pair

        self.binance_ws = Binancebook("MATICUSDT", 25)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                HStack {
                    if isReady {
                        PairHomeView(volume: Constants.pairSettings[pair]!.minimumOrderVolume)
                            .environmentObject(binance_ws.book)

                    } else {
                        VStack {
                            Text("Connecting ... ").font(.title).foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 1200, maxWidth: .infinity, minHeight: 1000, maxHeight: .infinity, alignment: .leading)
        .padding([.top, .bottom, .leading, .trailing], 2)
        .onReceive(binance_ws.$book) { setReady($0) }
    }
}

#Preview {
    DashboardView(pair: "MATICUSDT")
}
