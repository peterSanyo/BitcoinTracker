//
//  BitcoinTrackerApp.swift
//  BitcoinTracker
//
//  Created by Péter Sanyó on 05.12.23.
//

import SwiftUI

@main
struct BitcoinTrackerApp: App {
    let dataController = DataController()

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel(context: dataController.container.viewContext))
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
