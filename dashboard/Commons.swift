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
    let fr =  Constants.pairSettings[pair]?.priceFractionalPoints
    let p = pow(Double(10), Double(fr!))
    return "\(round(p * price) / p)"
}

func formatVolume(price: Double, pair: String) -> String {
    let fr =  Constants.pairSettings[pair]?.volumeFractionalPoints
    let p = pow(Double(10), Double(fr!))
    return "\(round(p * price) / p)"
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
