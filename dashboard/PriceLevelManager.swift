//
//  PriceLevelManager.swift
//  dashboard
//
//  Created by km on 17/01/2024.
//

import Combine
import Foundation
import SwiftUI

enum PriceLevelType: Int32, CaseIterable, Identifiable {
    case minor = 1
    case middle = 2
    case major = 3
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

extension PairPriceLevel {
    var color: (Color, CGFloat) {
        switch self.type {
        case 3:
            return (.purple, 4)
        case 2:
            return (.teal, 3)
        case 1:
            return (.gray, 2)
        default:
            return (.black, 1)
        }
    }
}

class PriceLevelManager: ObservableObject {
    private var container: NSPersistentContainer

    @Published var levels: [PairPriceLevel] = []
    
    static let shared = PriceLevelManager()
    
    init() {
     
        container = NSPersistentContainer(name: "DashboardDataController")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error)")
            }
        }
        fetchLevels()
    }

    func fetchLevels() {
        let fetchRequest = NSFetchRequest<PairPriceLevel>(entityName: "PairPriceLevel")
        do {
            levels = try container.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching \(error)")
        }
    }

    func getLevel(pair: String, price: String) -> PairPriceLevel! {
        return levels.first(where: { $0.price == price && $0.pair == pair })
    }
    
    func getLevelPrices(pair: String) -> [Double] {
        return levels.filter({$0.pair == pair}).map({ Double($0.price!)! })
    }

    func getLevels(pair: String) -> [PairPriceLevel] {
        return levels.filter({$0.pair == pair})
    }
    
    func updateAlertTime(id: UUID) {
        if let l = levels.first(where: { $0.id == id }) {
            l.lastAlertTime = Date()
            saveData()
        }
    }
    func saveData() {
        do {
            try container.viewContext.save()
            fetchLevels()
        } catch {
            print("Error saving. \(error)")
        }
    }

    func addLevel(pair: String, price: String, type: PriceLevelType = .middle, note: String = "") {
        let newLevel = PairPriceLevel(context: container.viewContext)
        newLevel.id = UUID()
        newLevel.pair = pair
        newLevel.price = price
        newLevel.type = type.rawValue
        newLevel.note = note
        newLevel.added = Date()
        saveData()
    }

    func deleteLevel(id: UUID) {
        if let l = levels.first(where: { $0.id == id }) {
            container.viewContext.delete(l)
            saveData()
        }
    }
}
