//
//  OrderForm.swift
//  dashboard
//
//  Created by km on 15/12/2023.
//

import SwiftUI

struct KrakenOrderForm: View {
    @Binding var volume: Double
    @Binding var scaleInOut: Bool
    @Binding var validate: Bool
    @Binding var useRest: Bool

    @Binding var stopLossEnabled: Bool
    @Binding var sellStopLoss: Double!
    @Binding var buyStopLoss: Double!

    @EnvironmentObject var manager: KrakenOrderManager
    @EnvironmentObject var book: KrakenOrderBookData

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    func getAllowedleverage(pair: String) -> Int {
        return Constants.pairSettings[pair]!.leverage
    }

    func getAllowedMargin() -> Double {
        let p = manager.accountBalance * Double(getAllowedleverage(pair: book.pair))
        return p - p * Constants.kraken_fee
    }

    func isFormInvalid() -> Bool {
        return volume * book.stats.pegValue > getAllowedMargin() - 1
    }

    func updateStopLoss(_ publishedStats: KrakenStats!) {
        sellStopLoss = publishedStats.bestAsk + roundPrice(price: publishedStats.bestAsk * 0.05, pair: book.pair)
        buyStopLoss = publishedStats.bestBid - roundPrice(price: publishedStats.bestBid * 0.05, pair: book.pair)
    }

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Account balance:")
                        .foregroundColor(.black)
                        .font(.title3)
                    Spacer()
                    Text("\(Int(manager.accountBalance))$")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }.padding()
            Divider()
            VStack {
                HStack {
                    Text(book.pair)
                    Spacer()
                    VStack {
                        Text("\(volume * book.stats.pegValue, specifier: "%.2f")$")
                            .foregroundColor(.black)
                            .font(.title3)
                    }
                }
                HStack {
                    Text("Leverage \(getAllowedleverage(pair: book.pair))x").font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    VStack {
                        Text("\(getAllowedMargin(), specifier: "%.2f")$")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }.padding()
            VStack(alignment: .leading) {
                HStack {
                    Text("Volume:")
                    TextField("Volume", value: $volume, formatter: formatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                HStack {
                    Text("Kraken fee \(Constants.kraken_fee)%").font(.caption).foregroundColor(.gray)
                    Spacer()
                    Text("\(formatPrice(price: volume * Constants.kraken_fee))$").font(.caption).foregroundColor(.gray)
                }.padding([.bottom])
                HStack {
                    Toggle("Stop loss", isOn: $stopLossEnabled)
                        .toggleStyle(.checkbox)
                    Spacer()
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Sell stop loss").font(.caption).foregroundStyle(.gray)
                        TextField("Sell stop loss", value: $sellStopLoss, formatter: formatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onReceive(book.$stats, perform: updateStopLoss)
                            .disabled(!stopLossEnabled)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Buy stop loss").font(.caption).foregroundStyle(.gray)
                        TextField("Buy stop loss", value: $buyStopLoss, formatter: formatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onReceive(book.$stats, perform: updateStopLoss)
                            .disabled(!stopLossEnabled)
                    }
                }.padding([.bottom])

                Toggle("Scale In/Out", isOn: $scaleInOut)
                    .toggleStyle(.checkbox)
            }.padding(.leading)
                .padding(.trailing)
            VStack {
                HStack {
                    VStack {
                        Button(action: {
                            Task {
                                await manager.sellMarket(pair: book.pair, vol: volume, price: 0, scaleInOut: scaleInOut, validate: validate, stopLoss: stopLossEnabled ? sellStopLoss : nil)
                            }
                        }) {
                            HStack {
                                Text("Sell Market")
                            }.frame(width: 150, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color("RedDarker"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                            .disabled(isFormInvalid())
                        Button(action: {
                            Task {
                                await manager.buyMarket(pair: book.pair, vol: volume, price: 0, scaleInOut: scaleInOut, validate: validate, stopLoss: stopLossEnabled ? buyStopLoss : nil)
                            }
                        }) {
                            HStack {
                                Text("Buy Market")
                            }.frame(width: 150, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color("GreenDarker"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                            .disabled(isFormInvalid())
                    }
                    VStack {
                        Button(action: {
                            Task {
                                await manager.sellAsk(pair: book.pair, vol: volume, best_ask: book.stats.bestAsk, scaleInOut: scaleInOut, validate: validate, stopLoss: stopLossEnabled ? sellStopLoss : nil)
                            }
                        }) {
                            HStack {
                                Text("Sell Ask")
                            }.frame(width: 150, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color("Red"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                            .disabled(isFormInvalid())
                        Button(action: {
                            Task {
                                await manager.buyBid(pair: book.pair, vol: volume, best_bid: book.stats.bestBid, scaleInOut: scaleInOut, validate: validate, stopLoss: stopLossEnabled ? buyStopLoss : nil)
                            }
                        }) {
                            HStack {
                                Text("Buy Bid")
                            }.frame(width: 150, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color("Green"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .imageScale(.large)
                        }.buttonStyle(PlainButtonStyle())
                            .disabled(isFormInvalid())
                    }
                }
            }.padding(.top)
                .padding(.bottom)

            VStack {
                OrdersView(useREST: useRest)
            }
            .padding(.top)

            VStack {
                PositionsView(useREST: useRest, validate: validate)
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

                }.frame(width: 300, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .imageScale(.large)
                Divider()
                HStack {
                    Toggle("Validate orders", isOn: $validate)
                        .toggleStyle(.checkbox)
                    Spacer()
                }.frame(width: 300, height: 20)
                Divider()
                HStack {
                    Toggle("Use REST API", isOn: $useRest)
                        .toggleStyle(.checkbox)
                    Spacer()
                }.frame(width: 300)
                Divider()
            }

            Spacer()
        }.frame(maxWidth: 320, maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            )
            .background(Color("Background"))
    }
}
