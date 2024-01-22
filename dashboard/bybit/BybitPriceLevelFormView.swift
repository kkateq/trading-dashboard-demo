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
    @State var playAlerts: Bool = true
    @State var priceMark: String = "0"
    @State var level: PriceLevelType = .minor
    @State var isSoundPlaying: Bool = false
    @EnvironmentObject var instrumentStats: BybitInstrumentStats
    @EnvironmentObject var priceLevelManager: PriceLevelManager
//    var sound: Sound
    let threshhold: Double = 5
    @Environment(\.managedObjectContext) var moc
    let layout = [
        GridItem(.fixed(20), spacing: 2),
        GridItem(.fixed(70), spacing: 2),
        GridItem(.fixed(160), spacing: 2),
        GridItem(.fixed(20), spacing: 2)
    ]
    @State var tickSize: Double = 0.0001

    @State var bestBid: Double = 0
    @State var bestAsk: Double = 0
   
//    
//    init() {
////        let url = .main.url(forResource: "piano", withExtension: "mp3")
////        self.sound = Sound(url: url)
//    }

    func playAlert() {
//        if playAlerts && !isSoundPlaying {
////            isSoundPlaying = true
////            sound.play { completed in
////                isSoundPlaying = completed
////            }
//        }
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
            
            let priceBid = bestBid - threshhold * tickSize
            let levels = priceLevelManager.getLevels()
            if let f = levels.first(where: { bestBid > $0 && $0 > priceBid }) {
                playAlert()
            } else {
                let priceAsk = bestAsk + threshhold * tickSize
                let levels = priceLevelManager.getLevels()
                if let f = levels.first(where: { bestAsk < $0 && $0 < priceAsk }) {
                    playAlert()
                }
            }
        }
    }

    var body: some View {
        VStack {
            VStack {
                VStack {
                    Text(pair).font(.title)
                    Text("\(tickSize)").font(.caption)
                }
                Toggle("Play Alerts", isOn: $playAlerts)
                    .toggleStyle(.checkbox)
                LazyVGrid(columns: layout, spacing: 2) {
                    ForEach(priceLevelManager.levels) { level in
                        if level.pair! == pair {
                            VStack {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(level.color.0)
                                
                            }.frame(width: 20, height: 25, alignment: .center)
                                .background(.white)
                            
                            Text(level.price!)
                                .frame(width: 70, height: 25, alignment: .leading)
                                .background(.white)
                            Text("").frame(width: 170, height: 25, alignment: .leading)
                                .background(.white)
                            Button(action: {
                                Task {
                                    priceLevelManager.deleteLevel(id: level.id!)
                                }
                            }) {
                                VStack(alignment: .center) {
                                    Image(systemName: "x.square")
                                        .foregroundColor(Color.red)

                                }.frame(width: 20, height: 20)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .imageScale(.large)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(.white)
                        }
                    }
                }.frame(width: 280)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(.gray, lineWidth: 2)
                    )
                    .background(Color("Background"))
            }.padding()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Add price level:").font(.caption)
                    HStack {
                        TextField("Mark", text: $priceMark)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Spacer()
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
                            Text("Add level")
                        }.frame(width: 100, height: 30)
                            .foregroundColor(Color.blue)
                    }
                    .frame(width: 100, height: 30)
                   
                    Spacer()
          
                    Button(action: {
                        Task {
                            Sound.stopAll()
                        }
                    }) {
                        HStack {
                            Text("Stop Alert")
                        }.frame(width: 100, height: 30)
                            .foregroundColor(Color.black)
                    }
                    .frame(width: 100, height: 30)
                  
                }.padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(.gray, lineWidth: 2)
                    )
            }.onReceive(instrumentStats.$info, perform: updateTickSize)
                .onReceive(instrumentStats.$stats, perform: updateCurrentPrice)
           
        }.frame(width: 300)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            ).padding()
    }
}
