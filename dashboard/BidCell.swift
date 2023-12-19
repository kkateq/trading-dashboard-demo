//
//  VolumeCell.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct BidCell: View {
    var volume: String
    @StateObject var manager = Manager()
    @State var isHover = false
    var price: String
    var onBuyLimit: (String, String) async -> Void
    
    var hoverColor: Color {
        return isHover ? Color("BidHover") : .white
    }
    
    var body: some View {
        Button(action: {
            Task {
                await onBuyLimit(volume, price)
            }
        }) {
            Text(volume)
                .frame(width:100, height: 25, alignment: .trailing)
                .font(.system(.title3))
                .foregroundColor(Color("BidTextColor")).font(.system(.title3))
                .background(Rectangle().fill(hoverColor))
                .onHover { hover in
                    isHover = hover
                }
        }.buttonStyle(PlainButtonStyle())
    }
}

struct VolumeCell_Previews: PreviewProvider {
    static var previews: some View {
        BidCell(volume: "1000", price: "0.999", onBuyLimit: { print("\($0) sell \($1)") })
    }
}
