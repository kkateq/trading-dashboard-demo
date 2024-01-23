//
//  PairsCardsView.swift
//  dashboard
//
//  Created by km on 23/01/2024.
//

import SwiftUI

struct PairsCardsView: View {
    var body: some View {
        VStack {
            PairAlertCard(pair: "AVAXUSDT")
            PairAlertCard(pair: "MATICUSDT")
        }
    }
}

#Preview {
    PairsCardsView()
}
