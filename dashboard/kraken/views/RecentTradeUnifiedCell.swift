//
//  RecentTradeCell.swift
//  dashboard
//
//  Created by km on 22/12/2023.
//

import SwiftUI

struct RecentTradeUnifiedCell: View {
    var trade: KrakenRecentTrade
    var recentTrades: KrakenRecentTradesData
    var book: KrakenOrderBookData
    
    let cellHeight: CGFloat = 25
    let cellWidth: CGFloat = 100
    
    var sellMarket: Double {
        return trade.sellMarket
    }
    
    var buyMarket: Double {
        return trade.buyMarket
    }
    
    var buyLimit: Double {
        return trade.buyLimit
    }
    
    var sellLimit: Double {
        return trade.sellLimit
    }
    
    var maxVolume: Double {
        return recentTrades.maxSellLimitVolume + recentTrades.maxBuyLimitVolume + recentTrades.maxSellMarketVolume + recentTrades.maxBuyMarketVolume
    }

    var fill1: CGFloat {
        let k = round((totalVolume / maxVolume) * 100)
        return k
    }
    

    
    var fill2: CGFloat {
        let res = 100 - fill1
        if res < 0 {
            return 0
        }
        return res
    }
    

    var totalVolume: Double {
        return sellLimit + sellMarket + buyLimit + buyMarket
    }

    var body: some View {


        let totalVolume = sellLimit + sellMarket + buyLimit + buyMarket
        let totalVolumeStr = String(format: "%.0f", totalVolume)
        let price = formatPrice(price: trade.price)
        HStack {
            Text(price).frame(width: cellWidth, height: cellHeight)
                .font(.caption)
                .background(.white)
        }
        ZStack {
            HStack(spacing: 0) {
                Rectangle().fill(Color("Bar1")).frame(width: fill1, height: 25)
                Rectangle().fill(.white).frame(width: fill2, height: 25)
              
      
            }.frame(width: cellWidth, height: cellHeight)
            Text(totalVolumeStr)
                .frame(width: cellWidth, height: cellHeight, alignment: .trailing)
                .font(.system(.caption))
                .foregroundColor(Color("Bar1")).font(.system(.title3))
        }
  
    
           
    }
}

#Preview {
    VStack {

    }.frame(width: 700, height: 500)
}
