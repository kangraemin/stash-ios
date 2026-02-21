import Dependencies
import Foundation

struct ContentClient {
    var save: @Sendable (SavedContent) async throws -> Void
    var fetch: @Sendable () async throws -> [SavedContent]
    var delete: @Sendable (UUID) async throws -> Void
}

extension ContentClient: DependencyKey {
    static let liveValue: ContentClient = {
        let container = try! ContentModelActor.makeContainer()
        let actor = ContentModelActor(modelContainer: container)
        return ContentClient(
            save: { content in try await actor.save(content) },
            fetch: { try await actor.fetchAll() },
            delete: { id in try await actor.delete(id: id) }
        )
    }()

    static let testValue = ContentClient(
        save: { _ in },
        fetch: { [] },
        delete: { _ in }
    )
}

extension DependencyValues {
    var contentClient: ContentClient {
        get { self[ContentClient.self] }
        set { self[ContentClient.self] = newValue }
    }
}
