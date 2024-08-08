import SwiftUI

@main
struct EditjiroApp: App {
    @AppStorage("fontSize") var fontSize: Double = 18

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("Editjiro")
        }
        .commands {
            CommandMenu("Editor") {
                Button("Increase Font Size") {
                    fontSize += 2
                }
                .keyboardShortcut("+", modifiers: .command)
                Button("Decrease Font Size") {
                    fontSize -= 2
                }
                .keyboardShortcut("-", modifiers: .command)
            }
        }
    }
}
