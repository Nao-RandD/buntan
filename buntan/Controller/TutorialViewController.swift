//
//  TutorialViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/01/08.
//

import UIKit

class TutorialViewController: UIViewController {
    private var image: UIImage?
    private var targetFrame: CGRect = .zero
    private var imageView: UIImageView!
    private let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        imageView = UIImageView(frame: targetFrame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        view.addSubview(imageView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tap)
    }

    @objc private func didTap() {
        userDefaults.set(true, forKey: "isShowTutorial")
        dismiss(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let viewController = PopViewController()
        viewController.modalPresentationStyle = .popover
        viewController.preferredContentSize = .init(width: 300, height: 100)
        viewController.text = "+ボタンからタスクを追加してみましょう！"

        var frame = imageView.bounds
        frame.origin.x = frame.width * 0.8
        print(dump(frame))

        let presentationController = viewController.popoverPresentationController
        presentationController?.delegate = self
        presentationController?.permittedArrowDirections = .up
        presentationController?.sourceView = imageView
        presentationController?.sourceRect = frame
//        presentationController?.sourceView = super.view
//        presentationController?.sourceRect = frame
        present(viewController, animated: false)
    }

    func showTutorial(from parent: UIViewController, target: UIView) {
        modalPresentationStyle = .overCurrentContext
//        targetFrame = target.convert(target.bounds, to: nil)
        targetFrame = target.frame
        image = target.screenCapture()
        parent.present(self, animated: false)
    }
}

// ポップで表示用
extension TutorialViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// ポップで説明出す用
final class PopViewController: UIViewController {

    var text: String?
    private var label: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        label = UILabel(frame: .zero)
        label?.textAlignment = .center
        label?.numberOfLines = 0
        view.addSubview(label!)
        label?.text = text
        label?.font = .systemFont(ofSize: 20)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label?.frame = view.bounds
    }
}

// Viewのスクショ撮る用
extension UIView {

    func screenCapture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}

extension UIBarButtonItem {

    var frame: CGRect? {
        guard let view = self.value(forKey: "view") as? UIView else {
            return nil
        }
        return view.frame
    }

}
