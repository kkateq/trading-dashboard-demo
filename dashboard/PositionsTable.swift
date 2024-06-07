//
//  PositionsTable.swift
//  dashboard
//
//  Created by km on 01/02/2024.
//

import SwiftUI

struct PositionsTable: View {
    var positions: [BybitPositionDataIdentifiable]

    var body: some View {
        VStack {
            Table(self.positions) {
                TableColumn("Account") { position in
                    Text(position.accountName)
                }
                TableColumn("Symbol") { position in
                    let pos = position.data
                    let colorSide: Color = pos.side == "Sell" ? .pink : .blue
                    VStack(alignment: .leading) {
                        Text("\(pos.symbol)")
                        Text("\(pos.side) cross \(pos.leverage)x").font(.caption).foregroundStyle(colorSide)
                    }
                }
                TableColumn("Pnl") { position in
                    let pos = position.data
                    let color: Color = pos.unrealisedPnl.starts(with: "-") ? .red : .green
                    Text("\(pos.unrealisedPnl) USDT").foregroundStyle(color)
                }
                TableColumn("Pnl") { position in
                    let pos = position.data
                    let color: Color = pos.unrealisedPnl.starts(with: "-") ? .red : .green
                    let pnl = Double(pos.unrealisedPnl.replacingOccurrences(of: "-", with: ""))!
                    let pnk = roundPrice(price: (pnl / (Double(pos.positionValue)! / 10)) * 100, fr: 4)

                    Text("\(formatPrice(price: pnk, fr: 4)) %").foregroundStyle(color)
                }
                TableColumn("Size") { position in
                    let pos = position.data
                    Text("\(pos.size)")
                }
                TableColumn("IM") { position in
                    let pos = position.data
                    let value = Double(pos.positionIM)!
                    Text("\(formatPrice(price: value, fr: 4)) USDT")
                }
                TableColumn("Value") { position in
                    let pos = position.data
                    let value = Double(pos.positionValue)!
                    Text("\(formatPrice(price: value, fr: 4)) USDT")
                }
//                TableColumn("Size") { position in
//                    let pos = position.data
//                    Text("\(pos.stopLoss)")
//                }
            }
        }
    }
}

#Preview {
    PositionsTable(positions: [])
}
