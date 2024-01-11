//
//  BybitOrdersView.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import SwiftUI

struct BybitOrdersView: View {
    @EnvironmentObject var manager: BybitPrivateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Divider()
            
            HStack {
                Text("Orders")
                    .font(.caption)
                Spacer()
                Button(action: {
                    Task {
                        await manager.fetchOrders()
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
                if manager.orders.count > 0 {
                    VStack {
                        ForEach(manager.orders, id: \.orderId) { order in
                            HStack {
                                Text("\(order.side) \(order.orderType) \(order.symbol) @ \(order.price)")
                                    .foregroundColor(order.side.starts(with: "Sell") ? Color("Red") : Color("Green"))
                                    .font(.caption2)
                                Spacer()
                                Button(action: {
                                    Task {
                                        await manager.cancelOrder(id: order.orderId, symbol: order.symbol)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "trash.square.fill")
                                            .foregroundColor(Color.gray)
                                                
                                    }.frame(width: 20, height: 20)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .imageScale(.large)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                } else {
                    Text("No orders")
                }
                Divider()
                Button(action: {
                    Task {
                        await manager.cancelAllOrders()
                    }
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Cancel Orders")
                    }.frame(width: 300, height: 30)
                        .foregroundColor(Color.white)
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .imageScale(.large)
                }.buttonStyle(PlainButtonStyle())
            }
        }.frame(width: 300, height: 200, alignment: .leading)
    }
}

#Preview {
    BybitOrdersView()
}
