//
//  PairsCardsView.swift
//  dashboard
//
//  Created by km on 23/01/2024.
//

import SwiftUI
import SwiftySound

struct PairsCardsView: View {
    var list: [String]
    let layout = [
        GridItem(.fixed(350), spacing: 2),
        GridItem(.fixed(350), spacing: 2)
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Button(action: {
                    Task {
                        if SoundHandler.shared.muted { SoundHandler.shared.unmute()
                        } else { SoundHandler.shared.mute() }
                    }
                }) {
                    HStack {
                        Text( SoundHandler.shared.muted ? "Unmute" : "Mute")
                    }.frame(width: 150, height: 30)
                        .foregroundColor(Color.white)
                        .background(Color("Green"))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .imageScale(.large)
                }.buttonStyle(PlainButtonStyle())
         
            }
            LazyVGrid(columns: layout) {
                ForEach(list, id: \.self) { pair in
                    PairAlertWrapper(pair: pair)
                }
               
            }
        }
    }
}

#Preview {
    PairsCardsView(list: [])
}
