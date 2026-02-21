import Foundation
import Testing
@testable import Stash

struct ContentMapperTests {

    @Test("SDContent에서 SavedContent로 변환된다")
    func toDomain() {
        let sd = SDContent(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            title: "테스트 콘텐츠",
            urlString: "https://www.youtube.com/watch?v=abc",
            contentTypeRawValue: "youtube",
            createdAt: Date(timeIntervalSince1970: 1000),
            thumbnailURLString: "https://img.youtube.com/vi/abc/0.jpg",
            summary: "테스트 요약",
            metadataJSON: "{\"channelName\":\"테스트채널\"}"
        )

        let domain = ContentMapper.toDomain(sd)

        #expect(domain.id == sd.id)
        #expect(domain.title == "테스트 콘텐츠")
        #expect(domain.url.absoluteString == "https://www.youtube.com/watch?v=abc")
        #expect(domain.contentType == .youtube)
        #expect(domain.createdAt == Date(timeIntervalSince1970: 1000))
        #expect(domain.thumbnailURL?.absoluteString == "https://img.youtube.com/vi/abc/0.jpg")
        #expect(domain.summary == "테스트 요약")
        #expect(domain.metadata["channelName"] == "테스트채널")
    }

    @Test("SavedContent에서 SDContent로 변환된다")
    func toData() {
        let domain = SavedContent(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            title: "쿠팡 상품",
            url: URL(string: "https://www.coupang.com/vp/products/123")!,
            contentType: .coupang,
            createdAt: Date(timeIntervalSince1970: 2000),
            thumbnailURL: URL(string: "https://thumbnail.coupang.com/img.jpg"),
            summary: "할인 상품",
            metadata: ["price": "29,900원", "seller": "쿠팡"]
        )

        let sd = ContentMapper.toData(domain)

        #expect(sd.id == domain.id)
        #expect(sd.title == "쿠팡 상품")
        #expect(sd.urlString == "https://www.coupang.com/vp/products/123")
        #expect(sd.contentTypeRawValue == "coupang")
        #expect(sd.createdAt == Date(timeIntervalSince1970: 2000))
        #expect(sd.thumbnailURLString == "https://thumbnail.coupang.com/img.jpg")
        #expect(sd.summary == "할인 상품")
        #expect(sd.metadataJSON != nil)
    }

    @Test("양방향 변환 후 데이터가 보존된다")
    func roundTrip() {
        let original = SavedContent(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            title: "네이버지도 장소",
            url: URL(string: "https://map.naver.com/v5/search/맛집")!,
            contentType: .naverMap,
            createdAt: Date(timeIntervalSince1970: 3000),
            thumbnailURL: URL(string: "https://example.com/thumb.jpg"),
            summary: "맛집 정보",
            metadata: ["address": "서울시 강남구"]
        )

        let sd = ContentMapper.toData(original)
        let restored = ContentMapper.toDomain(sd)

        #expect(restored.id == original.id)
        #expect(restored.title == original.title)
        #expect(restored.url == original.url)
        #expect(restored.contentType == original.contentType)
        #expect(restored.createdAt == original.createdAt)
        #expect(restored.thumbnailURL == original.thumbnailURL)
        #expect(restored.summary == original.summary)
        #expect(restored.metadata == original.metadata)
    }

    @Test("metadata JSON 직렬화/역직렬화가 정확하다")
    func metadataJsonRoundTrip() {
        let metadata: [String: String] = [
            "key1": "value1",
            "key2": "한글값",
            "key3": "value with spaces"
        ]

        let content = SavedContent(
            id: UUID(),
            title: "Test",
            url: URL(string: "https://example.com")!,
            contentType: .web,
            createdAt: Date(),
            metadata: metadata
        )

        let sd = ContentMapper.toData(content)
        let restored = ContentMapper.toDomain(sd)

        #expect(restored.metadata == metadata)
    }

    @Test("빈 metadata는 nil JSON으로 변환된다")
    func emptyMetadata() {
        let content = SavedContent(
            id: UUID(),
            title: "Test",
            url: URL(string: "https://example.com")!,
            contentType: .web,
            createdAt: Date(),
            metadata: [:]
        )

        let sd = ContentMapper.toData(content)
        #expect(sd.metadataJSON == nil)

        let restored = ContentMapper.toDomain(sd)
        #expect(restored.metadata.isEmpty)
    }
}
