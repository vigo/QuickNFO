import Cocoa
@preconcurrency import QuickLookUI

class PreviewProvider: NSViewController, QLPreviewingController {

    override var nibName: NSNib.Name? {
        nil
    }

    override func loadView() {
        view = NSView()
    }

    nonisolated func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let fileURL = request.fileURL

        guard let htmlData = NFORenderer.createHTMLPreview(from: fileURL) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let reply = QLPreviewReply(
            dataOfContentType: .html,
            contentSize: CGSize(width: 800, height: 600)
        ) { replyToUpdate in
            replyToUpdate.stringEncoding = .utf8
            return htmlData
        }

        reply.title = fileURL.lastPathComponent
        return reply
    }
}
