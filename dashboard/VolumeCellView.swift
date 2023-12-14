//
//  VolumeCell.swift
//  dashboard
//
//  Created by km on 14/12/2023.
//

import SwiftUI

struct VolumeCell: View {
    var volume: String
    var side: BookRecordType

    var color: Color {
        return side == .ask ? .pink : .blue
    }
    
    var algn: Alignment {
        get {
            return side == .ask ? Alignment.leading : .trailing
        }
    }
    
    var padding: Edge.Set {
        get {
            return side == .ask ? Edge.Set.leading : .trailing
        }
    }

    var body: some View {
        Text(volume)
            .frame(width:100, height: 25, alignment: self.algn)
            .font(.system(.title3))
//            .padding(padding, 4)
            .foregroundColor(color).font(.system(.title3))
            .background(Rectangle().fill(Color.white))
    }
}

struct VolumeCell_Previews: PreviewProvider {
    static var previews: some View {
        VolumeCell(volume: "1000", side: .ask)
    }
}
