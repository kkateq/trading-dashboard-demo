//
//  OrderForm.swift
//  dashboard
//
//  Created by km on 15/12/2023.
//

import SwiftUI

struct OrderForm: View {
    @Binding  var volume: Double
    @Binding  var scaleInOut: Bool
    @Binding  var validate: Bool
    @Binding  var useRest: Bool
    @Binding  var leverage: Int
    
    @EnvironmentObject var manager: KrakenOrderManager
    @EnvironmentObject var book: OrderBookData

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(book.pair)
                    Spacer()
                    Text("\(volume * book.stats.pegValue, specifier: "%.2f")$")
                        .foregroundColor(.black)
                        .font(.title3)
                }
            }.padding()
            VStack(alignment: .leading) {
                TextField("Volume", value: $volume, formatter: formatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Leverage", value: $leverage, formatter: formatter)
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
                                await manager.sellMarket(pair: book.pair, vol: volume, scaleInOut: scaleInOut, validate: validate, leverage: leverage)
                            }
                        }) {
                            HStack {
                                Text("Sell Market")
                            }.frame(width: 100, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color("RedDarker"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                        Button(action: {
                            Task {
                                await manager.buyMarket(pair: book.pair, vol: volume, scaleInOut: scaleInOut, validate: validate, leverage: leverage)
                            }
                        }) {
                            HStack {
                                Text("Buy Market")
                            }.frame(width: 100, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color("GreenDarker"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    VStack {
                        Button(action: {
                            Task {
                                await manager.sellAsk(pair: book.pair, vol: volume, best_ask: book.stats.bestAsk, scaleInOut: scaleInOut, validate: validate, leverage: leverage)
                            }
                        }) {
                            HStack {
                                Text("Sell Ask")
                            }.frame(width: 100, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color("Red"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                        Button(action: {
                            Task {
                                await manager.buyBid(pair: book.pair, vol: volume, best_bid: book.stats.bestBid, scaleInOut: scaleInOut, validate: validate, leverage: leverage)
                            }
                        }) {
                            HStack {
                                Text("Buy Bid")
                            }.frame(width: 100, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color("Green"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }.padding(.top)
                .padding(.bottom)

            VStack {
                OrdersView(useREST: useRest)
            }
            .padding(.top)

            VStack {
                PositionsView(useREST: useRest, validate: validate, leverage: leverage)
            }

            VStack {
                LogView()

                HStack {
                    if manager.isConnected {
                        Image(systemName: "wifi")
                            .foregroundColor(Color.green)
                        Text("Socket connected")
                    } else {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(Color.gray)
                        Text("Socket disconnected")
                    }
                    Spacer()

                }.frame(width: 200, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .imageScale(.large)
                Divider()
                HStack {
                    Toggle("Validate orders", isOn: $validate)
                        .toggleStyle(.checkbox)
                    Spacer()
                }.frame(width: 200, height: 20)
                Divider()
                HStack {
                    Toggle("Use REST API", isOn: $useRest)
                        .toggleStyle(.checkbox)
                    Spacer()
                }.frame(width: 200)
                Divider()
            }

            Spacer()
        }.frame(maxWidth: 220, maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            )
    }
}

