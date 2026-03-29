import QuickLookUI
import SwiftUI

if #available(macOS 14.0, *) {
    let reply = QLPreviewReply(contextSize: .zero) {
        Text("hello")
    }
}
