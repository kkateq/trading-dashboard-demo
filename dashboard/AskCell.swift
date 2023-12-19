//
//  AskCell.swift
//  dashboard
//
//  Created by km on 19/12/2023.
//

import SwiftUI

struct AskCell: View {
    var volume: String
    @State var isHover = false

    var hoverColor: Color {
        return isHover ? Color("AskHover") : .white
    }

    var body: some View {
        Text(volume)
            .frame(width: 100, height: 25, alignment: .leading)
            .font(.system(.title3))
            .foregroundColor(.pink).font(.system(.title3))
            .background(Rectangle().fill(hoverColor))
            .onHover { hover in
                isHover = hover
            }
    }
}

struct AskCell_Previews: PreviewProvider {
    static var previews: some View {
        AskCell(volume: "100")
    }
}
