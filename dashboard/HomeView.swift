//
//  HomeView.swift
//  dashboard
//
//  Created by km on 19/12/2023.
//

import SwiftUI

struct HomeView: View {
    @State private var volume: Double = 10
    @State private var scaleInOut: Bool = true
    @State private var validate: Bool = true
    @State private var useRest: Bool = false
    @State private var leverage: Int = 4

    var body: some View {
        HStack {
            IndicatorPanView()
                .frame(width: 400)
            HStack {
                
                ZStack {
                    HStack {
                        
                        OrderBookView(volume: $volume, scaleInOut: $scaleInOut, validate: $validate, useRest: $useRest, leverage: $leverage)
                        VStack {
                            VolumeProfileChart()
                        }
                    }
                    GridOverlay()
                }
               
                
            }.frame(width: 950)
            OrderForm(volume: $volume, scaleInOut: $scaleInOut, validate: $validate, useRest: $useRest, leverage: $leverage)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
