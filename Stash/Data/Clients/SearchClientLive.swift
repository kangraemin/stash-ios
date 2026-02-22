import Dependencies
import Foundation

extension SearchClient {
    static let liveValue: SearchClient = {
        @Dependency(\.contentClient) var contentClient
        @Dependency(\.embeddingClient) var embeddingClient
        return SearchClient(
            search: { query in
                guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return try await contentClient.fetch()
                }
                let contents = try await contentClient.fetch()

                // 키워드 검색
                let keywordResults = Set(
                    contents.filter { content in
                        content.title.localizedStandardContains(query)
                            || content.url.absoluteString.localizedStandardContains(query)
                            || (content.summary?.localizedStandardContains(query) ?? false)
                            || content.metadata.values.contains { $0.localizedStandardContains(query) }
                    }.map(\.id)
                )

                // 시맨틱 검색
                var semanticScores: [UUID: Float] = [:]
                if let queryVector = try? await embeddingClient.embed(query),
                   !queryVector.isEmpty
                {
                    let semanticResults = VectorSearchService.search(
                        query: queryVector,
                        in: contents,
                        threshold: 0.3
                    )
                    for result in semanticResults {
                        semanticScores[result.content.id] = result.score
                    }
                }

                // 하이브리드 점수 계산 및 병합
                let keywordWeight: Float = 0.6
                let semanticWeight: Float = 0.4

                let scored: [(SavedContent, Float)] = contents.compactMap { content in
                    let isKeywordMatch = keywordResults.contains(content.id)
                    let semanticScore = semanticScores[content.id]

                    guard isKeywordMatch || semanticScore != nil else { return nil }

                    let kScore: Float = isKeywordMatch ? 1.0 : 0.0
                    let sScore = semanticScore ?? 0.0
                    let combined = kScore * keywordWeight + sScore * semanticWeight
                    return (content, combined)
                }

                return scored
                    .sorted { $0.1 > $1.1 }
                    .map(\.0)
            }
        )
    }()
}
