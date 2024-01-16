//
//  BybitTimesAndSalesView.swift
//  dashboard
//
//  Created by km on 05/01/2024.
//

import SwiftUI

struct BybitTimesAndSalesView: View {
    @EnvironmentObject var recentTrades: BybitRecentTradeData
    @State var filterVolume: Double = 10.0
    @State var highlightVolume: Double = 50.0
    let cellWidth = 100
    let cellHeight = 20
    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(30), spacing: 2),
        GridItem(.fixed(50), spacing: 2),
//        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(50), spacing: 2)
    ]
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    func returnDirection(direction: String!) -> (String, Color) {
        switch direction {
        case "MinusTick" :
            return ("arrow.down", .red)
            
        case "PlusTick":
            return ("arrow.up", .blue)
        default:
            return("circle", Color("Transparent"))
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    VStack {
                        Text("Filter volume").font(.caption)
                        TextField("FilterVolume", value: $filterVolume, formatter: formatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    VStack {
                        Text("Highlight volume").font(.caption)
                        TextField("Volume", value: $highlightVolume, formatter: formatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                Button(action: {
                    Task {
                        recentTrades.clean()
                    }
                }) {
                    HStack {
                        Text("Clear recent")
                    }.frame(width: 200, height: 30)
                        .foregroundColor(Color.white)
                        .background(Color.teal)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .imageScale(.large)
                }.buttonStyle(PlainButtonStyle())
            }
            ScrollView {
                LazyVGrid(columns: layout, spacing: 2) {
                    let records = recentTrades.list.filter {$0.volume > filterVolume}
                    
                    ForEach(records) { record in
                        let color = record.side == .sell ? Color("Red") : Color("Blue")
                        
                        let shouldHighlight = record.volume > highlightVolume
                        let bgColor = shouldHighlight ? (record.side == .sell ?Color("AskHover") : Color("BidHover")) : .white
                        let direction = returnDirection(direction: record.direction)
                        
                        Text("\(formatPrice(price: record.price, pair: record.pair))")
                            .foregroundStyle(color)
                            .frame(width: 100, height: 20, alignment: .center)
                            .background(bgColor)
                        VStack{
                            Image(systemName: direction.0)
                                .foregroundColor(direction.1)
                                .imageScale(.medium)
                        }
                         
                            .frame(width: 30, height: 20, alignment: .leading)
                            .background(bgColor)
                        Text("\(record.side == .buy ? "BUY" : "SELL")")
                            .foregroundStyle(color)
                            .frame(width: 50, height: 20, alignment: .center)
                            .background(bgColor)
                        Text("\(formatVolume(volume: record.volume, pair: record.pair))")
                            .foregroundStyle(color)
                            .frame(width: 50, height: 20, alignment: .leading)
                            .background(bgColor)
                    }
                }
            }
        }.frame(width: 250)
            .background(Color("Background"))
            .font(.caption)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            )
    }
}

#Preview {
    BybitTimesAndSalesView()
}
