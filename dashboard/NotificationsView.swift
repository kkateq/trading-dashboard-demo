//
//  NotificationsView.swift
//  dashboard
//
//  Created by km on 22/01/2024.
//

import SwiftUI

struct NotificationsView: View {
    var pair: String
    var priceLevelManager: PriceLevelManager
    var instrumentStats: BybitInstrumentStats

    
    init(pair: String) {
        self.pair = pair
        self.instrumentStats = BybitInstrumentStats(self.pair)
        self.priceLevelManager = PriceLevelManager(self.pair)
    }
    
    var body: some View {
        BybitPriceLevelFormView(pair: self.pair)
            .environmentObject(instrumentStats)
            .environmentObject(priceLevelManager)
        
    }
}

#Preview {
    NotificationsView(pair: "")
}
