//
//  PositionsView.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct PositionsView: View {
    @StateObject var manager = Manager()

    let layout = [
        GridItem(.fixed(60), spacing: 1),
        GridItem(.fixed(30), spacing: 1),
        GridItem(.fixed(30), spacing: 1),
        GridItem(.fixed(30), spacing: 1, alignment: .trailing),
        GridItem(.fixed(30), spacing: 1, alignment: .trailing),
    ]
    
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
            }
            
            ScrollView {
                if let positions = manager.positions {
                    if positions.count > 0 {
                        VStack {
                            LazyVGrid(columns: layout) {
                                ForEach(positions) { position in
                                    
                                    Text(position.pair).font(.caption2)
                                    Text(position.type)
                                        .foregroundColor(position.type == "sell" ? Color("Red") : Color("Green"))
                                        .font(.caption2)
                                    
                                    Text("\(position.net)$")
                                        .foregroundColor(position.net.starts(with: "-") ?Color("Red") : Color("Green"))
                                        .font(.caption2)
                                    
                                    Button(action: {
                                        Task {
                                            await manager.flattenPosition(refid: position.refid)
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
                                            await manager.closePositionMarket(refid: position.refid)
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
                                        await manager.flattenAllPositions()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "lightbulb.fill")
                                        Text("Flatten Positions")
                                    }.frame(width: 200, height: 30)
                                        .foregroundColor(Color.white)
                                        .background(Color.teal)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .imageScale(.large)
                                }.buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    Task {
                                        await manager.closeAllPositions()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "power.circle.fill")
                                        Text("Close Positions")
                                    }
                                    .frame(width: 200, height: 30)
                                    .foregroundColor(Color.white)
                                    .background(Color.black)
                                    .imageScale(.large)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                }.buttonStyle(PlainButtonStyle())
                            }.padding(.top)
                                .padding(.bottom)
                        }
                    }
                }
                else {
                    Text("No positions")
                }
                Divider()
            }
        }.frame(width: 200, height: 200, alignment: .leading)
    }
}

struct PositionsView_Previews: PreviewProvider {
    static var previews: some View {
        PositionsView()
    }
}
