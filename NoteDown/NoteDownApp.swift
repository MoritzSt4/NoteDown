//
//  NoteDownApp.swift
//  NoteDown
//
//  Created by Moritz on 19.11.23.
//

import SwiftUI

@main
struct NoteDownApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
