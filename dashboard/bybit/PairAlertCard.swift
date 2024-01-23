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
    var instrumentStats: BybitInstrumentStats
    @State private var selection: PairPriceLevel.ID?
    let threshhold: Double = 15
    @State var isSoundPLaying: Bool = false
    @Environment(\.managedObjectContext) var moc
    let mySound = Sound(url: Bundle.main.url(forResource: "piano", withExtension: "mp3")!)
    @State var tickSize: Double = 0.0001

    @State var bestBid: Double = 0
    @State var bestAsk: Double = 0
    
    init(_ pair: String) {
        self.pair = pair
        self.instrumentStats = BybitInstrumentStats(self.pair)
 
    }
    
    func updateCurrentPrice(_ p: BybitTickerData!) {
        if let pricing = p {
            bestAsk = Double(pricing.ask1Price)!
            bestBid = Double(pricing.bid1Price)!
            
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
            mySound!.play { completed in
                isSoundPLaying = false
            }
        }
    }
   
    func sendAlert(level: Double) {
        playSound()
        let price = formatPrice(price: level, pair: pair)
        SlackNotification.instance.sendAlert(pair: pair, price: price, bestBid: formatPrice(price: bestBid, pair: pair), bestAsk: formatPrice(price: bestAsk, pair: pair))
    }
    
    func updateTickSize(_ info: BybitInstrumentInfo!) {
        if let i = info {
            tickSize = Double(i.priceFilter.tickSize)!
        }
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(pair).font(.title)
                Text("\(tickSize)").font(.caption)
            }
            BybitBPS(pair: pair)
            HStack {
                Text("\(formatPrice(price: bestAsk, pair: pair))").font(.title).foregroundStyle(.red)
                Text("\(formatPrice(price: bestBid, pair: pair))").font(.title).foregroundStyle(.green)
            }
        } .onReceive(instrumentStats.$info, perform: updateTickSize)
            .onReceive(instrumentStats.$stats, perform: updateCurrentPrice)
    }
}

#Preview {
    PairAlertCard("AVAXUSDT")
}
