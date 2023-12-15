//
//  OrderForm.swift
//  dashboard
//
//  Created by km on 15/12/2023.
//

import SwiftUI

struct OrderForm: View {
    var pair: String
//    var onCancelAllOrders : () -> Void
//    var onCloseAllPositions: () -> Void
//    var onFlattenAllPositions: () -> Void
//    var onBuyMarket: () -> Void
//    var onSellMarket: () -> Void
    @State private var volume: Double = 10.0
    @State private var isEditing = false
    @State private var scaleInOut = true

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    let layout = [
        GridItem(.fixed(30), spacing: 5),
        GridItem(.fixed(100), spacing: 5),
        GridItem(.fixed(100), spacing: 5),
        GridItem(.fixed(150), spacing: 5, alignment: .center),
        GridItem(.fixed(150), spacing: 5, alignment: .center),
        GridItem(.fixed(550), spacing: 5, alignment: .bottom),
     
    ]

    var body: some View {
        HStack {
            LazyHGrid(rows: layout, alignment: .top) {
                VStack {
                    Spacer()
                    HStack {
                        Text(pair)
                            .font(.title3)
                        Spacer()
                        Text("$ 0.90")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                }
                VStack(alignment: .leading) {
                    TextField("", value: $volume, formatter: formatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                    Slider(
                        value: $volume,
                        in: 0 ... 100,
                        onEditingChanged: { editing in
                            isEditing = editing
                        }
                    )
                        
                    Toggle("Scale In/Out", isOn: $scaleInOut)
                        .toggleStyle(.checkbox)
                }
                    
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Button(action: {}) {
                                HStack {
                                    Text("Sell Market")
                                }.frame(width: 90, height: 50)
                                    .foregroundColor(Color.white)
                                    .background(Color.gray)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .imageScale(.large)
                            }.buttonStyle(PlainButtonStyle())
                            Button(action: {}) {
                                HStack {
                                    Text("Buy Market")
                                }.frame(width: 90, height: 50)
                                    .foregroundColor(Color.white)
                                    .background(Color.gray)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .imageScale(.large)
                            }.buttonStyle(PlainButtonStyle())
                        }
                        VStack {
                            Button(action: {}) {
                                HStack {
                                    Text("Sell Ask")
                                }.frame(width: 90, height: 50)
                                    .foregroundColor(Color.white)
                                    .background(Color.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .imageScale(.large)
                            }.buttonStyle(PlainButtonStyle())
                            Button(action: {}) {
                                HStack {
                                    Text("Buy Bid")
                                }.frame(width: 90, height: 50)
                                    .foregroundColor(Color.white)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .imageScale(.large)
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                HStack {
                    Text("Orders")
                }
                HStack {
                    Text("Positions")
                }
                    
                VStack(alignment: .trailing) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                            Text("Flatten Positions")
                        }.frame(width: 180, height: 50)
                            .foregroundColor(Color.white)
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .imageScale(.large)
                    }.buttonStyle(PlainButtonStyle())
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete Orders")
                        }.frame(width: 180, height: 50)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .imageScale(.large)
                    }.buttonStyle(PlainButtonStyle())
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "power.circle.fill")
                            
                            Text("Close Everything")
                        }
                        .frame(width: 180, height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .imageScale(.large)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding([.trailing, .leading], 5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(.gray, lineWidth: 2)
        )
    }
}

struct OrderForm_Previews: PreviewProvider {
    static var previews: some View {
        OrderForm(pair: "MATIC/USD")
    }
}
