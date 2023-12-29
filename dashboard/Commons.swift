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


func roundPrice(price: Double, fr: Int = 4) -> Double {
    let p = pow(Double(10), Double(fr))
    return round(p * price) / p
}
