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
    @EnvironmentObject var priceLevelManager: PriceLevelManager
    
    @Environment(\.managedObjectContext) var moc

    @State var tickSize: Double = 0.0001

    @State var bestBid: Double = 0
    @State var bestAsk: Double = 0

    
    func playAlert() {
        Sound.play(file: "/sounds/piano", fileExtension: "mp3", numberOfLoops: 2)
    }
    
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

//    func updateLevels(_ a: Anchor) {
//        var res: [PriceLevel] = []
//        for level in PriceLevelManager.manager.levels(pair: pair) {
//            res.append(PriceLevel(level: level))
//        }
//    }
    
    var body: some View {
        VStack {
            VStack {
                ForEach(priceLevelManager.levels) { level in
                    if level.pair! == pair {
                        HStack {
                            Text(level.price!)
                            Spacer()
                            Button(action: {
                                Task {
                                    priceLevelManager.deleteLevel(id: level.id!)
                                }
                            }) {
                                HStack {
                                    Text("Delete")
                                }
                                
                                .foregroundColor(Color.red)
                            }
                        }.frame(width: 300, height: 25)
                            .background(.white)
                    }
                }
            }.padding()
            
            HStack(alignment: .top) {
                VStack {
                    Text("Add mark:").font(.caption)
                    VStack {
                        TextField("Mark", text: $priceMark)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
    
                        Picker("", selection: $level) {
                            ForEach(PriceLevelType.allCases) { option in
                                Text(String(describing: option))
                            }
                        }.frame(width: 100)
                    }
                    
                    Button(action: {
                        Task {
                            priceLevelManager.addLevel(pair: pair, price: priceMark, type: level)
                        }
                    }) {
                        HStack {
                            Text("Add Mark")
                        }.frame(width: 50, height: 20)
                            .foregroundColor(Color.white)
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .imageScale(.medium)
                    }.buttonStyle(PlainButtonStyle())
                        .frame(width: 50, height: 20)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            Sound.stopAll()
                        }
                    }) {
                        HStack {
                            Text("Stop Alert")
                        }.frame(width: 50, height: 20)
                            .foregroundColor(Color.white)
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .imageScale(.medium)
                    }.buttonStyle(PlainButtonStyle())
                        .frame(width: 50, height: 20)
                }
            }.onReceive(instrumentStats.$info, perform: updateTickSize)
                .onReceive(instrumentStats.$stats, perform: updateCurrentPrice)
//                .onReceive(PriceLevelManager.manager.$anchor, perform: updateLevels)
           
        }.frame(width: 300)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            ).padding()
    }
}
