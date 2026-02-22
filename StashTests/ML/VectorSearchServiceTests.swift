import Foundation
import Testing

@testable import Stash

struct VectorSearchServiceTests {
    @Test("동일 벡터의 코사인 유사도는 1.0이다")
    func identicalVectors() {
        let vector: [Float] = [1, 2, 3, 4, 5]
        let similarity = VectorSearchService.cosineSimilarity(vector, vector)
        #expect(abs(similarity - 1.0) < 0.0001)
    }

    @Test("반대 벡터의 코사인 유사도는 -1.0이다")
    func oppositeVectors() {
        let a: [Float] = [1, 2, 3]
        let b: [Float] = [-1, -2, -3]
        let similarity = VectorSearchService.cosineSimilarity(a, b)
        #expect(abs(similarity - (-1.0)) < 0.0001)
    }

    @Test("직교 벡터의 코사인 유사도는 0.0이다")
    func orthogonalVectors() {
        let a: [Float] = [1, 0, 0]
        let b: [Float] = [0, 1, 0]
        let similarity = VectorSearchService.cosineSimilarity(a, b)
        #expect(abs(similarity) < 0.0001)
    }

    @Test("빈 벡터의 코사인 유사도는 0.0이다")
    func emptyVectors() {
        let similarity = VectorSearchService.cosineSimilarity([], [])
        #expect(similarity == 0)
    }

    @Test("길이가 다른 벡터의 코사인 유사도는 0.0이다")
    func differentLengthVectors() {
        let a: [Float] = [1, 2, 3]
        let b: [Float] = [1, 2]
        let similarity = VectorSearchService.cosineSimilarity(a, b)
        #expect(similarity == 0)
    }

    @Test("임계값 이상인 콘텐츠만 검색 결과에 포함된다")
    func searchFiltersbyThreshold() {
        let queryVector: [Float] = [1, 0, 0]

        var similar = SavedContent.mock
        similar.embeddingVector = [0.9, 0.1, 0.0]

        var dissimilar = SavedContent.mockYouTube
        dissimilar.embeddingVector = [0.0, 0.0, 1.0]

        let results = VectorSearchService.search(
            query: queryVector,
            in: [similar, dissimilar],
            threshold: 0.5
        )

        #expect(results.count == 1)
        #expect(results.first?.content.id == similar.id)
    }

    @Test("임베딩 벡터가 없는 콘텐츠는 검색 결과에서 제외된다")
    func contentWithoutEmbeddingIsExcluded() {
        let queryVector: [Float] = [1, 0, 0]
        let results = VectorSearchService.search(
            query: queryVector,
            in: [.mock],
            threshold: 0.0
        )
        #expect(results.isEmpty)
    }

    @Test("검색 결과는 유사도 점수 내림차순으로 정렬된다")
    func resultsAreSortedByScore() {
        let queryVector: [Float] = [1, 0, 0]

        var highScore = SavedContent.mock
        highScore.embeddingVector = [1.0, 0.0, 0.0]

        var midScore = SavedContent.mockYouTube
        midScore.embeddingVector = [0.7, 0.7, 0.0]

        let results = VectorSearchService.search(
            query: queryVector,
            in: [midScore, highScore],
            threshold: 0.0
        )

        #expect(results.count == 2)
        #expect(results[0].content.id == highScore.id)
        #expect(results[1].content.id == midScore.id)
    }
}
