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

    var body: some View {
        VStack {
            Text("Levels")
            VStack {
                ForEach(PriceLevelManager.manager.levels) { level in
                    HStack {
                        Text(level.price)
                        Spacer()
                        Button(action: {
                            Task {
                                PriceLevelManager.manager.deleteLevel(id: level.id)
                            }
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                            }
                            .frame(width: 25, height: 25, alignment: .center)
                            .foregroundColor(Color.red)
                            .imageScale(.large)
                        }
                    }.frame(width: 500, height: 25)
                        .background(.white)
                }.padding()
            }
            
            HStack(alignment: .top) {
                VStack {
                    Text("Add mark:").font(.caption)
                    HStack {
                        
                        TextField("Mark", text: $priceMark)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Spacer()
                        Picker("", selection: $level) {
                            ForEach(PriceLevelType.allCases) { option in
                                Text(String(describing: option))
                            }
                        }.frame(width: 200)
                    }
                    
                    Button(action: {
                        Task {
                            PriceLevelManager.manager.addLevel(price: priceMark, type: level)
                        }
                    }) {
                        HStack {
                            Text("Add Mark")
                        }
                    }
                }
                
            }
           
        }.frame(width: 500)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            ).padding()
    }
}
