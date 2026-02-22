import Dependencies
import Foundation
import UIKit

struct OpenURLClient {
    var open: @Sendable (URL) async -> Bool
}

extension OpenURLClient: DependencyKey {
    static let liveValue = OpenURLClient(
        open: { url in
            await UIApplication.shared.open(url)
        }
    )

    static let testValue = OpenURLClient(
        open: { _ in true }
    )
}

extension DependencyValues {
    var openURLClient: OpenURLClient {
        get { self[OpenURLClient.self] }
        set { self[OpenURLClient.self] = newValue }
    }
}
