import Foundation
import UniformTypeIdentifiers

enum URLExtractor {

    // MARK: - Text Parsing

    static func parseURL(from text: String) -> URL? {
        guard !text.isEmpty else { return nil }

        // 텍스트 전체가 URL인 경우 우선 처리
        if let url = URL(string: text.trimmingCharacters(in: .whitespacesAndNewlines)),
           url.scheme?.hasPrefix("http") == true {
            return url
        }

        // NSDataDetector로 텍스트 내 URL 추출
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)
        let match = detector.firstMatch(in: text, range: range)
        return match?.url
    }

    // MARK: - Extension Item Extraction

    static func extractURL(
        from extensionItems: [Any]?,
        completion: @escaping (URL?) -> Void
    ) {
        guard let items = extensionItems as? [NSExtensionItem],
              let item = items.first,
              let providers = item.attachments else {
            completion(nil)
            return
        }

        // UTType.url 우선 시도
        if let urlProvider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            urlProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { data, _ in
                let url = (data as? URL) ?? (data as? String).flatMap(URL.init(string:))
                completion(url)
            }
            return
        }

        // UTType.plainText 폴백
        if let textProvider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) }) {
            textProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
                let text = data as? String ?? ""
                completion(parseURL(from: text))
            }
            return
        }

        completion(nil)
    }
}
