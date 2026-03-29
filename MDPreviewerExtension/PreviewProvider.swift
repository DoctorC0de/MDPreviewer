import QuickLookUI
import SwiftUI
import MDPreviewerCore

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let fileURL = request.fileURL
        
        // Security: Always start accessing the security-scoped resource
        guard fileURL.startAccessingSecurityScopedResource() else {
            throw NSError(domain: "MDPreviewer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to access file"])
        }
        defer { fileURL.stopAccessingSecurityScopedResource() }
        
        // Truncation limit: 5MB
        let maxSizeBytes = 5 * 1024 * 1024
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        let fileSize = attributes[.size] as? Int ?? 0
        let isTruncated = fileSize > maxSizeBytes
        
        let content: String
        if isTruncated {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe).prefix(maxSizeBytes)
            content = String(decoding: data, as: UTF8.self)
        } else {
            content = try String(contentsOf: fileURL, encoding: .utf8)
        }
        
        return QLPreviewReply(contextSize: .zero) {
            MarkdownPreviewView(content: content, isTruncated: isTruncated)
        }
    }
}
