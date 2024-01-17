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

class PriceLevelManager: ObservableObject {
    @Published private(set) var data: [Level] = []
    static let manager = PriceLevelManager()

    private var cancellable: AnyCancellable?
    let didChange = PassthroughSubject<Void, Never>()
    
    @Published var levels: [Level] {
        didSet {
            didChange.send()
        }
    }

    init() {
        self.levels = []
        cancellable = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.levels, on: self))
    }

    
    func addLevel(price: String, type: PriceLevelType = .minor) {
        DispatchQueue.main.async {
            self.data.append(Level(price: price, type: type))
        }
    }

    func deleteLevel(id: UUID) {
        DispatchQueue.main.async {
            self.data.removeAll(where: { $0.id == id })
        }
    }
}
