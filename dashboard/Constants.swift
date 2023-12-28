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
    static let pairs = ["MATIC/USD", "ETH/USD"]
    static let pairSettings:[String:PairSettings] = [
        "MATIC/USD": PairSettings(leverage: 4, minimumOrderVolume: 100, numberOfFractionalPoints: 4),
        "ETH/USD": PairSettings(leverage: 5, minimumOrderVolume: 0.04, numberOfFractionalPoints: 4)
    ]
}
