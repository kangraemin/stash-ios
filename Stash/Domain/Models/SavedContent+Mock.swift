import Foundation

extension SavedContent {
    static let mock = SavedContent(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        title: "테스트 콘텐츠",
        url: URL(string: "https://example.com")!,
        contentType: .web,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        thumbnailURL: nil,
        summary: nil,
        metadata: [:]
    )

    static let mockYouTube = SavedContent(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        title: "Swift 동시성 프로그래밍 강의",
        url: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!,
        contentType: .youtube,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        thumbnailURL: URL(string: "https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg"),
        summary: "Swift Concurrency를 활용한 비동기 프로그래밍",
        metadata: ["channelName": "SwiftDev"]
    )

    static let mockInstagram = SavedContent(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        title: "서울 카페 추천",
        url: URL(string: "https://www.instagram.com/p/ABC123")!,
        contentType: .instagram,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        thumbnailURL: URL(string: "https://instagram.com/image/ABC123.jpg"),
        summary: "성수동 분위기 좋은 카페",
        metadata: ["username": "cafetour"]
    )

    static let mockNaverMap = SavedContent(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        title: "스타벅스 강남역점",
        url: URL(string: "https://map.naver.com/v5/entry/place/12345")!,
        contentType: .naverMap,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        thumbnailURL: nil,
        summary: "서울 강남구 강남대로 396",
        metadata: ["address": "서울 강남구 강남대로 396", "category": "카페"]
    )

    static let mockGoogleMap = SavedContent(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        title: "도쿄 타워",
        url: URL(string: "https://maps.google.com/maps?q=Tokyo+Tower")!,
        contentType: .googleMap,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        thumbnailURL: nil,
        summary: "4 Chome-2-8 Shibakoen, Minato City, Tokyo",
        metadata: ["address": "4 Chome-2-8 Shibakoen, Minato City, Tokyo"]
    )

    static let mockCoupang = SavedContent(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
        title: "Apple AirPods Pro 2세대",
        url: URL(string: "https://www.coupang.com/vp/products/12345")!,
        contentType: .coupang,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        thumbnailURL: URL(string: "https://thumbnail.coupang.com/image/12345.jpg"),
        summary: "액티브 노이즈 캔슬링, USB-C 충전 케이스",
        metadata: ["price": "359,000원", "seller": "Apple 공식스토어"]
    )
}
