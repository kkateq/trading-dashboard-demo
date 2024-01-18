//
//  BybitPriceLevelFormView.swift
//  dashboard
//
//  Created by km on 17/01/2024.
//

import SwiftUI

struct BybitPriceLevelFormView: View {
    @State var priceMark: String = "0"
    @State var level: PriceLevelType = .minor
    @EnvironmentObject var book: BybitOrderBook
    
    var body: some View {
        VStack {
            Text("Levels \(PriceLevelManager.manager.anchor.time)")
            VStack {
                ForEach(PriceLevelManager.manager.levels(pair: book.pair)) { level in
                    HStack {
                        Text(level.price)
                        Spacer()
                        Button(action: {
                            Task {
                                PriceLevelManager.manager.deleteLevel(id: level.id, pair: book.pair)
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
                            PriceLevelManager.manager.addLevel(pair: book.pair, price: priceMark, type: level)
                        }
                    }) {
                        HStack {
                            Text("Add Mark")
                        }
                    }
                    Spacer()
                }
            }
           
        }.frame(width: 300)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            ).padding()
    }
}
