import Foundation

enum DeepLinkBuilder {
    static func deepLinkURL(for content: SavedContent) -> URL {
        switch content.contentType {
        case .naverMap:
            return naverMapDeepLink(from: content.url) ?? content.url
        case .youtube, .instagram, .googleMap, .coupang, .web:
            return content.url
        }
    }

    static func canDeepLink(_ contentType: ContentType) -> Bool {
        true
    }
}

// MARK: - Naver Map

private extension DeepLinkBuilder {
    static func naverMapDeepLink(from url: URL) -> URL? {
        var components = URLComponents()
        components.scheme = "nmap"
        components.host = "place"
        components.queryItems = [
            URLQueryItem(name: "url", value: url.absoluteString),
            URLQueryItem(name: "appname", value: "com.kangraemin.stash"),
        ]

        return components.url
    }
}
