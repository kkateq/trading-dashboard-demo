//
//  BybitPairView.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import SwiftUI

struct BybitPairView: View {
    var pair: String
    
    var body: some View {
        BybitbookView(pair: Constants.PAIRS_ISO_NAMES_REV[pair]!)
    }
}

#Preview {
    BybitPairView(pair: "test")
}
