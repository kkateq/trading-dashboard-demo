//
//  VolumeChart.swift
//  dashboard
//
//  Created by km on 26/12/2023.
//

import Charts
import SwiftUI

struct RawVolumeChart: View {
    @EnvironmentObject var book: KrakenOrderBookData
    let cellWidth = 300.0
    
    @State var totalAskVolumePerc: Int = 0
    @State var totalAskCellWidth: Double = 0
    
    @State var totalAskVolume5Perc: Int = 0
    @State var totalAskCellWidth5: Double = 0
    
    @State var totalAskVolume10Perc: Int = 0
    @State var totalAskCellWidth10: Double = 0
    
    func updateChart(_ publishedStats: KrakenStats!) {
        if let stats = publishedStats {
            let totalAskVolume = stats.totalAskVolRaw
            let totalBidVolume = stats.totalBidVolRaw
            let totalAskVol5 = stats.totalAskVol5Raw
            let totalBidVol5 = stats.totalBidVol5Raw
            let totalAskVol10 = stats.totalAskVol10Raw
            let totalBidVol10 = stats.totalBidVol10Raw
            
            if totalAskVolume + totalBidVolume > 0 {
                let totalAskPerc = round(100 * (totalAskVolume / (totalAskVolume + totalBidVolume)))
                if totalAskPerc > 0 && totalAskPerc <= 100 {
                    self.totalAskVolumePerc = Int(totalAskPerc)
                    self.totalAskCellWidth = self.cellWidth * (totalAskPerc / 100)
                }
            }
            if totalAskVol5 + totalBidVol5 > 0 {
                let totalAskPerc5 = round(100 * (totalAskVol5 / (totalAskVol5 + totalBidVol5)))
                if totalAskPerc5 > 0 && totalAskPerc5 < 100 {
                    self.totalAskVolume5Perc = Int(totalAskPerc5)
                    self.totalAskCellWidth5 = self.cellWidth * (totalAskPerc5 / 100)
                }
            }
            if totalAskVol10 + totalBidVol10 > 0 {
                let totalAskPerc10 = round(100 * (totalAskVol10 / (totalAskVol10 + totalBidVol10)))
                if totalAskPerc10 > 0 && totalAskPerc10 < 100 {
                    self.totalAskVolume10Perc = Int(totalAskPerc10)
                    self.totalAskCellWidth10 = self.cellWidth * (totalAskPerc10 / 100)
                }
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Text("Top 5").font(.caption).frame(height: 25)
                Text("Top 10").font(.caption).frame(height: 25)
                Text("Top 25").font(.caption).frame(height: 25)
            }
            VStack {
                VStack {
                    ZStack {
                        HStack(spacing: 0) {
                            Rectangle().fill(Color("BidTextColor")).frame(width: cellWidth - Double(totalAskCellWidth5), height: 25)
                            Rectangle().fill(Color("AskTextColor")).frame(width: totalAskCellWidth5, height: 25)
                            
                        }.frame(width: cellWidth, height: 25)
                        HStack {
                            Text("\(100 - totalAskVolume5Perc) %").foregroundStyle(.white).frame(width: cellWidth - totalAskCellWidth5, height: 25)
                            Text("\(totalAskVolume5Perc) %").foregroundStyle(.white).frame(width: totalAskCellWidth5, height: 25)
                        }.frame(width: cellWidth, height: 25)
                    }
                }
                VStack {
                    ZStack {
                        HStack(spacing: 0) {
                            Rectangle().fill(Color("BidTextColor")).frame(width: cellWidth - totalAskCellWidth10, height: 25)
                            Rectangle().fill(Color("AskTextColor")).frame(width: totalAskCellWidth10, height: 25)
                            
                        }.frame(width: cellWidth, height: 25)
                        HStack {
                            Text("\(100 - totalAskVolume10Perc) %").foregroundStyle(.white).frame(width: cellWidth - totalAskCellWidth10, height: 25)
                            Text("\(totalAskVolume10Perc) %").foregroundStyle(.white).frame(width: totalAskCellWidth10, height: 25)
                        }.frame(width: cellWidth, height: 25)
                    }
                }
                VStack {
                    ZStack {
                        HStack(spacing: 0) {
                            Rectangle().fill(Color("BidTextColor")).frame(width: cellWidth - totalAskCellWidth, height: 25)
                            Rectangle().fill(Color("AskTextColor")).frame(width: totalAskCellWidth, height: 25)
                            
                        }.frame(width: cellWidth, height: 25)
                        HStack {
                            Text("\(100 - totalAskVolumePerc) %").foregroundStyle(.white).frame(width: cellWidth - totalAskCellWidth, height: 25)
                            Text("\(totalAskVolumePerc) %").foregroundStyle(.white).frame(width: totalAskCellWidth, height: 25)
                        }.frame(width: cellWidth, height: 25)
                    }
                }
            }
        }
        .frame(height: 100)
        .onReceive(book.$stats, perform: updateChart)
    }
}

#Preview {
    RawVolumeChart()
}
