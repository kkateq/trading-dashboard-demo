//
//  EmptyCell.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct EmptyCell: View {
    var width: CGFloat
    var body: some View {
        Text("")
            .frame(width: width, height: 25, alignment: .center)
            .font(.system(.title3))
            .background(Rectangle().fill(Color.white))
    }
}

struct EmptyCell_Previews: PreviewProvider {
    static var previews: some View {
        EmptyCell(width: 100)
    }
}
