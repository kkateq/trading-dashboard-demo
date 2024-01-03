//
//  BinanceDashboardView.swift
//  dashboard
//
//  Created by km on 03/01/2024.
//

import SwiftUI

struct DashboardView: View {
    var pair: String
    var depth: Int = 25
    var binance_ws: Binancebook
    @State var isReady: Bool = false

    func setReady(_ publishedBook: BinanceOrderBook!) {
        if !isReady && publishedBook != nil {
            isReady = true
        }
    }
    
    init(pair: String) {
        self.pair = pair

        self.binance_ws = Binancebook(Constants.PAIRS_ISO_NAMES_REV[pair]!, depth)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .top)  {
                    Text(pair)
                    Spacer()
                    Text("\(depth)")
                }.padding([.top], 5)
            }
            Divider()
               
            if isReady {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        PairHomeView(volume: Constants.pairSettings[pair]!.minimumOrderVolume)
                            .environmentObject(binance_ws.book)
                    }
                }
            } else {
                VStack {
                    Text("Connecting ... ").font(.title).foregroundStyle(.blue)
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
