//
//  BybitOrderFormView.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import SwiftUI

struct BybitOrderFormView: View {
    @Binding var volume: Double
    @Binding var scaleInOut: Bool

    @Binding var stopLossEnabled: Bool
    @Binding var takeProfitEnabled: Bool
    @Binding var sellStopLoss: Double!
    @Binding var buyStopLoss: Double!
    @Binding var sellTakeProfit: Double!
    @Binding var buyTakeProfit: Double!

    @EnvironmentObject var manager: BybitPrivateManager
    @EnvironmentObject var book: BybitOrderBook

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
//        return Constants.pairSettings[pair]!.leverage
//        It's variable on BYbit'
        return 2
    }

    func getAllowedMargin() -> Double {
        let p = manager.totalAvailableUSDT * Double(getAllowedleverage(pair: book.pair))
        return p - p * Constants.bybit_fee
    }

    func isFormInvalid() -> Bool {
        return volume * book.stats.pegValue > getAllowedMargin() - 1
    }

    func updateStopLoss(_ publishedStats: BybitStats!) {
        sellStopLoss = publishedStats.bestAsk + roundPrice(price: publishedStats.bestAsk * 0.05, pair: book.pair)
        buyStopLoss = publishedStats.bestBid - roundPrice(price: publishedStats.bestBid * 0.05, pair: book.pair)
    }

    func updateTakeProfit(_ publishedStats: BybitStats!) {
        sellTakeProfit = publishedStats.bestAsk - roundPrice(price: publishedStats.bestAsk * 0.1, pair: book.pair)
        buyTakeProfit = publishedStats.bestBid + roundPrice(price: publishedStats.bestBid * 0.1, pair: book.pair)
    }

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Account balance:")
                        .foregroundColor(.black)
                        .font(.title3)
                    Spacer()
                    Text("\(Int(manager.totalAvailableUSDT))$")
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
                    Text("Bybit fee \(Constants.bybit_fee)%").font(.caption).foregroundColor(.gray)
                    Spacer()
                    Text("\(formatPrice(price: volume * Constants.bybit_fee))$").font(.caption).foregroundColor(.gray)
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

                HStack {
                    Toggle("Take profit", isOn: $takeProfitEnabled)
                        .toggleStyle(.checkbox)
                    Spacer()
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Sell take profit").font(.caption).foregroundStyle(.gray)
                        TextField("Sell take profit", value: $sellTakeProfit, formatter: formatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onReceive(book.$stats, perform: updateTakeProfit)
                            .disabled(!takeProfitEnabled)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Buy take profit").font(.caption).foregroundStyle(.gray)
                        TextField("Buy take profit", value: $buyTakeProfit, formatter: formatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onReceive(book.$stats, perform: updateTakeProfit)
                            .disabled(!takeProfitEnabled)
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
                                await manager.sellMarket(symbol: book.pair, vol: volume, scaleInOut: scaleInOut, stopLoss: stopLossEnabled ? sellStopLoss : nil, takeProfit: takeProfitEnabled ? sellTakeProfit : nil)
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
                                await manager.buyMarket(symbol: book.pair, vol: volume, scaleInOut: scaleInOut, stopLoss: stopLossEnabled ? buyStopLoss : nil, takeProfit: takeProfitEnabled ? buyTakeProfit : nil)
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
                                await manager.sellLimit(symbol: book.pair, vol: volume, price: book.stats.bestAsk, scaleInOut: scaleInOut, stopLoss: stopLossEnabled ? sellStopLoss : nil, takeProfit: takeProfitEnabled ? sellTakeProfit : nil)
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
                                await manager.buyLimit(symbol: book.pair, vol: volume, price: book.stats.bestBid, scaleInOut: scaleInOut, stopLoss: stopLossEnabled ? buyStopLoss : nil, takeProfit: takeProfitEnabled ? buyTakeProfit : nil)
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
                BybitOrdersView()
            }
            .padding(.top)

            VStack {
                BybitPositionsView()
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

                }.frame(width: 400, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .imageScale(.large)
                Divider()
            }

            Spacer()
        }.frame(maxWidth: 420, maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray, lineWidth: 2)
            )
            .background(Color("Background"))
    }
}
