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
                
                Group {
                    NavigationLink(destination: BybitPositions()){
                                                Label("All Positions", systemImage: "house")
                                            }
                }

//
//                Group {
//                    NavigationLink(destination: PairsCardsView(list: list)) {
//                        Label("Home", systemImage: "house")
//                    }
//                    
//                }
//                Spacer()
//                
//                Text("NOTIFICATIONS")
//                    .font(.system(size: 10))
//                    .fontWeight(.bold)
//                Group {
//                    ForEach(list, id: \.self) { pair in
//                        NavigationLink(destination: ConfigurationView(pair: pair)) {
//                            Label(pair, systemImage: "mail")
//                        }
//                    }
//                }
//                Spacer()
//                
//                Text("TRADING")
//                Group {
//                    ForEach(list, id: \.self) { pair in
//                        NavigationLink(destination: DashboardView(pair: pair)) {
//                            Label(pair, systemImage: "book.closed.fill")
//                        }
//                    }
//                }
            }
           
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
