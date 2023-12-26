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

            ImbalanceChart2()

            VStack {
                VolumeChart()
            }.frame(height: 200)

        }.frame(width: 720)
    }
}

#Preview {
    IndicatorPanView()
}
