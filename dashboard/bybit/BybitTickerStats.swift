//
//  BybitTickerStats.swift
//  dashboard
//
//  Created by km on 15/01/2024.
//

import SwiftUI

struct BybitTickerStats: View {
    @State var bestBid: String = ""
    @State var bestAsk: String = ""
    @State var high: String=""
    @State var low: String=""
    @State var change: String=""
    
    @EnvironmentObject var instrumentStats: BybitInstrumentStats
    
   
    func updateStats(_ p: BybitTickerData!) -> Void {
        if let pricing = p {
            if let ask = pricing.ask1Price {
                bestAsk = ask
            }
            if let bid = pricing.bid1Price {
                bestBid = bid
            }
            if let h = pricing.highPrice24h {
                high = h
            }
            if let l = pricing.lowPrice24h {
                low = l
            }
            
            if let c = pricing.price24hPcnt {
                change = c
            }
        }
    }
    
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("24h change").font(.caption).foregroundStyle(.gray)
                    Text("\(change)").font(.title).foregroundStyle(change.starts(with: "-") ? .red : .green)
                }
                Divider()
                VStack(alignment: .leading) {
                    Text("BID").font(.caption).foregroundStyle(.gray)
                    Text("\(bestBid)").font(.title).foregroundStyle(.blue)
                }
                Divider()
                VStack(alignment: .leading)  {
                    Text("ASK").font(.caption).foregroundStyle(.gray)
                    Text("\(bestAsk)").font(.title).foregroundStyle(.pink)
                }
                //            Divider()
                //            VStack(alignment: .leading)  {
                //                Text("24h High").font(.caption).foregroundStyle(.gray)
                //                Text("\(high)").font(.title)
                //            }
                //            Divider()
                //                VStack(alignment: .leading)  {
                //                Text("24h Low").font(.caption).foregroundStyle(.gray)
                //                Text("\(low)").font(.title)
                //            }
            }
            .padding()
        }.onReceive(instrumentStats.$stats, perform: updateStats)
            .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(.gray, lineWidth: 2)
                ).padding()
    }
}

#Preview {
    BybitTickerStats()
}
