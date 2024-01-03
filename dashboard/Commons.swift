//
//  Commons.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import Foundation

func formatPrice(price: Double, fr: Int = 4) -> String {
    let p = pow(Double(10), Double(fr))
    return "\(round(p * price) / p)"
}

func formatPrice(price: Double, pair: String) -> String {
    let settings = Constants.pairSettings[pair] ?? Constants.pairSettings[Constants.PAIRS_ISO_NAMES[pair]!]
    let fr = settings?.priceFractionalPoints
    let p = pow(Double(10), Double(fr!))
    return "\(round(p * price) / p)"
}

func formatVolume(volume: Double, pair: String) -> String {
    let settings = Constants.pairSettings[pair] ?? Constants.pairSettings[Constants.PAIRS_ISO_NAMES[pair]!]
    let fr = settings!.volumeFractionalPoints
    let p = pow(Double(10), Double(fr))
    return "\(round(p * volume) / p)"
}

func formatPrice(price: String, pair: String) -> String {
    let pr = Double(price)
    return formatPrice(price: pr!, pair: pair)
}

func formatVolume(volume: String, pair: String) -> String {
    let vol = Double(volume)
    return formatVolume(volume: vol!, pair: pair)
}

func roundPrice(price: Double, fr: Int = 4) -> Double {
    let p = pow(Double(10), Double(fr))
    return round(p * price) / p
}

func roundPrice(price: Double, pair: String) -> Double {
    let fr = Constants.pairSettings[pair]?.priceFractionalPoints
    let p = pow(Double(10), Double(fr!))
    return round(p * price) / p
}
