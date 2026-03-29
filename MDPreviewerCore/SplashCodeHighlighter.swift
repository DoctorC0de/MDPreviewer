import SwiftUI
import Splash
import MarkdownUI

public struct SplashCodeHighlighter: CodeHighlighter {
    public init() {}
    public func highlightCode(_ code: String, language: String?) -> Text {
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
        text = text + Text(token).foregroundColor(Color(color))
    }
    mutating func addPlainText(_ text: String) { self.text = self.text + Text(text) }
    mutating func addWhitespace(_ whitespace: String) { self.text = self.text + Text(whitespace) }
    func build() -> Text { text }
}
