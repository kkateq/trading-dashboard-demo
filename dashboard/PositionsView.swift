//
//  PositionsView.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct PositionsView: View {
    @EnvironmentObject var manager: KrakenOrderManager
    @EnvironmentObject var book: KrakenOrderBookData
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
                        await manager.refetchOpenPositions()
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
                            ForEach(manager.positions) { position in
                                    
                                Text(position.pair).font(.caption2)
                                Spacer()
                                Text(position.type)
                                    .foregroundColor(position.type == "sell" ? Color("Red") : Color("Green"))
                                    .font(.caption2)
                                    Spacer()
                                Text("\(formatPrice(price: Double(position.cost)! / Double(position.vol)!))")
                                    .foregroundColor(.blue)
                                    .font(.caption2)
                                Spacer()
                                Text("\(position.net)$")
                                    .foregroundColor(position.net.starts(with: "-") ?Color("Red") : Color("Green"))
                                    .font(.caption2)
                                    Spacer()
                                Button(action: {
                                    Task {
                                        await manager.flattenPosition(refid: position.refid, best_bid: book.stats.bestBid, best_ask: book.stats.bestAsk, useREST: useREST, validate: validate)
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
                                        await manager.closePositionMarket(refid: position.refid, useREST: useREST, validate: validate)
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
                            
                        VStack {
                            Button(action: {
                                Task {
                                    await manager.flattenAllPositions(best_bid: book.stats.bestBid, best_ask: book.stats.bestAsk, useREST: useREST, validate: validate)
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
                    }
                }
                else {
                    Text("No positions")
                }
                Divider()
            }
        }.frame(width: 300, height: 200, alignment: .leading)
    }
}

struct PositionsView_Previews: PreviewProvider {
    static var previews: some View {
        PositionsView(useREST: true, validate: true)
    }
}
