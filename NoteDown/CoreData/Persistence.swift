//
//  Persistence.swift
//  NoteDown
//
//  Created by Moritz on 19.11.23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

  

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "NoteDown")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
