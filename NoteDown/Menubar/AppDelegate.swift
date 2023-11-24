//
//  AppDelegate.swift
//  NoteDown
//
//  Created by Moritz on 19.11.23.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover = NSPopover()
    var statusBar: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.popover.contentViewController = NSHostingController(rootView: PopoverView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext))
        
        // Popover hides if user clicks outside the popover
        self.popover.behavior = .transient
        
        statusBar = StatusBarController(self.popover)
        
    }
    
}
