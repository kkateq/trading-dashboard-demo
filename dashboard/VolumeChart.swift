//
//  VolumeChart.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import Charts
import SwiftUI

struct VolumeChart: View {
    @EnvironmentObject var book: OrderBookData
    let cellWidth = 300.0
    var body: some View {
        
        let totalAskPerc = book.stats.totalAskVol/(book.stats.totalAskVol + book.stats.totalBidVol)
        let fillTotalAsk = CGFloat(cellWidth * totalAskPerc)
        
        let total5AskPerc = book.stats.totalAskVol5/(book.stats.totalAskVol5 + book.stats.totalBidVol5)
        let fillTotalAsk5 = CGFloat(cellWidth * total5AskPerc)
        
        let total10AskPerc = book.stats.totalAskVol10/(book.stats.totalAskVol10 + book.stats.totalBidVol10)
        let fillTotalAsk10 = CGFloat(cellWidth * total10AskPerc)
        
        HStack {
            VStack {
                Text("Top 5").font(.caption).frame(height: 25)
                Text("Top 10").font(.caption).frame( height: 25)
                Text("Top 25").font(.caption).frame( height: 25)
            }
            VStack {
                VStack {
                    ZStack {
                        HStack(spacing: 0) {
                            Rectangle().fill(Color("BidTextColor")).frame(width: cellWidth - fillTotalAsk5, height: 25)
                            Rectangle().fill(Color("AskTextColor")).frame(width: fillTotalAsk5, height: 25)
                            
                        }.frame(width: cellWidth, height: 25)
                        HStack {
                            Text("\(100 - Int(total5AskPerc * 100)) %").foregroundStyle(.white).frame(width: cellWidth - fillTotalAsk5, height: 25)
                            Text("\(Int(total5AskPerc * 100)) %").foregroundStyle(.white).frame(width: fillTotalAsk5, height: 25)
                        }.frame(width: cellWidth, height: 25)
                    }
                    
                }
                VStack {
                    ZStack {
                        HStack(spacing: 0) {
                            Rectangle().fill(Color("BidTextColor")).frame(width: cellWidth - fillTotalAsk10, height: 25)
                            Rectangle().fill(Color("AskTextColor")).frame(width: fillTotalAsk10, height: 25)
                            
                        }.frame(width: cellWidth, height: 25)
                        HStack {
                            Text("\(100 - Int(total10AskPerc * 100)) %").foregroundStyle(.white).frame(width: cellWidth - fillTotalAsk10, height: 25)
                            Text("\(Int(total10AskPerc * 100)) %").foregroundStyle(.white).frame(width: fillTotalAsk10, height: 25)
                        }.frame(width: cellWidth, height: 25)
                    }
                    
                }
                VStack {
                    
                    ZStack {
                        HStack(spacing: 0) {
                            Rectangle().fill(Color("BidTextColor")).frame(width: cellWidth - fillTotalAsk, height: 25)
                            Rectangle().fill(Color("AskTextColor")).frame(width: fillTotalAsk, height: 25)
                            
                        }.frame(width: cellWidth, height: 25)
                        HStack {
                            Text("\(100 - Int(totalAskPerc * 100)) %").foregroundStyle(.white).frame(width: cellWidth - fillTotalAsk, height: 25)
                            Text("\(Int(totalAskPerc * 100)) %").foregroundStyle(.white).frame(width: fillTotalAsk, height: 25)
                        }.frame(width: cellWidth, height: 25)
                    }
                    
                }
            }
        }
        .frame(height: 100)
    }
}

#Preview {
    VolumeChart()
}
