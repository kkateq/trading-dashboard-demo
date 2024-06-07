//
//  BybitPrivateManager.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import CodableCSV
import Combine
import CryptoSwift
import Foundation

struct BybitTransactionData: Decodable, Equatable {
    var id: String
    var symbol: String
    var side: String
    var funding: String
    var orderLinkId: String
    var orderId: String
    var fee: String
    var change: String
    var cashFlow: String
    var transactionTime: String
    var type: String
    var feeRate: String
    var bonusChange: String
    var size: String
    var qty: String
    var cashBalance: String
    var currency: String
    var category: String
    var tradePrice: String
    var tradeId: String
}

struct BybitPositionDataIdentifiable: Identifiable, Hashable {
    var data: BybitPositionData
    var id: UUID
    var accountName: String

    init(data: BybitPositionData, accountName: String) {
        self.data = data
        self.id = UUID()
        self.accountName = accountName
        
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

class BybitAccountManager: ObservableObject {
    var accountName: String

    @Published var positions: [BybitPositionDataIdentifiable] = []

    @Published var orders: [BybitOrderData] = []

    @Published var transactions: [BybitTransactionData] = []

    @Published var wallet: [BybitWalletData] = []

    private var timer: Timer!
    
    @Published var updated: Date
    
    var totalAvailableWalletBalance: Double {
        return self.getWalletBalance()
    }

    var totalAvailableUSDT: Double {
        if self.wallet.count > 0 {
            if let item = wallet.first(where: { $0.accountType == "UNIFIED" }) {
                let coins = item.coin
                if let usdt = coins.first(where: { $0.coin == "USDT" }), usdt.walletBalance != "" {
                    return Double(usdt.walletBalance)!
                }
            }
        }
        return -1
    }

    func getWalletBalance(walletName: String = "UNIFIED") -> Double {
        if self.wallet.count > 0 {
            if let item = wallet.first(where: { $0.accountType == walletName }) {
                return item.totalWalletBalance != "" ? Double(item.totalWalletBalance)! : 0
            }
        }

        return -1
    }

    init(accountName: String) {
        self.wallet = []
        self.positions = []
        self.orders = []
        self.transactions = []
        self.accountName = accountName
        self.updated = Date()
        self.timer = Timer.scheduledTimer(withTimeInterval: 500, repeats: true, block: { _ in
            Task {
                self.updated = Date()
                await self.fetchPositions()
            }
        })

        Task {
            await fetchTransactionLog()
            await fetchPositions()
//            await fetchOrders()
//            await fetchBalance()
        }
    }

    func transformPositions(list: [BybitPositionData]) -> [BybitPositionDataIdentifiable] {
        var res: [BybitPositionDataIdentifiable] = []
        for item in list {
            res.append(BybitPositionDataIdentifiable(data: item, accountName: self.accountName))
        }
        return res
    }

    func fetchPositions(pair: String! = nil) async {
        await BybitRestApi.fetchPositions(cb: {
            do {
                let res = try JSONDecoder().decode(BybitListRestBase<BybitPositionData>.self, from: $0)

                if res.retCode == 0 {
                    DispatchQueue.main.async {
                        self.positions = self.transformPositions(list: res.result.list)
                    }
                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
                print(String(decoding: $0, as: UTF8.self))
            }
        }, symbol: pair, accountName: self.accountName)
    }

    func cancelAllOrders(pair: String! = nil) async {
        await BybitRestApi.cancelAllOrders(cb: {
            do {
                let res = try JSONDecoder().decode(BybitListRestBase<BybitMutateOrderData>.self, from: $0)

                if res.retCode == 0 {
                    for o in res.result.list {
                        LogManager.shared.info("Cancelled order \(o.orderId)")
                        Task {
                            await self.fetchOrders()
                        }
                    }
                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
            }
        }, symbol: pair, accountName: self.accountName)
    }

    func cancelOrder(id: String, symbol: String) async {
        await BybitRestApi.cancelOrder(cb: {
            do {
                let res = try JSONDecoder().decode(BybitRestBase<BybitMutateOrderData>.self, from: $0)

                if res.retCode == 0 {
                    LogManager.shared.info("Cancelled order \(res.result.orderId)")
                    Task {
                        await self.fetchOrders()
                    }

                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
            }
        }, orderId: id, symbol: symbol, accountName: self.accountName)
        await self.fetchOrders()
    }

    func fetchOrders(pair: String! = nil) async {
        await BybitRestApi.fetchOrders(cb: {
            do {
                let res = try JSONDecoder().decode(BybitListRestBase<BybitOrderData>.self, from: $0)

                if res.retCode == 0 {
                    DispatchQueue.main.async {
                        self.orders = res.result.list
                    }
                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
                print(String(decoding: $0, as: UTF8.self))
            }
        }, symbol: pair, accountName: self.accountName)
    }

    func fetchBalance() async {
        await BybitRestApi.fetchTradingBalance(cb: {
            do {
                let res = try JSONDecoder().decode(BybitListRestBase<BybitWalletData>.self, from: $0)

                if res.retCode == 0 {
                    DispatchQueue.main.async {
                        self.wallet = res.result.list
                    }
                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
                print(String(decoding: $0, as: UTF8.self))
            }
        }, accountName: self.accountName)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func createCSV(data: [BybitTransactionData]) {
        let header = ["id",
                      "symbol",
                      "side",
                      "funding",
                      "orderLinkId",
                      "orderId",
                      "fee",
                      "change",
                      "cashFlow",
                      "transactionTime",
                      "type",
                      "feeRate",
                      "bonusChange",
                      "size:",
                      "qty",
                      "cashBalance",
                      "currency",
                      "category",
                      "tradePrice",
                      "tradeId"]

        var rows = [header]

        for transaction in data {
            let newRow = [
                transaction.id,
                transaction.symbol,
                transaction.side,
                transaction.funding,
                transaction.orderLinkId,
                transaction.orderId,
                transaction.fee,
                transaction.change,
                transaction.cashFlow,
                transaction.transactionTime,
                transaction.type,
                transaction.feeRate,
                transaction.bonusChange,
                transaction.size,
                transaction.qty,
                transaction.cashBalance,
                transaction.currency,
                transaction.category,
                transaction.tradePrice,
                transaction.tradeId,
            ]
            rows.append(newRow)
        }

        do {
            let str = try CSVWriter.encode(rows: rows, into: String.self)
            print(str)
            let filename = self.getDocumentsDirectory().appendingPathComponent("transactions_bybit.csv")
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)

        } catch {
            fatalError("Unexpected error encoding CSV: \(error)")
        }
    }

    func fetchTransactionLog() async {
        await BybitRestApi.transactionInfo(cb: {
            do {
                let res = try JSONDecoder().decode(BybitListRestBase<BybitTransactionData>.self, from: $0)

                if res.retCode == 0 {
                    DispatchQueue.main.async {
                        self.transactions = res.result.list
                        self.createCSV(data: res.result.list)
                    }
                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
                print(String(decoding: $0, as: UTF8.self))
            }
        }, accountName: self.accountName)
    }
}
