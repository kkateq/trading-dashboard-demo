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
    @EnvironmentObject var book: BybitOrderBook
    @State private var sortOrder = [KeyPathComparator(\PairPriceLevel.price,
                                                      order: .reverse)]
    @State private var selection: PairPriceLevel.ID?
    @State var levels: [PairPriceLevel] = []

    init(pair: String) {
        self.pair = pair
        levels = PriceLevelManager.shared.getLevels(pair: pair)
    }

    @State var bestBid: Double = 0
    @State var bestAsk: Double = 0

    func updateCurrentPrice(_ s: BybitStats!) {
        if levels.count == 0 {
            levels = PriceLevelManager.shared.getLevels(pair: pair)
        }
        if let stats = s {
            bestAsk = stats.bestAsk
            bestBid = stats.bestBid
        }
    }

    func percentFromTarget(level: String) -> (String, Double) {
        let priceLevel = Double(level)!
        let peg = (bestBid + bestAsk) / 2

        if priceLevel > peg {
            let p = ((priceLevel - peg) / priceLevel) * 100
            return ("-\(formatPrice(price: p, pair: pair))", p)
        } else {
            let p = ((peg - priceLevel) / priceLevel) * 100
            return ("+\(formatPrice(price: p, pair: pair))", p)
        }
    }

    func addLevel() {
        PriceLevelManager.shared.addLevel(pair: pair, price: priceMark, type: level)
        levels = PriceLevelManager.shared.getLevels(pair: pair)
    }

    func deleteLevel(id: UUID) {
        PriceLevelManager.shared.deleteLevel(id: id)
        levels = PriceLevelManager.shared.getLevels(pair: pair)
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(pair).font(.title)
                    }

                    HStack {
                        Text("\(formatPrice(price: bestAsk, pair: pair))").font(.title).foregroundStyle(.red)
                        Text("\(formatPrice(price: bestBid, pair: pair))").font(.title).foregroundStyle(.green)
                    }
                    Spacer()
                    HStack {
                        TextField("Mark", text: $priceMark)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100, height: 30)
                            .onSubmit {
                                if priceMark != "" {
                                    addLevel()
                                }
                            }

                        Picker("", selection: $level) {
                            ForEach(PriceLevelType.allCases) { option in
                                Text(String(describing: option))
                            }
                        }.frame(width: 100, height: 30)

                        Button(action: {
                            Task {
                                addLevel()
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
                Table(levels, selection: $selection, sortOrder: $sortOrder) {
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

                        if perc.1 < 2 {
                            Text("\(perc.0)%").foregroundStyle(perc.0.starts(with: "-") ? .red : .green)
                                .fontWeight(.bold)
                                .underline()
                        } else {
                            Text("\(perc.0)%").foregroundStyle(perc.0.starts(with: "-") ? .red : .green)
                               
                        }
                            
                    }
                    TableColumn("") { level in
                        Button(action: {
                            Task {
                                deleteLevel(id: level.id!)
                            }
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.white)
                            }.frame(width: 70, height: 30)
                        }.frame(width: 50, height: 30)
                            .foregroundColor(Color.white)
                            .background(Color("RedLight"))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .imageScale(.medium)

                            .buttonStyle(PlainButtonStyle())
                    }
                }.onDeleteCommand(perform: {
                    if let selectedId = selection {
                        deleteLevel(id: selectedId!)
                    }
                }).onChange(of: sortOrder) { newOrder in
                    levels.sort(using: newOrder)
                }

            }.padding()
                .onReceive(book.$stats, perform: updateCurrentPrice)
        }
    }
}
