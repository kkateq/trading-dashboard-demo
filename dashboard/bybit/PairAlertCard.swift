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
    @State var isAlerting: Bool = true
    @State var priceMark: String = "0"
    @State var level: PriceLevelType = .minor
    @EnvironmentObject var book: BybitOrderBook
    @EnvironmentObject var info: BybitInstrumentInfo
    @State var closestLevel: PairPriceLevel! = nil
    @State private var selection: PairPriceLevel.ID?

    @State var levels: [PairPriceLevel] = []
    @State var bestBid: Double = 0
    @State var bestAsk: Double = 0

    func updateCurrentPrice(_ s: BybitStats!) {
        if let stats = s {
            bestAsk = stats.bestAsk
            bestBid = stats.bestBid

            if let level = PriceLevelManager.shared.getLevels(pair: pair).first(where: { checkPrice(price: $0.price!, bestBid: bestBid, bestAsk: bestAsk) == true }) {
                closestLevel = level
                sendAlert(level: level)
            } else {
                isAlerting = false
                closestLevel = nil
            }
        }
    }

    func checkPrice(price: String, bestBid: Double, bestAsk: Double) -> Bool {
        let priceLevel = Double(price)!
        let peg = (bestBid + bestAsk) / 2
        let delta = abs(((priceLevel - peg) / priceLevel) * 100)
        return delta < Constants.pairSettings[pair]!.priceThreshholdPercent
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
        SoundHandler.shared.playSound()
    }

    func intervalSince(_ previous: Date, isMoreThan minutes: Int) -> Bool {
        return Date() > previous.advanced(by: Double(minutes) * 60.0)
    }

    func sendAlert(level: PairPriceLevel) {
        if level.lastAlertTime == nil || intervalSince(level.lastAlertTime!, isMoreThan: 5) {
            playSound()

            SlackNotification.instance.sendAlert(pair: pair, price: level.price!, bestBid: formatPrice(price: bestBid, pair: pair), bestAsk: formatPrice(price: bestAsk, pair: pair))
            isAlerting = true
            PriceLevelManager.shared.updateAlertTime(id: level.id!)
        }
    }

    var body: some View {
        HStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 5) {
                
                VStack(alignment: .leading) {
                    if let cl = self.closestLevel {
                        HStack {
                            Text("Closest level").font(.caption)
                            Text(cl.price!).font(.subheadline)
                        }
                    } else {
                        Text("No alerts")
                    }
                    
                }
                HStack {
                    
                    VStack(alignment: .leading) {
                        Text(pair).font(.title).foregroundStyle(Color("BidTextColor"))
                    }
                    HStack {
                        Text("\(formatPrice(price: bestAsk, pair: pair))").font(.title).foregroundStyle(.red)
                        Text("\(formatPrice(price: bestBid, pair: pair))").font(.title).foregroundStyle(.green)
                    }
                }
                
                BybitBPS(pair: pair)
            }
        }
        .frame(width: 300, height: 200)
        .padding()
        .onReceive(book.$stats, perform: updateCurrentPrice)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(isAlerting ? Color("Alert") : .gray, lineWidth: 4)
        )
        .padding()
    }
}

#Preview {
    PairAlertCard(pair: "AVAXUSDT")
}
