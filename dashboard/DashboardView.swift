//
//  BinanceDashboardView.swift
//  dashboard
//
//  Created by km on 03/01/2024.
//

import SwiftUI

struct DashboardView: View {
    var pair: String

    init(pair: String) {
        self.pair = pair
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(pair)
                    Spacer()
                }.padding([.top], 5)
            }
           

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    PairHomeView(pair: self.pair)
                }
            }
        }
        .frame(minWidth: 1200, maxWidth: .infinity, minHeight: 1000, maxHeight: .infinity, alignment: .leading)
        .padding([.top, .bottom, .leading, .trailing], 2)
    }
}

#Preview {
    DashboardView(pair: "MATICUSDT")
}
