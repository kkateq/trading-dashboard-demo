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
            HStack {
                ImbalanceChart()
            }
            ImbalanceChart2()
        }.frame(width: 720)
    }
}

#Preview {
    IndicatorPanView()
}
