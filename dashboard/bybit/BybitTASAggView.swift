//
//  BybitTimesAndSalesView.swift
//  dashboard
//
//  Created by km on 05/01/2024.
//

import SwiftUI

struct TASRecord: Identifiable {
    var price: String
    var volume: Double
    var time: Int
    var id: String
}

struct BybitTASAggView: View {
    var type: BybitTradeSide
    var pair: String
    @State var total: Double = 0.0
    @State var speed: Double = 0.0
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    @EnvironmentObject var priceLevelManager: PriceLevelManager
    
    @State var filterVolume: Double = 0.0
    @State var highlightVolume: Double = 50.0
    let cellWidth = 100
    let cellHeight = 20
    let layout = [
        GridItem(.fixed(120), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(50), spacing: 2)
    ]
    @State var data: [TASRecord] = []
    @State var prevData: [TASRecord] = []
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    func returnDirection(direction: String!) -> (String, Color) {
        switch direction {
        case "MinusTick":
            return ("arrow.down", .red)
            
        case "PlusTick":
            return ("arrow.up", .blue)
        default:
            return ("circle", Color("Transparent"))
        }
    }
    
    func updateData(_ d: [BybitRecentTradeRecord]) {
        let filtered = d.filter { $0.side == type }
        self.prevData = self.data
        var records: [String: TASRecord] = [:]
        
        for v in filtered {
            let key = "\(formatTimestamp(v.time, "hh:mm"))\(v.priceStr)"
            if let exb = records[key] {
                records[key] = TASRecord(price: exb.price, volume: exb.volume + v.volume, time: v.time, id: key)
            } else {
                records[key] = TASRecord(price: v.priceStr, volume: v.volume, time: v.time, id: key)
            }
        }
        let pr = records.map { $0.value }.sorted(by: { $0.time > $1.time })
        self.data = pr.filter { $0.volume > filterVolume }
        self.total = pr.reduce(0) { $0 + $1.volume }
        self.speed = self.total / Double(pr.count)
    }

    func getPrev(_ r: TASRecord) -> String {
        if let p = self.prevData.first(where: { $0.id == r.id }) {
            let diff = Int(r.volume - p.volume)
           
            if diff > 0 {
                return "+\(Int(diff))"
            }
        }
        
        return ""
    }

    func getLevel(_ p: String) -> PairPriceLevel! {
        return priceLevelManager.getLevel(price: p)
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Total \(Int(self.total))")
                    Spacer()
                    Text("Speed \(Int(self.speed))")
                }
                VStack {
                    HStack {
                        VStack {
                            Text("Filter volume").font(.caption).foregroundStyle(.gray)
                            TextField("FilterVolume", value: $filterVolume, formatter: formatter)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack {
                            Text("Highlight volume").font(.caption).foregroundStyle(.gray)
                            TextField("Volume", value: $highlightVolume, formatter: formatter)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
            }.padding()
            ScrollView {
                LazyVGrid(columns: layout, spacing: 2) {
                    ForEach(data) { record in
                        let color = type == .sell ? Color("Red") : Color("Blue")
                        let shouldHighlight = record.volume > highlightVolume
                        let bgColor = shouldHighlight ? (type == .sell ? Color("AskHover") : Color("BidHover")) : .white
                        let level = getLevel(record.price)
                        HStack {
                            Text("\(formatPrice(price: record.price, pair: pair))")
                                .foregroundStyle(color)
                            Spacer()
                            if let lv = level {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(lv.color.0)
                            }
                        }.frame(width: 120, height: 25, alignment: .leading)
                            .background(bgColor)
                        HStack {
                            Text("\(formatVolume(volume: record.volume, pair: pair))")
                                .foregroundStyle(color)
                            Spacer()
                            Text("\(getPrev(record))")
                                .foregroundStyle(.black)
                        }
                        .frame(width: 100, height: 25, alignment: .leading)
                        .background(bgColor)
                        Text("\(formatTimestamp(record.time, "hh:mm"))")
                            .frame(width: 50, height: 25, alignment: .center)
                            .foregroundStyle(color)
                            .background(bgColor)
                    }
                }
            }.onReceive(type == .sell ? recentTrades.$sells : recentTrades.$buys, perform: updateData)
        }.frame(width: 290)
            
            .background(Color("Background"))
            .font(.system(size: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            )
    }
}

#Preview {
    BybitTASAggView(type: .buy, pair: "")
}
