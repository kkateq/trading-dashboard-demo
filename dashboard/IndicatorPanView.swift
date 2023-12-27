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
            ImbalanceChart()

            PegImbalanceChart()
            ImbalanceLevel5Chart()
            ImbalanceLevel10Chart()
            VStack {
                VolumeChart()
            }.frame(height: 100)

        }.frame(width: 720)
    }
}

#Preview {
    IndicatorPanView()
}
