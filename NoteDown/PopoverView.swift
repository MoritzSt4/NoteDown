//
//  PopoverView.swift
//  NoteDown
//
//  Created by Moritz Sta
//

import SwiftUI
import UniformTypeIdentifiers


struct PopoverView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    
    var texts: FetchedResults<Note>
    
    @State private var noteText: String = ""
    @State private var uuidCopied: String = ""
    @State private var uuidNoteClicked: String = ""
    @State private var clickedNoteContent: String = ""
    @State private var changesCounter: Int = 0
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                if (texts.isEmpty) {
                    showOnboardingNote()
                } else {
                    generateNotes()
                }
            }.frame(height: 370)
            Spacer()
            Spacer()
            Spacer()
            VStack {
                
                HStack {
                    Spacer()
                    TextEditor(text: $noteText)
                        .scrollContentBackground(.hidden)
                        .padding(.top, 4)
                        .padding(.bottom, 4)
                        .padding(.leading, 5)
                        .frame(minHeight: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary, lineWidth: 2)
                        )
                        .background(Color("TextEditorDynamicBackgroundColor").opacity(0.2))
                        .cornerRadius(10)
                        .font(.system(size: 13))
                    
                    Spacer()
                    
                    Button {
                        //add this note
                        if !noteText.isEmpty {
                            let note = Note(context: viewContext)
                            note.id = UUID()
                            note.text = noteText
                            note.timestamp = Date()
                            
                            try? viewContext.save()
                            
                            noteText = ""
                        }
                    } label: {
                        Image(systemName: "plus")
                    }.buttonStyle(.plain).foregroundStyle(noteText.isEmpty ? .gray : .green).help("add note ⇧ + ↵")
                }.onAppear{
                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        // Check if Shift and Enter keys are pressed simultaneously
                        if event.keyCode == 36 && event.modifierFlags.contains(.shift) {
                            // Trigger your action here
                            print("Shift + Enter pressed!")
                            //save this note
                            if !noteText.isEmpty {
                                let note = Note(context: viewContext)
                                note.id = UUID()
                                note.text = noteText
                                note.timestamp = Date()
                                
                                try? viewContext.save()
                                
                                noteText = ""
                            }
                            return nil
                        }
                        return event
                    }
                }
                
                Spacer()
                
                HStack() {
                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Image(systemName: "door.right.hand.open")
                    }
                    .buttonStyle(.plain).help("close app")
                    .foregroundStyle(.red)
                    
                    Spacer()
                     
                }
            }
            
        }
        .padding()
        .frame(width: 400).frame(maxHeight: 600)
    }
    
    
    func generateNotes() -> some View {
        ForEach(texts.reversed(), id: \.wrappedId) { text in
            VStack {
                
                if uuidNoteClicked == text.id?.uuidString {
                    
                    TextEditor(text: $clickedNoteContent)
                        .onAppear {
                            clickedNoteContent = text.wrappedText
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color("TextEditorDynamicBackgroundColor").opacity(0.1).cornerRadius(10))
                        .font(.system(size: 13))
                } else {
                    
                    HStack {
                        Text(text.wrappedText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.primary)
                    }.contentShape(Rectangle())
                }
                
                if (uuidNoteClicked == text.id?.uuidString) {
                    Divider().padding(.vertical, 4)
                    HStack {
                        
                        Button {
                            // Deletes note
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain).help("delete")
                        .alert(isPresented: $showDeleteAlert, content: {
                            deleteAlert { confirmed in
                                if confirmed {
                                    // delete note
                                    viewContext.delete(text)
                                    try? viewContext.save()
                                }
                            }
                        })
                        
                        Button {
                            // Save and Deletes note
                            saveToFile(textToSave: text.text ?? "Not defined") { success in
                                if success {
                                    // save was successfull, so note can be deleted
                                    viewContext.delete(text)
                                    try? viewContext.save()
                                } else {
                                    print("Save operation canceled or failed")
                                }
                            }
                            
                        } label: {
                            Image(systemName: "tray.and.arrow.down")
                        }.buttonStyle(.plain).help("archive")
                        
                        Spacer()
                        
                        
                        
                        if clickedNoteContent != text.text {
                            // Delete Changes Button
                            Button {
                                uuidNoteClicked = ""
                            } label: {
                                Image(systemName: "x.circle")
                            }
                            .buttonStyle(.plain).help("cancel")
                            .foregroundColor(.red)
                            
                            // Save changes Button
                            Button {
                                print("save changes")
                                if (clickedNoteContent.isEmpty) {
                                    // Delete note
                                    viewContext.delete(text)
                                    try? viewContext.save()
                                } else {
                                    // Save changes
                                    // create new note
                                    let note = Note(context: viewContext)
                                    note.id = UUID()
                                    note.text = clickedNoteContent
                                    note.timestamp = Date()
                                    
                                    // Delete note
                                    viewContext.delete(text)
                                    try? viewContext.save()
                                }
                                uuidNoteClicked = ""
                            } label: {
                                Image(systemName: "checkmark.circle")
                            }
                            .buttonStyle(.plain).help("save changes ⌘ + s")
                            .foregroundColor(.green)
                            .keyboardShortcut("s", modifiers: [.command])
                            
                            Spacer()
                        }
                        
                        Button {
                            // copy to clipboard
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.writeObjects([NSString(string: text.text ?? "")])
                            // Trigger the animation
                            withAnimation {
                                uuidCopied = text.id?.uuidString ?? ""
                            }
                            
                            // Reset the flag after a short delay to remove the animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    uuidCopied = ""
                                }
                            }
                            
                        } label: {
                            Image(systemName: (uuidCopied == text.id?.uuidString) ? "checkmark.circle" : "doc.on.doc")
                            
                                .rotationEffect(Angle(degrees: (uuidCopied == text.id?.uuidString)  ? 360 : 0)) // Rotate 360 degrees if copied
                                .scaleEffect((uuidCopied == text.id?.uuidString) ? 1.2 : 1) // Scale up if copied
                                .foregroundColor((uuidCopied == text.id?.uuidString) ? .green : .primary)
                            
                        }.buttonStyle(.plain).help("copy")
                        
                        if (uuidCopied == text.id?.uuidString) {
                            Text("Copied to Clipboard!")
                                .font(.system(size: 10))
                                .foregroundColor(.green) // You can customize the color
                                .transition(.opacity) // Apply a fade-in animation
                        }
                        
                        Button {
                            // save note then
                            saveToFile(textToSave: text.text ?? "Not defined") { success in
                                if success {
                                    print("Save successful")
                                } else {
                                    print("Save operation canceled or failed")
                                }
                            }
                            // Delete note with this id
                        } label: {
                            Image(systemName: "desktopcomputer.and.arrow.down")
                        }.buttonStyle(.plain).help("save as")
                    }}
                
            }.padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10).stroke((uuidNoteClicked == text.id?.uuidString) ? Color.accentColor : Color.primary, lineWidth: 1)
                )
                .padding(.vertical, 5)
                .onTapGesture {
                    uuidNoteClicked = text.id?.uuidString ?? ""
                    print("clicked")
                }
        }
    }
    
    
    func showOnboardingNote() -> some View {
        VStack {
            Text("Effortlessly capture your thoughts on the go with your NoteDown app. Seamlessly jot down ideas, to-do lists, and inspirations on your digital notepad, available whenever you need it.\n\nPro tip: Save time! Simply use Shift + Enter (⇧ + ↵) to instantly add notes without the need to reach for the '+' icon.")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10).stroke(Color.secondary, lineWidth: 1))
        .padding(.vertical, 5)
        .foregroundColor(.secondary)
    }
    
    private func deleteAlert(completion: @escaping (Bool) -> Void) -> Alert {
        return Alert(
            title: Text("Are you sure you want to delete this note?"),
            message: Text("This note will be deleted immediately. You can't undo this action."),
            primaryButton: .destructive(Text("Delete")) {
                // Benutzer hat bestätigt
                completion(true)
            },
            secondaryButton: .cancel() {
                // Benutzer hat abgebrochen
                completion(false)
            }
        )
    }
    
    func saveToFile(textToSave: String, completion: @escaping (Bool) -> Void) {
        let savePanel = NSSavePanel()
        savePanel.title = "Save Text File"
        savePanel.allowedContentTypes = [UTType.plainText]
        savePanel.nameFieldStringValue = "Unknown.txt"
        savePanel.level = NSWindow.Level.modalPanel
        savePanel.canCreateDirectories = true
        
        
        savePanel.begin { response in
            switch response {
            case .OK:
                if let url = savePanel.url {
                    do {
                        try textToSave.write(to: url, atomically: true, encoding: .utf8)
                        completion(true) // Inform the caller that the save was successful
                    } catch {
                        print("Error writing to file: \(error.localizedDescription)")
                        completion(false) // Inform the caller that there was an error
                    }
                }
            case .cancel:
                // Inform the caller that the save was canceled
                completion(false)
            default:
                break // Handle other cases if needed
            }
        }
    }
    
}


struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
    }
}
