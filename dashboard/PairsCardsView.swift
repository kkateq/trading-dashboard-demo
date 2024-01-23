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
            PairAlertWrapper(pair: "AVAXUSDT")
            
            PairAlertWrapper(pair: "MATICUSDT")
        }
    }
}

#Preview {
    PairsCardsView()
}
