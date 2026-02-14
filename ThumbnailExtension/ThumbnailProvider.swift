import QuickLookThumbnailing
import AppKit

class ThumbnailProvider: QLThumbnailProvider {

    private static let baseWidth: CGFloat = 490.0
    private static let baseHeight: CGFloat = 800.0
    private static let aspectRatio: CGFloat = baseWidth / baseHeight

    override func provideThumbnail(
        for request: QLFileThumbnailRequest,
        _ handler: @escaping (QLThumbnailReply?, Error?) -> Void
    ) {
        let fileURL = request.fileURL

        guard let htmlData = NFORenderer.createHTMLPreview(from: fileURL) else {
            handler(nil, CocoaError(.fileReadCorruptFile))
            return
        }

        let maxSize = request.maximumSize

        let contextSize: CGSize
        if maxSize.width / maxSize.height > Self.aspectRatio {
            contextSize = CGSize(
                width: maxSize.height * Self.aspectRatio,
                height: maxSize.height
            )
        } else {
            contextSize = CGSize(
                width: maxSize.width,
                height: maxSize.width / Self.aspectRatio
            )
        }

        let reply = QLThumbnailReply(contextSize: contextSize) { context -> Bool in
            context.setFillColor(CGColor.white)
            context.fill(CGRect(origin: .zero, size: contextSize))

            guard let htmlString = String(data: htmlData, encoding: .utf8),
                  let attrData = htmlString.data(using: .utf8) else {
                return false
            }

            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue,
            ]

            guard let attrString = try? NSAttributedString(
                data: attrData,
                options: options,
                documentAttributes: nil
            ) else {
                return false
            }

            NSGraphicsContext.saveGraphicsState()
            let nsContext = NSGraphicsContext(cgContext: context, flipped: false)
            NSGraphicsContext.current = nsContext

            let drawRect = CGRect(origin: .zero, size: contextSize)
            attrString.draw(in: drawRect)

            NSGraphicsContext.restoreGraphicsState()
            return true
        }

        handler(reply, nil)
    }
}
