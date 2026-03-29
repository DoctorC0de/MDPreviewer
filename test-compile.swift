import QuickLookUI
import SwiftUI

struct TestView: View {
    var body: some View { Text("Hello") }
}

func test() -> QLPreviewReply {
    return QLPreviewReply(contextSize: .zero) {
        TestView()
    }
}
