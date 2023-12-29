//
//  HomeView.swift
//  dashboard
//
//  Created by km on 19/12/2023.
//

import SwiftUI

struct PairHomeView: View {
    @State var volume: Double
    @State private var scaleInOut: Bool = true
    @State private var validate: Bool = false
    @State private var useRest: Bool = false
    @State var stopLossEnabled: Bool = true
    @State var sellStopLoss: Double!
    @State var buyStopLoss: Double!
    

    var body: some View {
        HStack {
            RecentTradesView()
            IndicatorPanView()
            OrderBookView(volume: $volume, scaleInOut: $scaleInOut, validate: $validate, useRest: $useRest, stopLossEnabled: $stopLossEnabled, sellStopLoss: $sellStopLoss, buyStopLoss: $buyStopLoss)
            OrderForm(volume: $volume, scaleInOut: $scaleInOut, validate: $validate, useRest: $useRest, stopLossEnabled: $stopLossEnabled, sellStopLoss: $sellStopLoss, buyStopLoss: $buyStopLoss)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        PairHomeView(volume: 100)
    }
}