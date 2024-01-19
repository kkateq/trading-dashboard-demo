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
            return (.red, 4)
        case 2:
            return (.orange, 3)
        case 1:
            return (.yellow, 2)
        default:
            return (.black, 1)
        }
    }
}

class PriceLevelManager: ObservableObject {
    private var container: NSPersistentContainer
    var pair: String

    @Published var levels: [PairPriceLevel] = []

    init(_ p: String) {
        pair = p
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
        fetchRequest.predicate = NSPredicate(format: "pair = %@", pair)
        do {
            levels = try container.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching \(error)")
        }
    }

    func getLevel(price: String) -> PairPriceLevel! {
        return levels.first(where: { $0.price == price })
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
        saveData()
    }

    func deleteLevel(id: UUID) {
        if let l = levels.first(where: { $0.id == id }) {
            container.viewContext.delete(l)
            saveData()
        }
    }
}
