import Foundation

enum VectorSearchService {
    static func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }

        var dot: Float = 0
        var normA: Float = 0
        var normB: Float = 0

        for i in 0..<a.count {
            dot += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }

        let denominator = sqrt(normA) * sqrt(normB)
        guard denominator > 0 else { return 0 }
        return dot / denominator
    }

    static func search(
        query queryVector: [Float],
        in contents: [SavedContent],
        threshold: Float = 0.3
    ) -> [(content: SavedContent, score: Float)] {
        guard !queryVector.isEmpty else { return [] }

        return contents
            .compactMap { content -> (SavedContent, Float)? in
                guard let embedding = content.embeddingVector, !embedding.isEmpty else {
                    return nil
                }
                let score = cosineSimilarity(queryVector, embedding)
                guard score >= threshold else { return nil }
                return (content, score)
            }
            .sorted { $0.1 > $1.1 }
    }
}
