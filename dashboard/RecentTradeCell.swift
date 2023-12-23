//
//  RecentTradeCell.swift
//  dashboard
//
//  Created by km on 22/12/2023.
//

import SwiftUI

struct RecentTradeCell: View {
    @EnvironmentObject var recentTrades: RecentTradesData
    
    var price: Double
    var side: BookRecordType
    let cellHeight: CGFloat = 25
    let cellWidth: CGFloat = 100
    
    var sellMarket: Double {
        if let trade = recentTrades.trades[price] {
            return trade.sellMarket
        }
        else {
            return 0
        }
    }
    
    var buyMarket: Double {
        if let trade = recentTrades.trades[price] {
            return trade.buyMarket
        }
        else {
            return 0
        }
    }
    
    var buyLimit: Double {
        if let trade = recentTrades.trades[price] {
            return trade.buyLimit
        }
        else {
            return 0
        }
    }
    
    var sellLimit: Double {
        if let trade = recentTrades.trades[price] {
            return trade.sellLimit
        }
        else {
            return 0
        }
    }
    
    var maxSellLimitVolume: Double {
        return recentTrades.maxSellLimitVolume
    }

    var maxBuyLimitVolume: Double {
        return recentTrades.maxBuyLimitVolume
    }
    
    var maxSellMarketVolume: Double {
        return recentTrades.maxSellMarketVolume
    }
    
    var maxBuyMarketVolume: Double {
        return recentTrades.maxBuyMarketVolume
    }

    var fill1: CGFloat {
        if side == .ask {
            return round(((sellMarket + sellLimit) / (maxSellLimitVolume + maxBuyMarketVolume)) * 100)
        }
        else {
            return round(((buyMarket + buyLimit) / (maxBuyLimitVolume + maxBuyMarketVolume)) * 100)
        }
    }
    
    var align: Alignment {
        return side == .bid ? .leading : .trailing
    }
    
    var textColor: Color {
        return side == .ask ? Color("AskTextColor") : Color("BidTextColor")
    }
    
    var volumeColor: Color {
        return side == .ask ? Color("RedLight") : Color("BlueLight")
    }
    
    var volumeFullColor: Color {
        return side == .ask ? .white : .white
    }
    
    var body: some View {
        let volStr = String(format: "%.0f", side == .bid ? round(buyLimit + buyMarket) : round(sellLimit + sellMarket))
        ZStack {
            HStack(spacing: 0) {
                if side == .bid {
                    Rectangle().fill(volumeFullColor).frame(width: 100 - fill1)
                    Rectangle().fill(volumeColor).frame(width: fill1)
                }
                else {
                    Rectangle().fill(volumeColor).frame(width: fill1)
                    Rectangle().fill(volumeFullColor).frame(width: 100 - fill1)
                }
            }.frame(width: cellWidth, height: cellHeight)
            Text(volStr)
                .frame(width: cellWidth, height: cellHeight, alignment: align)
                .font(.system(.caption))
                .foregroundColor(Color("LightGray")).font(.system(.title3))
        }
        .frame(width: 100, height: 25)
    }
}

#Preview {
    VStack {
        LazyVGrid(columns: [GridItem(.fixed(100), spacing: 2),
                            GridItem(.fixed(100), spacing: 2),
                            GridItem(.fixed(100), spacing: 2),
                            GridItem(.fixed(100), spacing: 2),
                            GridItem(.fixed(100), spacing: 2)], spacing: 2) {
            PositionCell(position: "")
            EmptyCell()
            PriceCell(price: "0.9888", depth: 25, level: 1)
            VolumeCell(volume: 800, maxVolume: 200000, type: .ask, price: "0.999", onLimit: { print("\($0)") })
            RecentTradeCell(price: 0.5055, side: .ask)
            
            PositionCell(position: "")
            EmptyCell()
            PriceCell(price: "0.9888", depth: 25, level: 1)
            VolumeCell(volume: 8700, maxVolume: 200000, type: .ask, price: "0.997", onLimit: { print("\($0)") })
            RecentTradeCell(price: 0.5055, side: .ask)
            
            RecentTradeCell(price: 0.5055, side: .bid)
            VolumeCell(volume: 87000, maxVolume: 200000, type: .bid, price: "0.997", onLimit: { print("\($0)") })
            PriceCell(price: "0.9888", depth: 25, level: 1)
            EmptyCell()
            PositionCell(position: "")
            
            RecentTradeCell(price: 0.5055, side: .bid)
            VolumeCell(volume: 7000, maxVolume: 20000, type: .bid, price: "0.997", onLimit: { print("\($0)") })
            PriceCell(price: "0.9888", depth: 25, level: 1)
            EmptyCell()
            PositionCell(position: "")
        }
    }.frame(width: 700, height: 500)
}
