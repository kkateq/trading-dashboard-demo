//
//  PriceLevelManager.swift
//  dashboard
//
//  Created by km on 17/01/2024.
//

import Combine
import Foundation
import SwiftUI

enum PriceLevelType: CaseIterable, Identifiable {
    case minor, middle, major
    var id: Self { self }
    var description: String {
        switch self {
        case .minor:
            return "minor"
        case .middle:
            return "Middle"
        case .major:
            return "MAJOR"
        }
    }
}

struct Level: Identifiable, Equatable {
    var id = UUID()
    var price: String
    var type: PriceLevelType
    var pair: String
    var color: (Color, CGFloat) {
        switch type {
        case .major:
            return (.black, 4)
        case .middle:
            return (Color("MiddleLevel"), 3)
        case .minor:
            return (.gray, 2)
        }
    }
}

          

class Anchor {
    var id = UUID()
    var time = Date().currentTimeMillis()
}

class PriceLevelManager: ObservableObject {
    @Published private(set) var data: [String: [Level]] = [:]
    static let manager = PriceLevelManager()
    @Published var anchor = Anchor()
    private let levelsStore = [
        "AVAXUSDT": [("36.245", PriceLevelType.major)]
    ]
    
    func levels(pair: String) -> [Level] {
        if let lv = self.data[pair] {
            return lv
        }
        return []
    }
            
    init() {
        for l in levelsStore {
            for node in l.value {
                if var dEx = self.data[l.key] {
                    dEx.append(Level(price: node.0, type: node.1, pair: l.key))
                    self.data[l.key] = dEx
                } else {
                    self.data[l.key] = [Level(price: node.0, type: node.1, pair: l.key)]
                }
            }
        }
    }

    func addLevel(pair: String, price: String, type: PriceLevelType = .minor) {
        DispatchQueue.main.async {
            let newLevel = Level(price: price, type: type, pair: pair)
            if var levEx = self.data[pair] {
                levEx.append(newLevel)
                self.data[pair] = levEx
            } else {
                self.data[pair] = [newLevel]
            }
            self.anchor = Anchor()
        }
    }

    func deleteLevel(id: UUID, pair: String) {
        DispatchQueue.main.async {
            if var levEx = self.data[pair] {
                levEx.removeAll(where: { $0.id == id })
                self.data[pair] = levEx
            }
            self.anchor = Anchor()
        }
    }
}
