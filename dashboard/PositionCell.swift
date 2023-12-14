//
//  PositionCell.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct PositionCell: View {
    var position: String
    
    var body: some View {
        Text(position)
            .frame(width: 100, height: 25, alignment: .center)
            .font(.system(.title3))
            .background(Rectangle().fill(Color.white))
    }
}

struct PositionCell_Previews: PreviewProvider {
    static var previews: some View {
        PositionCell(position: "")
    }
}
