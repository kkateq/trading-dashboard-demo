//
//  ContentView.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedPair = ""
    var body: some View {
        VStack(alignment: .leading) {
            if selectedPair == "" {
                Picker("Pair", selection: $selectedPair) {
                    ForEach([""]+Constants.pairs, id: \.self) {
                        Text($0)
                    }
                }.frame(width: 200)
              
            }

            else {
                DashboardView(pair: selectedPair)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
