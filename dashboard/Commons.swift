//
//  Commons.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import CryptoSwift
import Foundation

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

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
    if fr == 0 {
        return "\(Int(round(volume)))"
    } else {
        let p = pow(Double(10), Double(fr))
        return "\(round(p * volume) / p)"
    }
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

func formatTimestamp(_ ts: Int, _ dataFormat: String = "MMM dd YYYY hh:mm a") -> String {
    let date = NSDate(timeIntervalSince1970: TimeInterval(ts / 1000))

    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = dataFormat

    return dayTimePeriodFormatter.string(from: date as Date)
}

func getDate(timestamp: Int) -> Date {
    return Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
}

func generateSignature(api_secret: String, value: String) -> String {
    let inputData = Data(value.utf8)
    let hash = try? HMAC(key: api_secret, variant: .sha2(.sha256)).authenticate(Array(inputData))
    return hash?.toHexString() ?? ""
}

func formatDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    return formatter.string(from: date)
}
