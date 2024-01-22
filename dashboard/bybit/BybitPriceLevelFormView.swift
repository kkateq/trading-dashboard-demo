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
    @State private var selection: PairPriceLevel.ID?
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
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(pair).font(.title)
                        Text("\(tickSize)").font(.caption)
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
                                priceLevelManager.addLevel(pair: pair, price: priceMark, type: level)
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
                Table(priceLevelManager.levels, selection: $selection) {
                    TableColumn("Type") { level in
                        Image(systemName: "circle.fill")
                            .foregroundColor(level.color.0)
                    }
                    TableColumn("Price") { level in
                        Text("\((level.price != nil) ? level.price! : "")")
                    }
                    TableColumn("Note") { level in
                        Text("\((level.note != nil) ? level.note! : "")")
                    }
                }.onDeleteCommand(perform: {
                    if let selectedId = selection {
                        priceLevelManager.deleteLevel(id: selectedId!)
                    }
                })
                
                HStack {
                    Toggle("Play Alerts", isOn: $playAlerts)
                        .toggleStyle(.checkbox)
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
                }
                
            }.padding()
            
            VStack(alignment: .leading) {}.onReceive(instrumentStats.$info, perform: updateTickSize)
                .onReceive(instrumentStats.$stats, perform: updateCurrentPrice)
                .padding()
        }
    }
}
