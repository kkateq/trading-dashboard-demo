//
//  OrdersView.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var manager: Manager
    
    let layout = [
        GridItem(.fixed(100), spacing: 2),
        GridItem(.fixed(100), spacing: 2),
    ]
    var body: some View {
        VStack {
            LazyVGrid(columns: layout) {
                ForEach(manager.orders) { order in
                    Text(order.order)
                        .foregroundColor(order.type == "sell" ? .red : .green)
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "xmark.fill")
                        }.frame(width: 30, height: 30)
                            .foregroundColor(Color.white)
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .imageScale(.large)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
    }
}
