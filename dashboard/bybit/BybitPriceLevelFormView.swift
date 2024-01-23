//
//  BybitPriceLevelFormView.swift
//  dashboard
//
//  Created by km on 17/01/2024.
//

import SwiftUI
import SwiftySound

struct BybitPriceLevelFormView: View {
    var pair: String
    @State var priceMark: String = "0"
    @State var level: PriceLevelType = .minor
    @EnvironmentObject var instrumentStats: BybitInstrumentStats

    @State private var selection: PairPriceLevel.ID?

    @State var tickSize: Double = 0.0001

    @State var bestBid: Double = 0
    @State var bestAsk: Double = 0

    func updateTickSize(_ info: BybitInstrumentInfo!) {
        if let i = info {
            tickSize = Double(i.priceFilter.tickSize)!
        }
    }

    func updateCurrentPrice(_ p: BybitTickerData!) {
        if let pricing = p {
            bestAsk = Double(pricing.ask1Price)!
            bestBid = Double(pricing.bid1Price)!
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

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(pair).font(.title)
                        Text("\(tickSize)").font(.caption)
                    }
                    BybitBPS(pair: pair)
                    HStack {
                        Text("\(formatPrice(price: bestAsk, pair: pair))").font(.title).foregroundStyle(.red)
                        Text("\(formatPrice(price: bestBid, pair: pair))").font(.title).foregroundStyle(.green)
                    }
                    Spacer()
                    HStack {
                        TextField("Mark", text: $priceMark)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100, height: 30)

                        Picker("", selection: $level) {
                            ForEach(PriceLevelType.allCases) { option in
                                Text(String(describing: option))
                            }
                        }.frame(width: 100, height: 30)

                        Button(action: {
                            Task {
                                PriceLevelManager.shared.addLevel(pair: pair, price: priceMark, type: level)
                            }
                        }) {
                            HStack {
                                Text("Add level")
                            }.frame(width: 100, height: 30)
                                .foregroundColor(Color.blue)
                        }
                        .frame(width: 100, height: 30)
                        .padding([.leading], 10)
                    }
                }
                Table(PriceLevelManager.shared.getLevels(pair: pair), selection: $selection) {
                    TableColumn("Type") { level in
                        Image(systemName: "circle.fill")
                            .foregroundColor(level.color.0)
                    }
                    TableColumn("Price") { level in
                        Text("\((level.price != nil) ? level.price! : "")")
                    }
                    TableColumn("Created") { level in
                        Text(level.added!, style: .date)
                    }
                    TableColumn("Note") { level in
                        let perc = percentFromTarget(level: level.price!)
                        Text("\(perc)%").foregroundStyle(perc.starts(with: "-") ? .red : .green)
                    }
                }.onDeleteCommand(perform: {
                    if let selectedId = selection {
                        PriceLevelManager.shared.deleteLevel(id: selectedId!)
                    }
                })

            }.padding()
                .onReceive(instrumentStats.$info, perform: updateTickSize)
                .onReceive(instrumentStats.$stats, perform: updateCurrentPrice)
        }
    }
}
