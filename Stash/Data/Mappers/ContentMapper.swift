import Foundation

enum ContentMapper {
    static func toDomain(_ sdContent: SDContent) -> SavedContent {
        let url = URL(string: sdContent.urlString) ?? URL(string: "https://invalid.url")!
        let contentType = ContentType(rawValue: sdContent.contentTypeRawValue) ?? .web
        let thumbnailURL: URL? = sdContent.thumbnailURLString.flatMap { URL(string: $0) }
        let metadata = decodeMetadata(sdContent.metadataJSON)

        return SavedContent(
            id: sdContent.id,
            title: sdContent.title,
            url: url,
            contentType: contentType,
            createdAt: sdContent.createdAt,
            thumbnailURL: thumbnailURL,
            summary: sdContent.summary,
            metadata: metadata
        )
    }

    static func toData(_ savedContent: SavedContent) -> SDContent {
        SDContent(
            id: savedContent.id,
            title: savedContent.title,
            urlString: savedContent.url.absoluteString,
            contentTypeRawValue: savedContent.contentType.rawValue,
            createdAt: savedContent.createdAt,
            thumbnailURLString: savedContent.thumbnailURL?.absoluteString,
            summary: savedContent.summary,
            metadataJSON: encodeMetadata(savedContent.metadata)
        )
    }

    private static func decodeMetadata(_ json: String?) -> [String: String] {
        guard let json, let data = json.data(using: .utf8) else { return [:] }
        return (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
    }

    static func encodeMetadata(_ metadata: [String: String]) -> String? {
        guard !metadata.isEmpty else { return nil }
        guard let data = try? JSONEncoder().encode(metadata) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
