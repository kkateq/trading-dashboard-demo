//
//  NotificationsView.swift
//  dashboard
//
//  Created by km on 22/01/2024.
//

import SwiftUI

struct ConfigurationView: View {
    var pair: String
    var bybitbook_ws: Bybitbook
    @State var isBookSocketReady: Bool = false

    init(pair: String) {
        self.pair = pair
        self.bybitbook_ws = Bybitbook(self.pair, 1)
    }

    func setBookReady(_ publishedBook: BybitOrderBook!) {
        if !isBookSocketReady && publishedBook != nil {
            isBookSocketReady = true
        }
    }

    var body: some View {
        VStack {
            if isBookSocketReady {
                BybitPriceLevelFormView(pair: self.pair)
                    .environmentObject(bybitbook_ws.book)
            } else {
                Text("Connecting...")
            }
        }
        .onReceive(bybitbook_ws.$book, perform: setBookReady)
    }
}

#Preview {
    ConfigurationView(pair: "")
}
