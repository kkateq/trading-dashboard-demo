//
//  BybitBPS.swift
//  dashboard
//
//  Created by km on 22/01/2024.
//

import SwiftUI

struct BybitBPS: View {
    @EnvironmentObject var book: BybitOrderBook
    var body: some View {
        Text("BPS")
    }
}

#Preview {
    BybitBPS()
}
