import Foundation
import Testing
@testable import Stash

struct DeepLinkBuilderTests {

    // MARK: - Universal Link (원본 URL 그대로)

    @Test("YouTube 콘텐츠는 원본 URL을 그대로 반환한다")
    func youtubeDeepLink() {
        let url = DeepLinkBuilder.deepLinkURL(for: .mockYouTube)
        #expect(url == SavedContent.mockYouTube.url)
    }

    @Test("Instagram 콘텐츠는 원본 URL을 그대로 반환한다")
    func instagramDeepLink() {
        let url = DeepLinkBuilder.deepLinkURL(for: .mockInstagram)
        #expect(url == SavedContent.mockInstagram.url)
    }

    @Test("구글맵 콘텐츠는 원본 URL을 그대로 반환한다")
    func googleMapDeepLink() {
        let url = DeepLinkBuilder.deepLinkURL(for: .mockGoogleMap)
        #expect(url == SavedContent.mockGoogleMap.url)
    }

    @Test("쿠팡 콘텐츠는 원본 URL을 그대로 반환한다")
    func coupangDeepLink() {
        let url = DeepLinkBuilder.deepLinkURL(for: .mockCoupang)
        #expect(url == SavedContent.mockCoupang.url)
    }

    @Test("일반 웹 콘텐츠는 원본 URL을 그대로 반환한다")
    func webDeepLink() {
        let url = DeepLinkBuilder.deepLinkURL(for: .mock)
        #expect(url == SavedContent.mock.url)
    }

    // MARK: - 네이버지도 딥링크

    @Test("네이버지도 콘텐츠는 nmap:// scheme URL을 반환한다")
    func naverMapDeepLink() {
        let url = DeepLinkBuilder.deepLinkURL(for: .mockNaverMap)
        #expect(url.scheme == "nmap")
        #expect(url.host == "place")
    }

    @Test("네이버지도 딥링크에 원본 URL이 쿼리로 포함된다")
    func naverMapDeepLinkContainsOriginalURL() {
        let url = DeepLinkBuilder.deepLinkURL(for: .mockNaverMap)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let urlParam = components?.queryItems?.first { $0.name == "url" }?.value
        #expect(urlParam == SavedContent.mockNaverMap.url.absoluteString)
    }

    @Test("네이버지도 딥링크에 앱 번들 ID가 포함된다")
    func naverMapDeepLinkContainsAppName() {
        let url = DeepLinkBuilder.deepLinkURL(for: .mockNaverMap)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let appname = components?.queryItems?.first { $0.name == "appname" }?.value
        #expect(appname == "com.kangraemin.stash")
    }

    // MARK: - canDeepLink

    @Test("모든 ContentType이 딥링크 가능하다")
    func canDeepLinkAllTypes() {
        for type in ContentType.allCases {
            #expect(DeepLinkBuilder.canDeepLink(type) == true)
        }
    }
}
