import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isButtonClicked = false
    @State private var isClicked = false
    @State private var isClickedCounter = 0
    
    var body: some View {
        VStack {
            Text("Welcome to NoteDown!")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 30)
           
            
            Image("NoteDownIcon")
                .resizable()
                .frame(width: 80, height: 80)
                .rotationEffect(Angle(degrees: isClickedCounter > 12 && isClicked ? 36000 :(isClicked ? 360 : 0)))
                .scaleEffect(isClickedCounter >= 13 && isClicked ? 1.8 : (isClicked ? 1.3 : 1)) // Größenänderung
                .padding(.bottom, 20)
                .onTapGesture {
                    isClickedCounter += 1
                    withAnimation {
                        isClicked.toggle()
                    }
                }
            
            if isClicked && isClickedCounter >= 42 {
                ColorfulPointsView()
                    .transition(.opacity)
            }
            
            Spacer()
            
            HStack {
                Text("To begin, simply tap the NoteDown Icon")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Button {
                    isButtonClicked = true
                } label: {
                    Image("note.down")
                    
                }
                .buttonStyle(.plain).foregroundColor(.accentColor)
                
                Text("in your menu bar.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            
            if isButtonClicked {
                Text("Not the icon you see here, but the one located in your menubar ↗")
                    .foregroundColor(.green)
                    .italic()
                    .padding(.top, 20)
            }
            
            Text("Feel free to close this window at any time.")
                .italic()
                .foregroundColor(.secondary)
                .padding(.top, 20)
            
            Spacer()
            
            Text("© Moritz Staigl")
                .foregroundColor(.secondary)
            
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}


struct ColorfulPointsView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<1000) { _ in
                    Circle()
                        .foregroundColor(.random)
                        .opacity(0.8)
                        .frame(width: CGFloat.random(in: 5...20), height: CGFloat.random(in: 5...20))
                        .onAppear().position(
                            x: CGFloat.random(in: -1300...1500),
                            y: CGFloat.random(in: -1300...1500)
                        )
                }
            }
        }
    }
}


extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
