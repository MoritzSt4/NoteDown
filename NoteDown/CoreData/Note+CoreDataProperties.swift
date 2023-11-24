//
//  Note+CoreDataProperties.swift
//  NoteDown
//
//  Created by Moritz on 19.11.23.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var timestamp: Date?
    
    var wrappedId: UUID { id! }
    var wrappedText: String { text ?? "" }
    var wrappedTimestamp: Date { timestamp! }

}

extension Note : Identifiable {

}
