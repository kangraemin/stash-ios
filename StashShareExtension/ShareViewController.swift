import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        URLExtractor.extractURL(from: extensionContext?.inputItems) { [weak self] url in
            DispatchQueue.main.async {
                guard let self else { return }

                if let url {
                    do {
                        let container = try ShareExtensionSaver.makeContainer()
                        try ShareExtensionSaver.save(url: url, container: container)
                        self.showToast(success: true)
                    } catch {
                        self.showToast(success: false)
                    }
                } else {
                    self.showToast(success: false)
                }
            }
        }
    }

    // MARK: - Toast

    private func showToast(success: Bool) {
        let toast = makeToastView(success: success)
        view.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            toast.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
            toast.heightAnchor.constraint(equalToConstant: 48),
        ])

        toast.alpha = 0
        toast.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            toast.alpha = 1
            toast.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 1.0) {
                toast.alpha = 0
            } completion: { [weak self] _ in
                self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
    }

    private func makeToastView(success: Bool) -> UIView {
        let container = UIView()
        container.backgroundColor = success
            ? UIColor.systemGreen.withAlphaComponent(0.92)
            : UIColor.systemRed.withAlphaComponent(0.92)
        container.layer.cornerRadius = 24

        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        let symbolName = success ? "checkmark" : "xmark"
        let imageView = UIImageView(image: UIImage(systemName: symbolName, withConfiguration: config))
        imageView.tintColor = .white

        let label = UILabel()
        label.text = success ? "저장 완료" : "저장 실패"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)

        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center

        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        return container
    }
}
