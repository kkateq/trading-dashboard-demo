//
//  BybitPositionsView.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import SwiftUI

struct BybitPositionsView: View {
    @EnvironmentObject var manager: KrakenOrderManager
    @EnvironmentObject var book: KrakenOrderBookData
    var useREST: Bool
    var validate: Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BybitPositionsView(useREST: true, validate: true)
}
