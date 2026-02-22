import Foundation
import Testing
@testable import Stash

struct URLExtractorTests {

    // MARK: - 정상 URL

    @Test("정상 URL 문자열에서 URL을 반환한다")
    func validURL() {
        let result = URLExtractor.parseURL(from: "https://www.youtube.com/watch?v=abc123")
        #expect(result?.absoluteString == "https://www.youtube.com/watch?v=abc123")
    }

    @Test("http URL도 정상적으로 파싱한다")
    func httpURL() {
        let result = URLExtractor.parseURL(from: "http://example.com/page")
        #expect(result?.absoluteString == "http://example.com/page")
    }

    // MARK: - 텍스트 내 URL 추출

    @Test("텍스트에 포함된 URL을 추출한다")
    func urlInText() {
        let text = "이 링크 확인해봐 https://www.instagram.com/p/ABC123 재밌어"
        let result = URLExtractor.parseURL(from: text)
        #expect(result?.host?.contains("instagram.com") == true)
    }

    @Test("여러 URL이 있으면 첫 번째를 반환한다")
    func multipleURLs() {
        let text = "https://first.com 그리고 https://second.com"
        let result = URLExtractor.parseURL(from: text)
        #expect(result?.host == "first.com")
    }

    // MARK: - URL 없는 텍스트

    @Test("URL이 없는 일반 텍스트에서 nil을 반환한다")
    func plainText() {
        let result = URLExtractor.parseURL(from: "그냥 일반 텍스트입니다")
        #expect(result == nil)
    }

    @Test("숫자만 있는 텍스트에서 nil을 반환한다")
    func numbersOnly() {
        let result = URLExtractor.parseURL(from: "12345")
        #expect(result == nil)
    }

    // MARK: - 빈 문자열

    @Test("빈 문자열에서 nil을 반환한다")
    func emptyString() {
        let result = URLExtractor.parseURL(from: "")
        #expect(result == nil)
    }

    @Test("공백만 있는 문자열에서 nil을 반환한다")
    func whitespaceOnly() {
        let result = URLExtractor.parseURL(from: "   ")
        #expect(result == nil)
    }
}
