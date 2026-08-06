import AppKit
import SwiftUI

// SwiftUI の TextEditor は長文 + 日本語IMEの組み合わせで、高速入力時に変換中テキストの位置が
// ずれる既知の未解決バグがある(Apple Developer Forums 等で "TextEditor bouncing/jumping on
// long text input" として複数報告あり)。外側からの回避策がないため、NSTextView を直接ラップして
// バインディングを自前で制御する。
struct MacTextEditor: NSViewRepresentable {
    @Binding var text: String
    var fontSize: Double

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else { return scrollView }

        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.appearance = NSAppearance(named: .darkAqua)
        textView.font = .systemFont(ofSize: fontSize)
        textView.textColor = NSColor(named: "EditorTextColor")
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 8, height: 16)
        textView.string = text

        scrollView.drawsBackground = true
        scrollView.backgroundColor = NSColor(named: "EditorBackgroundColor") ?? .clear
        scrollView.appearance = NSAppearance(named: .darkAqua)

        DispatchQueue.main.async {
            scrollView.window?.makeFirstResponder(textView)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        // 外部からの text 変更はここでしか反映されない。変換中(marked text)はいじらない。
        if textView.string != text, !textView.hasMarkedText() {
            textView.string = text
        }
        if textView.font?.pointSize != CGFloat(fontSize) {
            textView.font = .systemFont(ofSize: fontSize)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        private let text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
        }
    }
}

struct ContentView: View {
    // @AppStorage を直接バインドすると、TextEditor への書き込み → UserDefaults 変更通知 → 値の読み戻しが
    // 毎キーストローク発生し、その往復の間に次の入力が来ると古い値で上書きされてカーソルが末尾へ飛ぶ。
    // そのため @State で保持し、UserDefaults へは書き込むだけの一方向同期にする。
    @State private var text = UserDefaults.standard.string(forKey: "text") ?? ""
    @AppStorage("fontSize") private var fontSize: Double = 18

    var body: some View {
        MacTextEditor(text: $text, fontSize: fontSize)
            .onChange(of: text) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "text")
            }
    }
}

#Preview {
    ContentView()
}
