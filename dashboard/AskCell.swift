//
//  AskCell.swift
//  dashboard
//
//  Created by km on 19/12/2023.
//

import SwiftUI

struct AskCell: View {
    var volume: String
    var price: String
    var onSellLimit: (String, String) -> Void

    @State var isHover = false
    @StateObject var manager = Manager()

    var hoverColor: Color {
        return isHover ? Color("AskHover") : .white
    }

    var body: some View {
        Button(action: {
            Task {
                onSellLimit(volume, price)
            }
        }) {
            Text(volume)
                .frame(width: 100, height: 25, alignment: .leading)
                .font(.system(.title3))
                .foregroundColor(Color("AskTextColor")).font(.system(.title3))
                .background(Rectangle().fill(hoverColor))
                .onHover { hover in
                    isHover = hover
                }
        }.buttonStyle(PlainButtonStyle())
    }
}

struct AskCell_Previews: PreviewProvider {
    static var previews: some View {
        AskCell(volume: "100", price: "0.999", onSellLimit: { print("\($0) sell \($1)") })
    }
}
