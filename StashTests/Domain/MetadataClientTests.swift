import Dependencies
import Foundation
import Testing
@testable import Stash

struct MetadataClientTests {

    @Test("testValue가 mock ContentMetadata를 반환한다")
    func testValueReturnsMock() async throws {
        let client = withDependencies {
            $0.metadataClient = .testValue
        } operation: {
            @Dependency(\.metadataClient) var metadataClient
            return metadataClient
        }

        let url = URL(string: "https://example.com")!
        let metadata = try await client.fetch(url)

        #expect(metadata.title == "테스트 제목")
        #expect(metadata.description == "테스트 설명")
        #expect(metadata.imageURL == URL(string: "https://example.com/image.png"))
        #expect(metadata.siteName == "테스트 사이트")
    }

    @Test("ContentMetadata 기본값은 모두 nil이다")
    func defaultMetadataIsNil() {
        let metadata = ContentMetadata()
        #expect(metadata.title == nil)
        #expect(metadata.description == nil)
        #expect(metadata.imageURL == nil)
        #expect(metadata.siteName == nil)
    }

    @Test("ContentMetadata Equatable이 동작한다")
    func equatable() {
        let a = ContentMetadata(title: "제목", siteName: "사이트")
        let b = ContentMetadata(title: "제목", siteName: "사이트")
        let c = ContentMetadata(title: "다른 제목")
        #expect(a == b)
        #expect(a != c)
    }
}
