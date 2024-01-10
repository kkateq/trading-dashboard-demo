//
//  BybitPositionsView.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import SwiftUI

struct BybitPositionsView: View {
    @EnvironmentObject var manager: BybitPrivateManager
    @EnvironmentObject var book: BybitOrderBook
    
    var useREST: Bool
    var validate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Divider()
            
            HStack {
                Text("Positions")
                    .font(.caption)
                Spacer()
                Button(action: {
                    Task {
                        await manager.fetchPositions()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color.gray)
                        
                    }.frame(width: 20, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .imageScale(.large)
                }.buttonStyle(PlainButtonStyle())
            }.padding([.bottom], 5)
            
            ScrollView {
                if manager.positions.count > 0 {
                    VStack(alignment: .leading) {
                        HStack(spacing: 2) {
                            ForEach(manager.positions, id: \.positionIdx) { position in
                                let net = Double(position.positionValue)!
                                
                                Text("\(position.symbol)")
                                Spacer()
                                Text(position.side)
                                    .foregroundColor(position.side == "sell" ? Color("Red") : Color("Green"))
                                    .font(.caption2)
                                Spacer()
                                Text(position.entryPrice)
                                    .foregroundColor(.blue)
                                    .font(.caption2)
                                Spacer()
                                Text("\(formatPrice(price: net, pair: book.pair))$")
                                    .foregroundColor(net < 0 ?Color("Red") : Color("Green"))
                                    .font(.caption2)
                                Spacer()
                                Button(action: {
                                    Task {
//                                        await manager.flattenPosition(refid: position.refid, best_bid: book.stats.bestBid, best_ask: book.stats.bestAsk, useREST: useREST, validate: validate)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                    }.frame(width: 20, height: 20)
                                        .foregroundColor(Color.white)
                                        .background(Color.teal)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .imageScale(.medium)
                                }.buttonStyle(PlainButtonStyle())
                                Button(action: {
                                    Task {
//                                        await manager.closePositionMarket(refid: position.refid, useREST: useREST, validate: validate)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "xmark")
                                    }.frame(width: 20, height: 20)
                                        .foregroundColor(Color.white)
                                        .background(Color.orange)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .imageScale(.medium)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }
                            
                      
                    }
                }
                else {
                    Text("No positions")
                }
                VStack {
                    Button(action: {
                        Task {
//                                    await manager.flattenAllPositions(best_bid: book.stats.bestBid, best_ask: book.stats.bestAsk, useREST: useREST, validate: validate)
                        }
                    }) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                            Text("Flatten Positions")
                        }.frame(width: 300, height: 30)
                            .foregroundColor(Color.white)
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .imageScale(.large)
                    }.buttonStyle(PlainButtonStyle())
                        
                    Button(action: {
                        Task {
                            await manager.closeAllPositions(useREST: useREST, validate: validate)
                        }
                    }) {
                        HStack {
                            Image(systemName: "power.circle.fill")
                            Text("Close Positions")
                        }
                        .frame(width: 300, height: 30)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .imageScale(.large)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }.buttonStyle(PlainButtonStyle())
                }.padding(.top)
                    .padding(.bottom)
                Divider()
            }
        }.frame(width: 300, height: 200, alignment: .leading)
    }
}

#Preview {
    BybitPositionsView(useREST: true, validate: true)
}
