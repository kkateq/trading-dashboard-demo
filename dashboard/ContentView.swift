//
//  ContentView.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
           
            List {
                Spacer()

                Text("NOTIFICATIONS")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                Group {
                    NavigationLink(destination: ConfigurationView(pair: "AVAXUSDT")) {
                        Label("AVAXUSDT", systemImage: "mail")
                    }
                    NavigationLink(destination: ConfigurationView(pair: "MATICUSDT")) {
                        Label("MATICUSDT", systemImage: "mail")
                    }
                }
                Spacer()
                
                Text("TRADING")
                Group {
                    NavigationLink(destination: DashboardView(pair: "AVAXUSDT")) {
                        Label("AVAXUSDT", systemImage: "book.closed.fill")
                    }
                    NavigationLink(destination: DashboardView(pair: "MATICUSDT")) {
                        Label("MATICUSDT", systemImage: "book.closed.fill")
                    }
                }
            }
            VStack {
                PairsCardsView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
