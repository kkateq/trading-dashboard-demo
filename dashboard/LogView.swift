//
//  LofView.swift
//  dashboard
//
//  Created by km on 18/12/2023.
//

import SwiftUI

struct LogView: View {
    @EnvironmentObject var logger: LogManager

    func getColor(level: LogLevel) -> Color {
        var color = Color.black
        
        if level == LogLevel.warning {
            color = Color.orange
        } else if level == LogLevel.error {
            color = Color("Red")
        } else if level == LogLevel.action {
            color = Color("Blue")
        }
        return color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Divider()
            HStack {
                Text("Log")
                    .font(.caption)
                Spacer()
            }
           
            List(logger.logMessages.reversed()) { log in
                Text(log.text)
                    .font(.caption)
                    .foregroundColor(getColor(level: log.level))
            }.listStyle(.bordered)
            Divider()
        }.frame(width: 300)
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
