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
        var color = Color.gray
        
        if level == LogLevel.warning {
            color = Color.orange
        } else if level == LogLevel.error {
            color = Color.red
        }
        return color
    }
    
    var body: some View {
        VStack {
            List(logger.logMessages) { log in
                Text(log.text)
                    .font(.caption)
                    .foregroundColor(getColor(level: log.level))
            }
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
