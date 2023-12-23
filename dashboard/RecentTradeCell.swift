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

    var fillAsk1: CGFloat {
        let k = round(((sellMarket + sellLimit) / (maxSellLimitVolume + maxBuyMarketVolume)) * 100)
        return k
    }
    
    var fillBid1: CGFloat {
        let p = round(((buyMarket + buyLimit) / (maxBuyLimitVolume + maxBuyMarketVolume)) * 100)
        return p
    }
    
    var fillAsk2: CGFloat {
        let res = 100 - fillAsk1
        if res < 0 {
            return 0
        }
        return res
    }
    
    var fillBid2: CGFloat {
        let res = 100 - fillBid1
        if res < 0 {
            return 0
        }
        return res
    }
    
    var body: some View {
        let sellVolumeStr = String(format: "%.0f", round(sellLimit + sellMarket))
        let buyVolumeStr = String(format: "%.0f", round(buyLimit + buyMarket))
        HStack(spacing: 0) {
            ZStack {
                HStack(spacing: 0) {
                    Rectangle().fill(.white).frame(width: fillBid2, height: 25)
                    Rectangle().fill(Color("GreenLight")).frame(width: fillBid1, height: 25)
      
                }.frame(width: cellWidth, height: cellHeight)
                Text(buyVolumeStr)
                    .frame(width: cellWidth, height: cellHeight, alignment: .trailing)
                    .font(.system(.caption))
                    .foregroundColor(Color("GreenDarker")).font(.system(.title3))
              
            }
            Divider()
            ZStack {
                HStack(spacing: 0) {
                   
                    Rectangle().fill(Color("RedLight")).frame(width: fillAsk1, height: 25)
                    Rectangle().fill(.white).frame(width: fillAsk2, height: 25)
                    
                }.frame(width: cellWidth, height: cellHeight)
              
                Text(sellVolumeStr)
                    .frame(width: cellWidth, height: cellHeight, alignment: .leading)
                    .font(.system(.caption))
                    .foregroundColor(Color("RedDarker")).font(.system(.title3))
            }
        }
        .frame(width: 200, height: 25)
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
            RecentTradeCell(price: 0.5055)
            
            PositionCell(position: "")
            EmptyCell()
            PriceCell(price: "0.9888", depth: 25, level: 1)
            VolumeCell(volume: 8700, maxVolume: 200000, type: .ask, price: "0.997", onLimit: { print("\($0)") })
            RecentTradeCell(price: 0.5055)
            
            RecentTradeCell(price: 0.5055)
            VolumeCell(volume: 87000, maxVolume: 200000, type: .bid, price: "0.997", onLimit: { print("\($0)") })
            PriceCell(price: "0.9888", depth: 25, level: 1)
            EmptyCell()
            PositionCell(position: "")
            
            RecentTradeCell(price: 0.5055)
            VolumeCell(volume: 7000, maxVolume: 20000, type: .bid, price: "0.997", onLimit: { print("\($0)") })
            PriceCell(price: "0.9888", depth: 25, level: 1)
            EmptyCell()
            PositionCell(position: "")
        }
    }.frame(width: 700, height: 500)
}
