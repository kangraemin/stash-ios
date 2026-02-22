import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        URLExtractor.extractURL(from: extensionContext?.inputItems) { [weak self] url in
            // TODO: Step 3.2에서 SwiftData 저장 구현
            // TODO: Step 3.3에서 토스트 피드백 구현
            self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}
