//
//  BybitPairView.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import SwiftUI

struct BybitPairView: View {
    var pair: String
    var bybitbook_ws: Bybitbook
    var bybittrades_ws: BybitLastTrade
    var manager: BybitPrivateManager
    @State private var volume: Double
    @State private var scaleInOut: Bool = false
    @State var stopLossEnabled: Bool = false
    @State var sellStopLoss: Double!
    @State var buyStopLoss: Double!
    @State var takeProfitEnabled: Bool = false
    @State var sellTakeProfit: Double!
    @State var buyTakeProfit: Double!
    @State var isBookSocketReady: Bool = false
    @State var isTradesSocketReady: Bool = false
    
    init(pair: String) {
        self.pair = pair
        self.bybitbook_ws = Bybitbook(self.pair)
        self.bybittrades_ws = BybitLastTrade(self.pair)
        self.manager = BybitPrivateManager(self.pair)
        self.volume = Constants.pairSettings[pair]!.minimumOrderVolume
    }
    
    func setBookReady(_ publishedBook: BybitOrderBook!) {
        if !isBookSocketReady && publishedBook != nil {
            isBookSocketReady = true
        }
    }
    
    func setTradesReady(_ publishedBook: BybitRecentTradeData!) {
        if !isTradesSocketReady && publishedBook != nil {
            isTradesSocketReady = true
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if isBookSocketReady && isTradesSocketReady {
                HStack {
                    BybitTimesAndSalesView()
                    BybitOrderBookView(volume: $volume, scaleInOut: $scaleInOut, stopLossEnabled: $stopLossEnabled, takeProfitEnabled: $takeProfitEnabled, sellStopLoss: $sellStopLoss, buyStopLoss: $buyStopLoss, sellTakeProfit: $sellTakeProfit, buyTakeProfit: $buyTakeProfit)
                        
                    BybitPriceVolumeChart()
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                Text(pair)
                                Spacer()
                            }.padding([.top], 5)
                        }
                        VStack {
                            HStack {
                                BybitRawVolumeChart()
                                BybitFilteredVolumeChart()
                            }
//                            BybitBellCurve()
//                            BybitTickerStats(pair: pair)
//                            BuySellTransactionsChart()
//                            BybitImbalanceChart()
                            BybitVolumeChart()
                        }
                        Spacer()
                    }
            
                    BybitOrderFormView(volume: $volume, scaleInOut: $scaleInOut, stopLossEnabled: $stopLossEnabled, takeProfitEnabled: $takeProfitEnabled, sellStopLoss: $sellStopLoss, buyStopLoss: $buyStopLoss, sellTakeProfit: $sellTakeProfit, buyTakeProfit: $buyTakeProfit)
                
                }.environmentObject(bybittrades_ws.recentTrades)
                    .environmentObject(bybitbook_ws.book)
                    .environmentObject(manager)
                
            } else {
                Text("Connecting...")
                    .font(.title3).foregroundStyle(.blue)
            }
        }.onReceive(bybitbook_ws.$book, perform: setBookReady)
            .onReceive(bybittrades_ws.$recentTrades, perform: setTradesReady)
    }
}

#Preview {
    BybitPairView(pair: "test")
}
