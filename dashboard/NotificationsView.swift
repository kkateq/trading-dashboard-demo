//
//  NotificationsView.swift
//  dashboard
//
//  Created by km on 22/01/2024.
//

import SwiftUI

struct ConfigurationView: View {
    var pair: String
    var instrumentStats: BybitInstrumentStats
    var bybittrades_ws: BybitLastTrade
    
    init(pair: String) {
        self.pair = pair
        self.instrumentStats = BybitInstrumentStats(self.pair)
        self.bybittrades_ws = BybitLastTrade(self.pair)
    }
    
    var body: some View {
        BybitPriceLevelFormView(pair: self.pair)
            .environmentObject(instrumentStats)
            .environmentObject(bybittrades_ws.recentTrades)
        
    }
}

#Preview {
    ConfigurationView(pair: "")
}
