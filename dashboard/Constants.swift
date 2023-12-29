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
    var priceFractionalPoints: Int
    var volumeFractionalPoints: Int
    var averageVolume: Double
}

enum Constants {
    static let bookDepth = 25
    static let defaultPair = "MATIC/USD"
    static let pairs = ["MATIC/USD", "ETH/USD"]
    static let pairSettings: [String: PairSettings] = [
        "MATIC/USD": PairSettings(leverage: 4, minimumOrderVolume: 100, priceFractionalPoints: 4, volumeFractionalPoints: 0, averageVolume: 10000),
        "ETH/USD": PairSettings(leverage: 5, minimumOrderVolume: 0.04, priceFractionalPoints: 2, volumeFractionalPoints: 2, averageVolume: 10)
    ]
    static let PAIRS_ISO_NAMES = [
        "MATICUSD": "MATIC/USD",
        "ETHUSD": "ETH/USD"
    ]
    static let kraken_fee = 0.02
    static let stop_loss_perc = 0.05
}
