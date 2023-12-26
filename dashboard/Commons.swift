//
//  Commons.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import Foundation


func formatPrice(price: Double) -> String {
    return "\(round(10000 * price) / 10000)"
}
