//
//  HeatmapChart.swift
//  dashboard
//
//  Created by km on 21/12/2023.
//

import Charts
import SwiftUI

struct BoolLevel: Identifiable {
    let id = UUID()
    let price: Double
    let volume: Double
    let start: Double
    let end: Double
}

let data: [BoolLevel] = [
    BoolLevel(price: 1, volume: 34, start: 1542057314, end: 1742057314),
    BoolLevel(price: 2, volume: 340, start: 1542057314, end: 1742058314),
    BoolLevel(price: 3, volume: 134, start: 1542057314, end: 1742057314),
    BoolLevel(price: 4, volume: 4, start: 1532057314, end: 1742057314),
]

// let data2: [BoolLevel] = [
//    BoolLevel(price: 0.7888, volume: 34),
//    BoolLevel(price: 0.7887, volume: 140),
//    BoolLevel(price: 0.7886, volume: 134),
//    BoolLevel(price: 0.7885, volume: 400),
// ]
//
// let data3: [BoolLevel] = [
//    BoolLevel(price: 0.7888, volume: 4),
//    BoolLevel(price: 0.7887, volume: 340),
//    BoolLevel(price: 0.7886, volume: 124),
//    BoolLevel(price: 0.7885, volume: 400),
// ]

struct BookRecord: Identifiable {
    var id: UUID = .init()
    var price: String
    var volume: Double
    var color: Color
}

struct ImbalanceRecord: Identifiable {
    var id: UUID = .init()
    var volume: String
    var start: String
    var end: String
}

let asks = [
    BookRecord(price: "0.8989", volume: 30000, color: .red),
    BookRecord(price: "0.8988", volume: 30000, color: .red),
    BookRecord(price: "0.8987", volume: 3000, color: .red),
    BookRecord(price: "0.8986", volume: 3000, color: .red),
    BookRecord(price: "0.8985", volume: 300, color: .red),
]
let bids = [
    BookRecord(price: "0.8984", volume: 430000, color: .green),
    BookRecord(price: "0.8983", volume: 30000, color: .green),
    BookRecord(price: "0.8982", volume: 3000, color: .green),
    BookRecord(price: "0.8981", volume: 3000, color: .green),
    BookRecord(price: "0.8980", volume: 300, color: .green),
]

struct VolumeProfileChart: View {
    @EnvironmentObject var book: OrderBookData

    var body: some View {
        ScrollView {
            Chart {
                ForEach(book.allList) { record in
                    let color = record.type == .ask ? Color("AskTextColor") : Color("BidTextColor")
                    BarMark(
                        x: .value("Volume", Double(record.volume)!),
                        y: .value("Price", record.price)
                        
                    ).foregroundStyle(color)
                        .annotation(position: .overlay) {
                            Text("\(Int(Double(record.volume)!))") // Show the actual step count of that day
                                .font(.caption) // make the font a bit smalelr
                                .foregroundStyle(.white)
//                                .padding([.top, .bottom], 5)
                        }
                    
                }
                
                //            ForEach(book.allList) { record in
                //                RuleMark(y: .value("Average", Double(record.volume)!))
                //            }
                //                .foregroundStyle(.red)
                //            RuleMark(x: .value("Average", 80000))
                //                .foregroundStyle(.green)
                //            RuleMark(
                //                   x: .value("Volume", 430000),
                //                   yStart: .value("Start", "0.8987"),
                //                   yEnd: .value("End",  "0.8984")
                //
                //               )
                //            .foregroundStyle(Color.gray)
                //            .interpolationMethod(.monotone)
                
            }.chartYAxis(.hidden)
            
                .chartLegend(.hidden)
                .frame(width: 400, height: 1370)
                .padding([.top], 5)
        }
    }
}

#Preview {
    VolumeProfileChart()
}
