//
//  Nautical_Math_HelperApp.swift
//  Nautical Math Helper
//
//  Created by Jill Russell on 12/28/24.
//

import SwiftUI

@main
struct Nautical_Math_HelperApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
