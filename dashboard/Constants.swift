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
let avaxSettings = PairSettings(leverage: 4, minimumOrderVolume: 5, priceFractionalPoints: 3, volumeFractionalPoints: 1, averageVolume: 10000)
let aptSettings = PairSettings(leverage: 3, minimumOrderVolume: 5, priceFractionalPoints: 4, volumeFractionalPoints: 0, averageVolume: 10000)

enum Constants {
    static let bookDepth = 25
    static let defaultPair = "MATIC/USDT"
    static let pairs = ["AVAX/USDT", "APT/USDT", "MATIC/USDT", "MANA/USDT", "ETH/USDT", "ADA/USDT"]
    static let pairSettings: [String: PairSettings] = [
        "MANA/USDT" :PairSettings(leverage: 4, minimumOrderVolume: 10, priceFractionalPoints: 4, volumeFractionalPoints: 0, averageVolume: 10000),
        "MANAUSDT" :PairSettings(leverage: 4, minimumOrderVolume: 10, priceFractionalPoints: 4, volumeFractionalPoints: 0, averageVolume: 10000),
        "MATIC/USDT": maticSettings,
        "MATICUSDT": maticSettings,
        "ETH/USDT": PairSettings(leverage: 5, minimumOrderVolume: 0.04, priceFractionalPoints: 2, volumeFractionalPoints: 2, averageVolume: 10),
        "ADA/USDT": PairSettings(leverage: 3, minimumOrderVolume: 100, priceFractionalPoints: 6, volumeFractionalPoints: 0, averageVolume: 100000),
        "AVAXUSDT": avaxSettings,
        "AVAX/USDT": avaxSettings,
        "APT/USDT" : aptSettings,
        "APTUSDT": aptSettings
    ]
    static let PAIRS_ISO_NAMES = [
        "MATICUSD": "MATIC/USD",
        "MATICUSDT": "MATIC/USDT",
        "ETHUSDT": "ETH/USDT",
        "AVAXUSDT": "AVAX/USDT",
        "ADAUSDT": "ADA/USDT",
        "APTUSDT": "APT/USDT"
    ]
    
    static let PAIRS_ISO_NAMES_REV = [
        "MATIC/USDT": "MATICUSDT",
        "MANA/USDT": "MANAUSDT",
        "ETH/USDT": "ETHUSDT",
        "ADA/USDT": "ADAUSDT",
        "AVAX/USDT": "AVAXUSDT",
        "APT/USDT" : "APTUSDT"
    ]
    static let kraken_fee = 0.02
    static let stop_loss_perc = 0.05
    static let bybit_fee = 0.02
}
