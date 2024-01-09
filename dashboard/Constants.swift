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

let maticSettings = PairSettings(leverage: 4, minimumOrderVolume: 100, priceFractionalPoints: 4, volumeFractionalPoints: 0, averageVolume: 10000)

enum Constants {
    static let bookDepth = 25
    static let defaultPair = "MATIC/USDT"
    static let pairs = ["MATIC/USDT", "MATIC/USD", "ETH/USD", "ADA/USD"]
    static let pairSettings: [String: PairSettings] = [
        "MATIC/USD": maticSettings,
        "MATIC/USDT": maticSettings,
        "MATICUSDT": maticSettings,
        "ETH/USD": PairSettings(leverage: 5, minimumOrderVolume: 0.04, priceFractionalPoints: 2, volumeFractionalPoints: 2, averageVolume: 10),
        "ADA/USD": PairSettings(leverage: 3, minimumOrderVolume: 100, priceFractionalPoints: 6, volumeFractionalPoints: 0, averageVolume: 100000)
    ]
    static let PAIRS_ISO_NAMES = [
        "MATICUSD": "MATIC/USD",
        "MATICUSDT": "MATIC/USDT",
        "ETHUSD": "ETH/USD",
        "ADAUSD": "ADA/USD"
    ]
    
    static let PAIRS_ISO_NAMES_REV = [
        "MATIC/USD": "MATICUSD",
        "MATIC/USDT": "MATICUSDT",
        "ETH/USD": "ETHUSD",
        "ADA/USD": "ADAUSD"
    ]
    static let kraken_fee = 0.02
    static let stop_loss_perc = 0.05
    static let bybit_fee = 0.01
}
