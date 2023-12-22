//
//  ContentView.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var kraken_ws = Krakenbook("MATIC/USD", 25)
    @StateObject var manager = KrakenOrderManager()

    var body: some View {
        VStack {
       
            HStack(alignment: .top) {
                HStack {
                    if kraken_ws.book != nil {
                        
                        HomeView().environmentObject(kraken_ws.book).environmentObject(manager)
                    } else {
                        Text("Connecting ... ")
                    }
                }
                
                
            }
           
        }
        .frame(minWidth: 1200, maxWidth: .infinity, minHeight: 1000, maxHeight: .infinity, alignment: .leading)
        .padding([.top, .bottom, .leading, .trailing], 2)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
