import SwiftUI
import Splash
import MarkdownUI

public struct SplashCodeHighlighter: CodeSyntaxHighlighter {
    public init() {}
    
    public func highlightCode(_ code: String, language: String?) -> Text {
        // Splash is primarily for Swift. If language is specified and not swift, return plain text.
        if let language = language, language.lowercased() != "swift" {
            return Text(code).font(.system(.callout, design: .monospaced))
        }
        
        let theme = Splash.Theme.wwdc17(withFont: .init(size: 12))
        let highlighter = SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme))
        return highlighter.highlight(code)
    }
}

private struct AttributedStringOutputFormat: OutputFormat {
    private let theme: Splash.Theme
    init(theme: Splash.Theme) { self.theme = theme }
    func makeBuilder() -> AttributedStringBuilder { AttributedStringBuilder(theme: theme) }
}

private struct AttributedStringBuilder: OutputBuilder {
    private var text = Text("")
    private let theme: Splash.Theme
    init(theme: Splash.Theme) { self.theme = theme }
    
    mutating func addToken(_ token: String, ofType type: TokenType) {
        let color = theme.tokenColors[type] ?? .white
        text = text + Text(token).foregroundColor(Color(nsColor: color))
    }
    
    mutating func addPlainText(_ text: String) { self.text = self.text + Text(text) }
    mutating func addWhitespace(_ whitespace: String) { self.text = self.text + Text(whitespace) }
    func build() -> Text { text }
}

extension Color {
    init(nsColor: Splash.Color) {
        self.init(nsColor)
    }
}
