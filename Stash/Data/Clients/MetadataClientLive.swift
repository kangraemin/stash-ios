import Foundation

enum OGTagParser {

    static func parse(from url: URL) async throws -> ContentMetadata {
        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(data: data, encoding: .utf8) ?? ""
        return extractOGTags(from: html)
    }

    static func extractOGTags(from html: String) -> ContentMetadata {
        ContentMetadata(
            title: extractMetaContent(property: "og:title", from: html),
            description: extractMetaContent(property: "og:description", from: html),
            imageURL: extractMetaContent(property: "og:image", from: html).flatMap(URL.init(string:)),
            siteName: extractMetaContent(property: "og:site_name", from: html)
        )
    }

    // MARK: - Private

    private static func extractMetaContent(property: String, from html: String) -> String? {
        let escapedProperty = NSRegularExpression.escapedPattern(for: property)

        // property="og:xxx" content="..." 또는 name="og:xxx" content="..."
        let patterns = [
            "<meta[^>]+(?:property|name)=\"\(escapedProperty)\"[^>]+content=\"([^\"]*)\"",
            "<meta[^>]+content=\"([^\"]*)\"[^>]+(?:property|name)=\"\(escapedProperty)\"",
            "<meta[^>]+(?:property|name)='\(escapedProperty)'[^>]+content='([^']*)'",
            "<meta[^>]+content='([^']*)'[^>]+(?:property|name)='\(escapedProperty)'",
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
               let range = Range(match.range(at: 1), in: html) {
                let value = String(html[range])
                return value.isEmpty ? nil : value
            }
        }
        return nil
    }
}
