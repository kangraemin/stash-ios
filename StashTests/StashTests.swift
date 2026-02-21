import Testing
@testable import Stash

struct SavedContentMockTests {
    @Test("기본 mock 인스턴스가 올바르게 생성된다")
    func defaultMock() {
        let content = SavedContent.mock
        #expect(content.title == "테스트 콘텐츠")
        #expect(content.contentType == .web)
        #expect(content.url.absoluteString == "https://example.com")
    }

    @Test("YouTube mock이 올바르게 생성된다")
    func youtubeMock() {
        let content = SavedContent.mockYouTube
        #expect(content.contentType == .youtube)
        #expect(content.metadata["channelName"] == "SwiftDev")
        #expect(content.thumbnailURL != nil)
    }

    @Test("Instagram mock이 올바르게 생성된다")
    func instagramMock() {
        let content = SavedContent.mockInstagram
        #expect(content.contentType == .instagram)
        #expect(content.metadata["username"] == "cafetour")
    }

    @Test("네이버지도 mock이 올바르게 생성된다")
    func naverMapMock() {
        let content = SavedContent.mockNaverMap
        #expect(content.contentType == .naverMap)
        #expect(content.metadata["address"] != nil)
    }

    @Test("구글맵 mock이 올바르게 생성된다")
    func googleMapMock() {
        let content = SavedContent.mockGoogleMap
        #expect(content.contentType == .googleMap)
    }

    @Test("쿠팡 mock이 올바르게 생성된다")
    func coupangMock() {
        let content = SavedContent.mockCoupang
        #expect(content.contentType == .coupang)
        #expect(content.metadata["price"] == "359,000원")
        #expect(content.metadata["seller"] == "Apple 공식스토어")
    }

    @Test("모든 mock의 id가 고유하다")
    func allMocksHaveUniqueIds() {
        let mocks: [SavedContent] = [
            .mock, .mockYouTube, .mockInstagram,
            .mockNaverMap, .mockGoogleMap, .mockCoupang
        ]
        let ids = Set(mocks.map(\.id))
        #expect(ids.count == mocks.count)
    }
}
