import Dependencies
import Foundation

extension SearchClient {
    static let liveValue: SearchClient = {
        @Dependency(\.contentClient) var contentClient
        return SearchClient(
            search: { query in
                guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return try await contentClient.fetch()
                }
                let contents = try await contentClient.fetch()
                return contents.filter { content in
                    content.title.localizedStandardContains(query)
                        || content.url.absoluteString.localizedStandardContains(query)
                        || (content.summary?.localizedStandardContains(query) ?? false)
                        || content.metadata.values.contains { $0.localizedStandardContains(query) }
                }
            }
        )
    }()
}
