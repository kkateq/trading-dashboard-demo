//
//  BybitTickerStats.swift
//  dashboard
//
//  Created by km on 15/01/2024.
//

import SwiftUI

struct BybitTickerStats: View {
    var pair: String
    var bybitTickerStats: BybitInstrumentStats
    
    init(pair: String) {
        self.pair = pair
        self.bybitTickerStats = BybitInstrumentStats(pair: pair)
    }

    
    
    var body: some View {
        VStack {
            if let node = bybitTickerStats.lastNode {
                Text(node.data.tickDirection)
            }
        }
    }
}

#Preview {
    BybitTickerStats(pair: "")
}
