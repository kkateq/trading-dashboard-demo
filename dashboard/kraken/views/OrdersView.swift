//
//  OrdersView.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var manager: KrakenOrderManager
    var useREST: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Divider()
            
            HStack {
                Text("Orders")
                    .font(.caption)
                Spacer()
                Button(action: {
                    Task {
                        await manager.refetchOpenOrders()
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
                        ForEach(manager.orders) { order in
                            HStack {
                                Text(order.order)
                                    .foregroundColor(order.order.starts(with: "sell") ? Color("Red") : Color("Green"))
                                    .font(.caption2)
                                Spacer()
                                Button(action: {
                                    Task {
                                        await manager.cancelOrder(txid: order.txid, useREST: useREST)
                                        await manager.refetchOpenOrders()
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
                            
                        Button(action: {
                            Task {
                                await manager.cancelAllOrders(useREST: useREST)
                                await manager.refetchOpenOrders()
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

                } else {
                    Text("No orders")
                }
                Divider()
            }
        }.frame(width: 300, height: 200, alignment: .leading)
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView(useREST: true)
    }
}
