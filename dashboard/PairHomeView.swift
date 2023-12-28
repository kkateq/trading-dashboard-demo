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
    @State private var stopLoss: Bool = false
    @State private var stopLossPerc: Double = 0.05

    var body: some View {
        HStack {
            RecentTradesView()
            IndicatorPanView()
            OrderBookView(volume: $volume, scaleInOut: $scaleInOut, validate: $validate, useRest: $useRest, stopLoss: $stopLoss, stopLossPerc: $stopLossPerc)
            OrderForm(volume: $volume, scaleInOut: $scaleInOut, validate: $validate, useRest: $useRest, stopLoss: $stopLoss, stopLossPerc: $stopLossPerc)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        PairHomeView(volume: 100)
    }
}
