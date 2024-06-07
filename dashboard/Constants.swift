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
    var highlightVolume: Double
    var priceThreshholdPercent: Double
    var imageLink: String
}

let maticSettings = PairSettings(leverage: 4, minimumOrderVolume: 100, priceFractionalPoints: 4, volumeFractionalPoints: 0, averageVolume: 10000, highlightVolume: 100, priceThreshholdPercent: 2, imageLink: "https://s2.coinmarketcap.com/static/img/coins/64x64/3890.png")
let avaxSettings = PairSettings(leverage: 4, minimumOrderVolume: 5, priceFractionalPoints: 3, volumeFractionalPoints: 1, averageVolume: 10000, highlightVolume: 100, priceThreshholdPercent: 2, imageLink: "https://s2.coinmarketcap.com/static/img/coins/64x64/5805.png")
let aptSettings = PairSettings(leverage: 3, minimumOrderVolume: 5, priceFractionalPoints: 4, volumeFractionalPoints: 0, averageVolume: 10000, highlightVolume: 100, priceThreshholdPercent: 2, imageLink: "https://s2.coinmarketcap.com/static/img/coins/64x64/21794.png")

let adaSettings = PairSettings(leverage: 3, minimumOrderVolume: 100, priceFractionalPoints: 6, volumeFractionalPoints: 0, averageVolume: 100000, highlightVolume: 5000, priceThreshholdPercent: 2, imageLink: "https://s2.coinmarketcap.com/static/img/coins/64x64/2010.png")

let manaSettings = PairSettings(leverage: 4, minimumOrderVolume: 10, priceFractionalPoints: 4, volumeFractionalPoints: 0, averageVolume: 10000, highlightVolume: 100, priceThreshholdPercent: 2, imageLink: "https://s2.coinmarketcap.com/static/img/coins/64x64/1966.png")

let ethSettings = PairSettings(leverage: 5, minimumOrderVolume: 0.04, priceFractionalPoints: 2, volumeFractionalPoints: 2, averageVolume: 10, highlightVolume: 10, priceThreshholdPercent: 1, imageLink: "https://s2.coinmarketcap.com/static/img/coins/64x64/1966.png")

let solSettings = PairSettings(leverage: 5, minimumOrderVolume: 2, priceFractionalPoints: 3, volumeFractionalPoints: 1, averageVolume: 10, highlightVolume: 50, priceThreshholdPercent: 1, imageLink: "https://s2.coinmarketcap.com/static/img/coins/64x64/5426.png")


enum Constants {
    static let bookDepth = 25
    static let defaultPair = "MATIC/USDT"
    static let pairs = ["AVAX/USDT", "APT/USDT", "MATIC/USDT", "MANA/USDT", "ETH/USDT", "ADA/USDT", "SILLY/USDT", "SOL/USDT"]
    static let pairSettings: [String: PairSettings] = [
        "MANA/USDT" :manaSettings,
        "MANAUSDT" :manaSettings,
        
        "MATIC/USDT": maticSettings,
        "MATICUSDT": maticSettings,
        
        "ETH/USDT": ethSettings,
        "ETHUSDT": ethSettings,
        
        "ADA/USDT": adaSettings,
        "ADAUSDT":adaSettings,
        
        "AVAXUSDT": avaxSettings,
        "AVAX/USDT": avaxSettings,
        
        "APT/USDT" : aptSettings,
        "APTUSDT": aptSettings,
        
        
        "SOL/USDT": solSettings,
        "SOLUSDT": solSettings
    ]
    static let PAIRS_ISO_NAMES = [
        "MATICUSD": "MATIC/USD",
        "MATICUSDT": "MATIC/USDT",
        "ETHUSDT": "ETH/USDT",
        "AVAXUSDT": "AVAX/USDT",
        "ADAUSDT": "ADA/USDT",
        "APTUSDT": "APT/USDT",

        "SOLUSDT": "SOL/USDT"
    ]
    
    static let PAIRS_ISO_NAMES_REV = [
        "MATIC/USDT": "MATICUSDT",
        "MANA/USDT": "MANAUSDT",
        "ETH/USDT": "ETHUSDT",
        "ADA/USDT": "ADAUSDT",
        "AVAX/USDT": "AVAXUSDT",
        "APT/USDT" : "APTUSDT",
  
        "SOL/USDT": "SOLUSDT"
    ]
    static let kraken_fee = 0.02
    static let stop_loss_perc = 0.05
    static let bybit_fee = 0.02
    
   
}
