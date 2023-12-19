//
//  VolumeCell.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct BidCell: View {
    var volume: String

    @State var isHover = false
    var hoverColor: Color {
        return isHover ? Color("BidHover") : .white
    }
    
    var body: some View {
        Text(volume)
            .frame(width:100, height: 25, alignment: .trailing)
            .font(.system(.title3))
            .foregroundColor(.blue).font(.system(.title3))
            .background(Rectangle().fill(hoverColor))
            .onHover { hover in
                isHover = hover
            }
    }
}

struct VolumeCell_Previews: PreviewProvider {
    static var previews: some View {
        BidCell(volume: "1000")
    }
}
