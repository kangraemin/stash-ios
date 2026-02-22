import Foundation
import Testing
@testable import Stash

struct OGTagParserTests {

    // MARK: - 전체 OG 태그 포함

    @Test("모든 OG 태그가 포함된 HTML에서 전체 필드를 추출한다")
    func allOGTags() {
        let html = """
        <html><head>
        <meta property="og:title" content="테스트 제목">
        <meta property="og:description" content="테스트 설명입니다">
        <meta property="og:image" content="https://example.com/image.png">
        <meta property="og:site_name" content="테스트 사이트">
        </head></html>
        """

        let metadata = OGTagParser.extractOGTags(from: html)

        #expect(metadata.title == "테스트 제목")
        #expect(metadata.description == "테스트 설명입니다")
        #expect(metadata.imageURL == URL(string: "https://example.com/image.png"))
        #expect(metadata.siteName == "테스트 사이트")
    }

    // MARK: - 일부 OG 태그 누락

    @Test("OG 태그 일부가 누락되면 해당 필드가 nil이다")
    func partialOGTags() {
        let html = """
        <html><head>
        <meta property="og:title" content="제목만 있음">
        </head></html>
        """

        let metadata = OGTagParser.extractOGTags(from: html)

        #expect(metadata.title == "제목만 있음")
        #expect(metadata.description == nil)
        #expect(metadata.imageURL == nil)
        #expect(metadata.siteName == nil)
    }

    // MARK: - 빈 HTML

    @Test("빈 HTML에서 모든 필드가 nil이다")
    func emptyHTML() {
        let metadata = OGTagParser.extractOGTags(from: "")

        #expect(metadata.title == nil)
        #expect(metadata.description == nil)
        #expect(metadata.imageURL == nil)
        #expect(metadata.siteName == nil)
    }

    // MARK: - content 순서가 앞에 오는 경우

    @Test("content가 property보다 앞에 오는 HTML도 파싱한다")
    func contentBeforeProperty() {
        let html = """
        <meta content="역순 제목" property="og:title">
        <meta content="역순 설명" property="og:description">
        """

        let metadata = OGTagParser.extractOGTags(from: html)

        #expect(metadata.title == "역순 제목")
        #expect(metadata.description == "역순 설명")
    }

    // MARK: - name 속성 사용

    @Test("name 속성으로 된 OG 태그도 파싱한다")
    func nameAttribute() {
        let html = """
        <meta name="og:title" content="name 속성 제목">
        <meta name="og:site_name" content="name 속성 사이트">
        """

        let metadata = OGTagParser.extractOGTags(from: html)

        #expect(metadata.title == "name 속성 제목")
        #expect(metadata.siteName == "name 속성 사이트")
    }

    // MARK: - 잘못된 메타 태그

    @Test("property가 없는 meta 태그는 무시한다")
    func invalidMetaTag() {
        let html = """
        <meta content="값만 있음">
        <meta charset="utf-8">
        """

        let metadata = OGTagParser.extractOGTags(from: html)

        #expect(metadata.title == nil)
        #expect(metadata.description == nil)
    }

    // MARK: - 대소문자 혼용

    @Test("대소문자가 혼용된 meta 태그도 파싱한다")
    func caseInsensitive() {
        let html = """
        <META Property="og:title" Content="대소문자 제목">
        """

        let metadata = OGTagParser.extractOGTags(from: html)

        #expect(metadata.title == "대소문자 제목")
    }

    // MARK: - 작은따옴표

    @Test("작은따옴표로 감싼 OG 태그도 파싱한다")
    func singleQuotes() {
        let html = """
        <meta property='og:title' content='작은따옴표 제목'>
        <meta property='og:description' content='작은따옴표 설명'>
        """

        let metadata = OGTagParser.extractOGTags(from: html)

        #expect(metadata.title == "작은따옴표 제목")
        #expect(metadata.description == "작은따옴표 설명")
    }
}
