import SwiftUI

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
            textContainerInset = NSSize(width: 8, height: 16)
        }
    }
}

struct ContentView: View {
    @AppStorage("text") private var text = ""
    @AppStorage("fontSize") private var fontSize: Double = 18
    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $text)
            .background(Color.editorBackground)
            .font(.system(size: fontSize))
            .foregroundStyle(Color.editorText)
            .focused($isFocused)
            .preferredColorScheme(.dark)
            .onAppear {
                isFocused = true
            }
    }
}

#Preview {
    ContentView()
}
