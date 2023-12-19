//
//  OrderForm.swift
//  dashboard
//
//  Created by km on 15/12/2023.
//

import SwiftUI

struct OrderForm: View {
    var pegValue: Double
    var bestBid: Double
    var bestAsk: Double
    @State private var pair: String = "MATIC/USD"
    @State private var volume: Double = 10.0
    @State private var isEditing = false
    @State private var scaleInOut = true
    @StateObject var manager = Manager()

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Picker("", selection: $pair) {
                        ForEach(["MATIC/USD"], id: \.self) {
                            Text($0)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    Spacer()
                    Text("\(volume * pegValue, specifier: "%.2f")$")
                        .foregroundColor(.black)
                        .font(.title3)
                }
            }.padding()
            VStack(alignment: .leading) {
                TextField("", value: $volume, formatter: formatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Toggle("Scale In/Out", isOn: $scaleInOut)
                    .toggleStyle(.checkbox)
            }.padding(.leading)
                .padding(.trailing)
            VStack {
                HStack {
                    VStack {
                        Button(action: {
                            Task {
                                await manager.sellMarket(pair: pair, vol: volume, scaleInOut: scaleInOut)
                            }
                        }) {
                            HStack {
                                Text("Sell Market")
                            }.frame(width: 100, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                        Button(action: {
                            Task {
                                await manager.buyMarket(pair: pair, vol: volume, scaleInOut: scaleInOut)
                            }
                        }) {
                            HStack {
                                Text("Buy Market")
                            }.frame(width: 100, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    VStack {
                        Button(action: {
                            Task {
                                await manager.sellAsk(pair: pair, vol: volume, best_ask: bestAsk, scaleInOut: scaleInOut)
                            }
                        }) {
                            HStack {
                                Text("Sell Ask")
                            }.frame(width: 100, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                        Button(action: {
                            Task {
                                await manager.buyBid(pair: pair, vol: volume, best_bid: bestBid, scaleInOut: scaleInOut)
                            }
                        }) {
                            HStack {
                                Text("Buy Bid")
                            }.frame(width: 100, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }.padding(.top)
                .padding(.bottom)

            VStack {
                OrdersView(orders: manager.orders, onCancelOrder: manager.cancelOrder, onCancelAllOrders: manager.cancelAllOrders, onRefreshOrders: manager.refetchOpenOrders)
            }
            .padding(.top)

            VStack {
                PositionsView()
            }

            VStack {
                
                LogView()

                HStack(){
                    if manager.isConnected {
                        Image(systemName: "wifi")
                            .foregroundColor(Color.green)
                        Text("Socket connected")
                    } else {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(Color.gray)
                        Text("Socket disconnected")
                    }
                    

                }.frame(width: 200, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .imageScale(.large)
            }

            Spacer()
        }.frame(maxWidth: 220, maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray, lineWidth: 2)
            )
    }
}

struct OrderForm_Previews: PreviewProvider {
    static var previews: some View {
        OrderForm(pegValue: 0, bestBid: 0, bestAsk: 0)
    }
}
