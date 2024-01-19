//
//  DataController.swift
//  dashboard
//
//  Created by km on 19/01/2024.
//


import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "DataController")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
