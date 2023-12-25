//
//  GridOverlay.swift
//  dashboard
//
//  Created by km on 22/12/2023.
//

import SwiftUI

struct GridOverlay: View {
    var body: some View {
        VStack {
//            ForEach(0 ... 30, id: \.self) { i in
//                Rectangle()
//                    .fill(i == 15 ? Color("Blue") : Color("GuideLine"))
//                    .frame(height: i == 16 ? 2 : 1)
//                    .edgesIgnoringSafeArea(.horizontal)
                Rectangle()
                .fill(.gray)
                    .frame(width: .infinity ,height: 2)
                    .edgesIgnoringSafeArea(.horizontal)
                   
//            }
        }

        .ignoresSafeArea()
//        .frame(width: 1000, height: 1000)
    }
}

#Preview {
    GridOverlay()
}
