import Foundation

enum NFORenderer {

    // MARK: - CP437 Encoding

    static let cp437Encoding: String.Encoding = {
        let cfEncoding = CFStringEncoding(CFStringEncodings.dosLatinUS.rawValue)
        let nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding)
        return String.Encoding(rawValue: nsEncoding)
    }()

    // MARK: - Block Character Detection

    static func isBlockOrBox(_ scalar: Unicode.Scalar) -> Bool {
        scalar.value >= 0x2500 && scalar.value <= 0x25A9
    }

    static func isWhitespace(_ scalar: Unicode.Scalar) -> Bool {
        scalar.value <= 0x0020
    }

    // MARK: - HTML Generation

    private static let preHTML = """
    <html style="margin:0;padding:0;background-color:#000;">
    <head><meta charset="utf-8">
    <style type="text/css">
    * { margin:0; padding:0; }
    pre {
        font-family: 'Menlo', 'SF Mono', 'Andale Mono', 'Courier New', monospace !important;
        font-size: 13px !important;
        line-height: 1.0 !important;
        color: #ccc;
        background-color: #000;
        -webkit-font-smoothing: subpixel-antialiased;
        white-space: pre !important;
        word-wrap: normal !important;
        overflow: auto;
        tab-size: 8;
    }
    .block { -webkit-font-smoothing: none; color: #fff; }
    </style>
    </head>
    <body style="margin:0;padding:8px;background-color:#000;">
    <pre style="font-family:'Menlo','SF Mono','Andale Mono','Courier New',monospace;font-size:13px;line-height:1.0;color:#ccc;">
    """

    private static let postHTML = "</pre></body></html>"

    static func createHTMLPreview(from url: URL) -> Data? {
        guard let rawData = try? Data(contentsOf: url) else {
            return nil
        }

        guard let text = String(data: rawData, encoding: cp437Encoding) else {
            return nil
        }

        let html = generateHTML(from: text)
        return html.data(using: .utf8)
    }

    static func generateHTML(from text: String) -> String {
        var result = String()
        result.reserveCapacity(text.count * 2)

        result.append(preHTML)

        var inBlockRun = false
        var pendingChars = String()

        for scalar in text.unicodeScalars {
            let isBlock = isBlockOrBox(scalar)
            let isWS = isWhitespace(scalar)

            var newState = inBlockRun
            if !inBlockRun {
                if isBlock {
                    newState = true
                }
            } else {
                if !isBlock && !isWS {
                    newState = false
                }
            }

            if inBlockRun != newState {
                if !pendingChars.isEmpty {
                    if inBlockRun {
                        result.append("<span class='block'>")
                        result.append(htmlEscape(pendingChars))
                        result.append("</span>")
                    } else {
                        result.append(htmlEscape(pendingChars))
                    }
                    pendingChars.removeAll(keepingCapacity: true)
                }
                inBlockRun = newState
            }

            pendingChars.append(Character(scalar))
        }

        if !pendingChars.isEmpty {
            if inBlockRun {
                result.append("<span class='block'>")
                result.append(htmlEscape(pendingChars))
                result.append("</span>")
            } else {
                result.append(htmlEscape(pendingChars))
            }
        }

        result.append(postHTML)
        return result
    }

    private static func htmlEscape(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
