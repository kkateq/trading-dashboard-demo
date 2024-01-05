//
//  BybitStats.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import Foundation
import Charts

struct BybitStats {
    var pair: String
    var totalBidVol: Double = 0
    var totalAskVol: Double = 0
    var totalBidVol5: Double = 0
    var totalAskVol5: Double = 0
    var totalBidVol10: Double = 0
    var totalAskVol10: Double = 0
    var totalBidVolRaw: Double = 0
    var totalAskVolRaw: Double = 0
    var totalBidVol5Raw: Double = 0
    var totalAskVol5Raw: Double = 0
    var totalBidVol10Raw: Double = 0
    var totalAskVol10Raw: Double = 0

    var bestBid: Double = 0
    var bestAsk: Double = 0
    var bestBidVolume: Double = 0
    var bestAskVolume: Double = 0
    var maxVolume: Double = 0
    var time: Date
    var ask_bins: NumberBins<Double>
    var bid_bins: NumberBins<Double>
    var ask_groups: [Int: [Array<Double>.Element]]
    var bid_groups: [Int: [Array<Double>.Element]]

    var askVolumeCutOff: Double = 0
    var bidVolumeCutOff: Double = 0

    var all: [Double: BybitBookRecord]
    var bid_keys = [Double]()
    var ask_keys = [Double]()
    var isUp: Bool = true

    init(pair: String, all: [Double: BybitBookRecord], bid_keys: [Double], ask_keys: [Double]) {
        time = Date()
        self.pair = pair
        self.all = all
        self.bid_keys = bid_keys
        self.ask_keys = ask_keys
        let ask_volumes = ask_keys.map { all[$0]!.vol }

        ask_bins = NumberBins(
            data: ask_volumes,
            desiredCount: 3
        )
        ask_groups = Dictionary(
            grouping: ask_volumes,
            by: ask_bins.index
        )

        let bid_volumes = bid_keys.map { all[$0]!.vol }

        bid_bins = NumberBins(
            data: bid_volumes,
            desiredCount: 3
        )

        bid_groups = Dictionary(
            grouping: bid_volumes,
            by: bid_bins.index
        )

        if let avVol = Constants.pairSettings[pair] {
            if ask_groups.values.count > 0 {
                askVolumeCutOff = ask_groups.suffix(1)[0].value[0]

                if askVolumeCutOff < avVol.averageVolume {
                    askVolumeCutOff = Constants.pairSettings[pair]!.averageVolume
                }
            }

            if bid_groups.values.count > 0 {
                bidVolumeCutOff = bid_groups.suffix(1)[0].value[0]

                if bidVolumeCutOff < avVol.averageVolume {
                    bidVolumeCutOff = Constants.pairSettings[pair]!.averageVolume
                }
            }
        }

        totalAskVol = getAskVolume()
        totalBidVol = getBidVolume()
        totalAskVol5 = getAskVolume(levels: 5)
        totalBidVol5 = getBidVolume(levels: 5)
        totalAskVol10 = getAskVolume(levels: 10)
        totalBidVol10 = getBidVolume(levels: 10)

        totalAskVolRaw = getAskVolume(raw: true)
        totalBidVolRaw = getBidVolume(raw: true)
        totalAskVol5Raw = getAskVolume(levels: 5, raw: true)
        totalBidVol5Raw = getBidVolume(levels: 5, raw: true)
        totalAskVol10Raw = getAskVolume(levels: 10, raw: true)
        totalBidVol10Raw = getBidVolume(levels: 10, raw: true)

        bestBid = bid_keys.count > 0 ? all[bid_keys[0]]!.pr : 0.0
        bestAsk = ask_keys.count > 0 ? all[ask_keys[0]]!.pr : 0.0
        bestBidVolume = bid_keys.count > 0 ? all[bid_keys[0]]!.vol : 0.0
        bestAskVolume = ask_keys.count > 0 ? all[ask_keys[0]]!.vol : 0.0

        maxVolume = all.values.max(by: { $0.vol < $1.vol })!.vol
    }

    func filterAskVolume(_ vol: Double) -> Double {
        return vol >= askVolumeCutOff ? 0 : vol
    }

    func filterBidVolume(_ vol: Double) -> Double {
        return vol >= bidVolumeCutOff ? 0 : vol
    }

    func getBidVolume(levels: Int = 0, raw: Bool = false) -> Double {
        if raw {
            if levels == 0 {
                return bid_keys.reduce(0) { $0 + all[$1]!.vol }
            }
            return bid_keys.prefix(levels).reduce(0) { $0 + all[$1]!.vol }
        } else {
            if levels == 0 {
                return bid_keys.reduce(0) { $0 + filterBidVolume(all[$1]!.vol) }
            }
            return bid_keys.prefix(levels).reduce(0) { $0 + filterBidVolume(all[$1]!.vol) }
        }
    }

    private func getAskVolume(levels: Int = 0, raw: Bool = false) -> Double {
        if raw {
            if levels == 0 {
                return ask_keys.reduce(0) { $0 + all[$1]!.vol }
            }
            return ask_keys.prefix(levels).reduce(0) { $0 + all[$1]!.vol }
        } else {
            if levels == 0 {
                return ask_keys.reduce(0) { $0 + filterAskVolume(all[$1]!.vol) }
            }
            return ask_keys.prefix(levels).reduce(0) { $0 + filterAskVolume(all[$1]!.vol) }
        }
    }

    var pegValue: Double {
        return (bestBid + bestAsk) / 2
    }

    var totalAskVolumePerc: Double {
        return round((totalAskVol / (totalAskVol + totalBidVol)) * 100)
    }

    var totalBidVolumePerc: Double {
        return round((totalBidVol / (totalAskVol + totalBidVol)) * 100)
    }

    var totalAskRawVolumePerc: Double {
        return round((totalAskVolRaw / (totalAskVolRaw + totalBidVolRaw)) * 100)
    }

    var totalBidRawVolumePerc: Double {
        return round((totalBidVolRaw / (totalAskVolRaw + totalBidVolRaw)) * 100)
    }
}
