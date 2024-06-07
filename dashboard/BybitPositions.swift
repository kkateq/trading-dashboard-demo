//
//  BybitPositions.swift
//  dashboard
//
//  Created by km on 01/02/2024.
//

import SwiftUI

struct BybitPositions: View {
    var main: BybitAccountManager
    var cashmere: BybitAccountManager
    var neat: BybitAccountManager

    init() {
        self.main = BybitAccountManager(accountName: "main")
        self.cashmere = BybitAccountManager(accountName: "cashmere")
        self.neat = BybitAccountManager(accountName: "neat")
    }

    var positions: [BybitPositionDataIdentifiable] {
        var l: [BybitPositionDataIdentifiable] = []
        l.append(contentsOf: self.main.positions)
        l.append(contentsOf: self.cashmere.positions)
        l.append(contentsOf: self.neat.positions)
        return l
    }

    var body: some View {
        ScrollView {
            HStack {
//                Button(action: {
//                    Task {
////                        await accountManager.fetchPositions()
//                    }
//                }) {
//                    HStack {
//                        Text("Refresh positions")
//
//                    }.frame(width: 120, height: 20)
//                        .foregroundColor(Color.white)
//                        .clipShape(RoundedRectangle(cornerRadius: 5))
//                        .background(Color.gray)
//
//                }.buttonStyle(PlainButtonStyle())
                Spacer()
                Text("Positions  \(positions.count)")
  
                Text("Last fetched  \(formatDate(date: self.main.updated))")
            }
            VStack(alignment: .leading) {
                PositionsTable(positions: positions)
            }.frame(height: 1000)
        }
    }
}

#Preview {
    BybitPositions()
}
