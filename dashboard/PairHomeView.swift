//
//  HomeView.swift
//  dashboard
//
//  Created by km on 19/12/2023.
//

import SwiftUI

struct PairHomeView: View {
    var pair: String

    var body: some View {
        VStack {
            HStack {
//                VStack {
//                    BinancePairView(pair: self.pair)
//                }
//                KrakenPairView(pair: self.pair)
                VStack {
                    BybitPairView(pair: Constants.PAIRS_ISO_NAMES_REV[self.pair]!)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        PairHomeView(pair: "")
    }
}
