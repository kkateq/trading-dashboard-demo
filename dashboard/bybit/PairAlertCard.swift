//
//  PairAlertCard.swift
//  dashboard
//
//  Created by km on 23/01/2024.
//

import SwiftUI
import SwiftySound

struct PairAlertCard: View {
    var pair: String
    @State var playAlerts: Bool = true
    @State var priceMark: String = "0"
    @State var level: PriceLevelType = .minor
    
    @EnvironmentObject var book: BybitOrderBook
    @EnvironmentObject var info: BybitInstrumentInfo
    
    @State private var selection: PairPriceLevel.ID?
    let threshhold: Double = 15
    @State var isSoundPLaying: Bool = false
//    @State var tickSize: Double = info != nil ? info.priceFilter.tickSize :0.0001

    let mySound = Sound(url: Bundle.main.url(forResource: "piano", withExtension: "mp3")!)

    @State var bestBid: Double = 0
    @State var bestAsk: Double = 0
    
//    func updateTickSize(_ i: BybitInstrumentInfo!) {
//        if let info = i {
//            self.tickSize = Double(info.priceFilter.tickSize)!
//        }
//    }
//
    func updateCurrentPrice(_ s: BybitStats!) {
        if let stats = s {
            bestAsk = stats.bestAsk
            bestBid = stats.bestBid

            let tickSize = Double(info.priceFilter.tickSize)!
            let priceBid = bestBid - threshhold * tickSize
            let levels = PriceLevelManager.shared.getLevelPrices(pair: pair)
            if let level = levels.first(where: { bestBid > $0 && $0 > priceBid }) {
                sendAlert(level: level)
            } else {
                let priceAsk = bestAsk + threshhold * tickSize
                let levels = PriceLevelManager.shared.getLevelPrices(pair: pair)
                if let level = levels.first(where: { bestAsk < $0 && $0 < priceAsk }) {
                    sendAlert(level: level)
                }
            }
        }
    }
    
    func percentFromTarget(level: String) -> String {
        let priceLevel = Double(level)!
        let peg = (bestBid + bestAsk) / 2
   
        if priceLevel > peg {
            return "-\(formatPrice(price: ((priceLevel - peg) / priceLevel) * 100, pair: pair))"
        } else {
            return "+\(formatPrice(price: ((peg - priceLevel) / priceLevel) * 100, pair: pair))"
        }
    }
    
    func playSound() {
        if !isSoundPLaying && playAlerts {
            isSoundPLaying = true
            mySound!.play { _ in
                isSoundPLaying = false
            }
        }
    }
   
    func sendAlert(level: Double) {
        playSound()
        let price = formatPrice(price: level, pair: pair)
        SlackNotification.instance.sendAlert(pair: pair, price: price, bestBid: formatPrice(price: bestBid, pair: pair), bestAsk: formatPrice(price: bestAsk, pair: pair))
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(pair).font(.title)
            }
            BybitBPS(pair: pair)
            HStack {
                Text("\(formatPrice(price: bestAsk, pair: pair))").font(.title).foregroundStyle(.red)
                Text("\(formatPrice(price: bestBid, pair: pair))").font(.title).foregroundStyle(.green)
            }
        }
        .onReceive(book.$stats, perform: updateCurrentPrice)
//        .onReceive(bybitbook_ws.$info, perform: updateTickSize)
        .padding()
    }
}

#Preview {
    PairAlertCard(pair: "AVAXUSDT")
}
