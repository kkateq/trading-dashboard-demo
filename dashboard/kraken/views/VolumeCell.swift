//
//  NewCell.swift
//  dashboard
//
//  Created by km on 22/12/2023.
//

import SwiftUI

struct VolumeCell: View {

    var volume: Double
    var maxVolume: Double
    var type: KrakenBookRecordType
    @State var isHover = false
    var price: String
    var onLimit: (String) async -> Void
    let cellHeight: CGFloat = 25
    let cellWidth: CGFloat = 100
    var hoverColor: Color {
        return isHover ? Color("BidHover") : Color("Transparent")
    }
    
    var fill1: CGFloat {
        return round((volume / maxVolume) * 100)
    }
    
    var align: Alignment {
        return type == .ask ? .leading : .trailing
    }
    
    var textColor: Color {
        return type == .ask ? Color("AskTextColor") : Color("BidTextColor")
    }
    
    var volumeColor: Color {
        return type == .ask ? Color("RedLight") : Color("BlueLight")
    }
    
    var volumeFullColor: Color {
        return type == .ask ? .white : .white
    }
    
    var body: some View {
        let volStr = String(format: "%.0f", round(volume))
      
        Button(action: {
            Task {
                await onLimit(price)
            }
        }) {
            ZStack {
                HStack(spacing: 0) {
                    if type == .bid {
                        Rectangle().fill(volumeFullColor).frame(width: 100 - fill1)
                        Rectangle().fill(volumeColor).frame(width: fill1)
                    } else {
                        Rectangle().fill(volumeColor).frame(width: fill1)
                        Rectangle().fill(volumeFullColor).frame(width: 100 - fill1)
                    }
                }.frame(width: cellWidth, height: cellHeight)
                Text(volStr)
                    .frame(width: cellWidth, height: cellHeight, alignment: align)
                    .font(.system(.title3))
                    .foregroundColor(textColor).font(.system(.title3))
                    .background(Rectangle().fill(hoverColor))
                    .onHover { hover in
                        isHover = hover
                    }
            }
        }.buttonStyle(PlainButtonStyle())
            .frame(width: 100, height: 25)
    }
}

#Preview {
    VStack {
        LazyVGrid(columns: [GridItem(.fixed(100), spacing: 2),
                            GridItem(.fixed(100), spacing: 2),
                            GridItem(.fixed(100), spacing: 2),
                            GridItem(.fixed(100), spacing: 2),
                            GridItem(.fixed(100), spacing: 2)], spacing: 2) {
//            NoteCell()
            EmptyCell()
            PriceCell(price: "0.9888", depth: 25, up: true)
            VolumeCell(volume: 800, maxVolume: 200000, type: .ask, price: "0.999", onLimit: { print("\($0)") })
//            NoteCell()
            

        }
    }.frame(width: 400, height: 500)
}
