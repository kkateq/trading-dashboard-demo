//
//  BybitOrdersView.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import SwiftUI

struct BybitOrdersView: View {
    @EnvironmentObject var manager: KrakenOrderManager
    var useREST: Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BybitOrdersView(useREST: false)
}
