//
//  KeychainHandler.swift
//  dashboard
//
//  Created by km on 21/12/2023.
//

import Foundation
// import Security

class KeychainHandler {
//    TODO: implementation 
//    internal static func retrievePrivateKey(tag: Data) throws -> SecKey {
//        // Create a query with key type and tag
//        let getQuery: [String: Any] = [kSecClass as String: kSecClassKey,
//                                       kSecAttrApplicationTag as String: tag,
//                                       kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
//                                       kSecReturnRef as String: true]
//
//        // Use this query with the SecItemCopyMatching method to execute a search
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(getQuery as CFDictionary, &item)
//        var error: Unmanaged<CFError>?
//        guard status == errSecSuccess else { throw error!.takeRetainedValue() as Error }
//        let privateKey = item as! SecKey
//
//        return privateKey
//    }

//    static func krakenAPIKey() throws -> SecKey {
//        let tag = "com.buildany.dashboard.kraken.key".data(using: .utf8)!
//        return try retrievePrivateKey(tag: tag)
//    }
//
//    static func krakenAPISecret() throws -> SecKey {
//        let tag = "com.buildany.dashboard.kraken.secret".data(using: .utf8)!
//        return try retrievePrivateKey(tag: tag)
//    }

    static var KrakenApiKey: String = "X"
    static var KrakenApiSecret: String = "X"

    static var BybitApiKey = "X"
    static var BybitApiSecret = "X"


    static var accounts = ["main": (BybitApiKey, BybitApiSecret)]
    
    static func getAccountKey(accountName: String!) -> String {
        if let name = accountName {
            return accounts[name]!.0
        } else {
            return BybitApiKey
        }
    }
    
    static func getAccountSecret(accountName: String!) -> String {
        if let name = accountName {
            return accounts[name]!.1
        } else {
            return BybitApiSecret
        }
    }
}
