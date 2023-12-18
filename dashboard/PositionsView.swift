//
//  PositionsView.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct PositionsView: View {
    var positions: [PositionResponse]
    var pegValue: Double
    var onClosePositionMarket: (String) async -> Void
    var onFlattenPosition: (String) async -> Void
    var onRefreshPositions: () async -> Void
    
    let layout = [
        GridItem(.fixed(60), spacing: 1),
        GridItem(.fixed(30), spacing: 1),
        GridItem(.fixed(30), spacing: 1),
        GridItem(.fixed(30), spacing: 1, alignment: .trailing),
        GridItem(.fixed(30), spacing: 1, alignment: .trailing),
    ]
    
    func getPL(vol: Double, cost: Double, type: String) -> Double {
        let currentPrice = vol * pegValue
        let pl = type == "sell" ? cost - currentPrice : currentPrice - cost
        
        return pl
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Divider()
            
            HStack {
                
                Text("Positions")
                    .font(.caption)
                Spacer()
                Button(action: {
                    Task {
                        await onRefreshPositions()
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
                if positions.count > 0 {
                    LazyVGrid(columns: layout) {
                        ForEach(positions) { position in
                            let pl = getPL(vol: position.vol, cost: position.cost, type: position.type)
                            
                            Text(position.pair).font(.caption2)
                            Text(position.type)
                                .foregroundColor(position.type == "sell" ? .red : .green)
                                .font(.caption2)
                            
                            Text("\(String(format: "%.1f", pl))$")
                                .foregroundColor(pl < 0 ? .red : .green)
                                .font(.caption2)
                            
                            Button(action: {
                                Task {
                                    await onFlattenPosition(position.refid)
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
                                    await onClosePositionMarket(position.refid)
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
//        let p1 = PositionResponse(refid: "sd", vol: 10.0, cost: 8.0, pair: "MATIC/USD", type: "sell", entryPrice: 10.0)
//        let p2 = PositionResponse(refid: "sd2", vol: 10.0, cost: 8.0, pair: "MATIC/USD", type: "buy", entryPrice: 10.0)
//
//        let testPositions:[PositionResponse] = [p1, p2]
        
        PositionsView(positions: [], pegValue: 0.9889, onClosePositionMarket: { print("Closing position \($0)")}, onFlattenPosition: { print("Flattening position \($0)")}, onRefreshPositions: { print("Refreshing positions")} )
    }
}
