import SwiftUI
import MarkdownUI

public struct MarkdownPreviewView: View {
    let content: String
    let isTruncated: Bool
    @AppStorage("selectedTheme", store: UserDefaults(suiteName: "group.com.mdpreviewer"))
    private var selectedTheme = "System"
    
    public init(content: String, isTruncated: Bool) {
        self.content = content
        self.isTruncated = isTruncated
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if isTruncated {
                Text("Preview truncated for performance (Large File)")
                    .font(.caption).padding(4).background(Color.yellow.opacity(0.3)).frame(maxWidth: .infinity)
            }
            ScrollView {
                Markdown(content)
                    .markdownTheme(.gitHub)
                    .markdownCodeSyntaxHighlighter(SplashCodeHighlighter())
                    .padding()
            }
        }
        .preferredColorScheme(selectedTheme == "Light" ? .light : (selectedTheme == "Dark" ? .dark : nil))
    }
}
