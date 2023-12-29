//
//  IndicatorPanView.swift
//  dashboard
//
//  Created by km on 22/12/2023.
//

import SwiftUI

struct IndicatorPanView: View {

    
    var body: some View {
        VStack {
            PositionRecomendation()
            VStack {
                HStack {
                    VolumeChart()
                    Spacer()
                    RawVolumeChart()
                }
            }.frame(height: 100)
           
            ImbalanceChart()
            ImbalanceLevelsChart()
            BellCurve()
           
        }.frame(width: 720)
    }
}

#Preview {
    IndicatorPanView()
}
