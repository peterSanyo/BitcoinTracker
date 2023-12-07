//
//  DataController.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 06.12.23.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name:"BitcoinTracker")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}

