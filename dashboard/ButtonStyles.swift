//
//  ButtonStyles.swift
//  dashboard
//
//  Created by km on 15/12/2023.
//

import Foundation
import SwiftUI

struct CustomizeWithPressed: ButtonStyle {
    typealias Body = Button
    var color1: Color
    var color2: Color
    
  
    func makeBody(configuration: Self.Configuration)
-> some View {
        if configuration.isPressed {
            return configuration
                .label
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 5)
                .background(color2)
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        } else {
            return configuration
                .label
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 5)
                .background(color1)
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}
