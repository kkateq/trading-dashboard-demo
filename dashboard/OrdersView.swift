//
//  OrdersView.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct OrdersView: View {
    var orders: [OrderResponse]!
    var onCancelOrder: (String) async -> Void
    var onCancelAllOrders: () async -> Void
    var onRefreshOrders: () async -> Void
    
 
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Divider()
            
            HStack {
                Text("Orders")
                    .font(.caption)
                Spacer()
                Button(action: {
                    Task {
                        await onRefreshOrders()
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
                if let ordersList = orders {
                    if ordersList.count > 0 {
                        VStack{
                           
                                ForEach(orders) { order in
                                    HStack {
                                        Text(order.order)
                                            .foregroundColor(order.order.starts(with: "sell") ? .red : .green)
                                            .font(.caption2)
                                        Spacer()
                                        Button(action: {
                                            Task {
                                                await onCancelOrder(order.txid)
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
                                    await onCancelAllOrders()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Cancel Orders")
                                }.frame(width: 200, height: 30)
                                    .foregroundColor(Color.white)
                                    .background(Color.gray)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .imageScale(.large)
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                } else {
                    Text("No orders")
                }
                Divider()
            }
        }.frame(width: 200, height: 200, alignment: .leading)
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        let o1 = OrderResponse(txid: "d", order: "sell MATIC/USD @ 0.7998 limit", type: "sell")
        let o2 = OrderResponse(txid: "d", order: "buy MATIC/USD @ 0.7998 limit", type: "buy")
        let o3 = OrderResponse(txid: "d", order: "sell MATIC/USD @ 0.7998 limit", type: "sell")
        let testOrders: [OrderResponse] = [o1, o2, o3]
        
        OrdersView(orders: testOrders, onCancelOrder: { print("\($0) is being cancelled")},
                   onCancelAllOrders: { print("Refreshing orders")},
                   onRefreshOrders: { print("Refreshing orders")})
    }
}
