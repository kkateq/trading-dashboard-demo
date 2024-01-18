//
//  BybitStats.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import Charts
import Foundation

struct BybitStats {
    var pair: String
    var totalBidVol: Double = 0
    var totalAskVol: Double = 0

    var bestBid: Double = 0
    var bestAsk: Double = 0
    var bestBidVolume: Double = 0
    var bestAskVolume: Double = 0
    var maxVolume: Double = 0
    var time: Date

    var all: [Double: BybitBookRecord]
    var bid_keys = [Double]()
    var ask_keys = [Double]()
    var isUp: Bool = true

    init(pair: String, all: [Double: BybitBookRecord], bid_keys: [Double], ask_keys: [Double]) {
        time = Date()
        self.pair = pair
        self.all = all
        self.bid_keys = bid_keys
        self.ask_keys = ask_keys
        let ask_volumes = ask_keys.map { all[$0]!.vol }

        totalAskVol = getAskVolume()
        totalBidVol = getBidVolume()

        bestBid = bid_keys.count > 0 ? all[bid_keys[0]]!.pr : 0.0
        bestAsk = ask_keys.count > 0 ? all[ask_keys[0]]!.pr : 0.0
        bestBidVolume = bid_keys.count > 0 ? all[bid_keys[0]]!.vol : 0.0
        bestAskVolume = ask_keys.count > 0 ? all[ask_keys[0]]!.vol : 0.0

        maxVolume = all.values.max(by: { $0.vol < $1.vol })!.vol
    }

    func getBidVolume(levels: Int = 0) -> Double {
        if levels == 0 {
            return bid_keys.reduce(0) { $0 + all[$1]!.vol }
        }
        return bid_keys.prefix(levels).reduce(0) { $0 + all[$1]!.vol }
    }

    private func getAskVolume(levels: Int = 0) -> Double {
        if levels == 0 {
            return ask_keys.reduce(0) { $0 + all[$1]!.vol }
        }
        return ask_keys.prefix(levels).reduce(0) { $0 + all[$1]!.vol }
    }

    var pegValue: Double {
        return (bestBid + bestAsk) / 2
    }

    var totalAskVolumePerc: Double {
        return round((totalAskVol / (totalAskVol + totalBidVol)) * 100)
    }

    var totalBidVolumePerc: Double {
        return round((totalBidVol / (totalAskVol + totalBidVol)) * 100)
    }
}
