import Dependencies
import Foundation

struct MetadataClient {
    var fetch: @Sendable (URL) async throws -> ContentMetadata
}

extension MetadataClient: DependencyKey {
    static let liveValue = MetadataClient(
        fetch: { url in try await OGTagParser.parse(from: url) }
    )

    static let testValue = MetadataClient(
        fetch: { _ in
            ContentMetadata(
                title: "테스트 제목",
                description: "테스트 설명",
                imageURL: URL(string: "https://example.com/image.png"),
                siteName: "테스트 사이트"
            )
        }
    )
}

extension DependencyValues {
    var metadataClient: MetadataClient {
        get { self[MetadataClient.self] }
        set { self[MetadataClient.self] = newValue }
    }
}
