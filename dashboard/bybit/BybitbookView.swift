//
//  BybitbookView.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import SwiftUI

struct BybitbookView: View {
    var pair: String
    var bybitbook_ws: Bybitbook
    @State var isReady: Bool = false
    
    init(pair: String) {
        self.pair = pair
        self.bybitbook_ws = Bybitbook(self.pair)
    }
    
    func setReady(_ publishedBook: BybitOrderBook!) {
        if !isReady && publishedBook != nil {
            isReady = true
        }
    }
    

    var body: some View {
        VStack(alignment: .center) {
            if isReady {
                BybitOrderBookView()
                    .environmentObject(bybitbook_ws.book)
                
            } else {
                Text("Connecting...")
                    .font(.title3).foregroundStyle(.blue)
            }
        }.onReceive(bybitbook_ws.$book, perform: setReady)
    }
}

#Preview {
    BybitbookView(pair: "test")
}
