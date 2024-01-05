//
//  BybitbookView.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import SwiftUI

struct BybitbookView: View {
    var pair: String

    var bybitbook: Bybitbook

    init(pair: String) {
        self.pair = pair
        self.bybitbook = Bybitbook(self.pair)
    }

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BybitbookView(pair: "test")
}
