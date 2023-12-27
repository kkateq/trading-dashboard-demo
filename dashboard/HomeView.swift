//
//  HomeView.swift
//  dashboard
//
//  Created by km on 19/12/2023.
//

import SwiftUI

struct HomeView: View {
    @State private var volume: Double = 200
    @State private var scaleInOut: Bool = true
    @State private var validate: Bool = true
    @State private var useRest: Bool = false
    
    var body: some View {
        HStack {
            RecentTradesView()

            OrderBookView(volume: $volume, scaleInOut: $scaleInOut, validate: $validate, useRest: $useRest)

            IndicatorPanView()

            OrderForm(volume: $volume, scaleInOut: $scaleInOut, validate: $validate, useRest: $useRest)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
