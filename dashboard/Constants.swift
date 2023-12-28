//
//  Constants.swift
//  dashboard
//
//  Created by km on 28/12/2023.
//

import Foundation

struct PairSettings {
    var leverage: Int
    var minimumOrderVolume: Double
    var numberOfFractionalPoints: Int
}

enum Constants {
    static let bookDepth = 25
    static let defaultPair = "MATIC/USD"
    static let pairs = ["MATIC/USD", "ETH/USD"]
    static let pairSettings: [String: PairSettings] = [
        "MATIC/USD": PairSettings(leverage: 4, minimumOrderVolume: 100, numberOfFractionalPoints: 4),
        "ETH/USD": PairSettings(leverage: 5, minimumOrderVolume: 0.04, numberOfFractionalPoints: 4)
    ]
    static let PAIRS_ISO_NAMES = [
        "MATICUSD": "MATIC/USD",
        "ETHUSD": "ETH/USD"
    ]
    static let kraken_fee = 0.02
    static let stop_loss_perc = 0.05
}
