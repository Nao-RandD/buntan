//
//  HomeViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/08.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    private var taskList: Results<TaskItem>!
    var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        indicator = UIActivityIndicatorView()
        view.addSubview(indicator)
    }

    @IBAction func tappedSendButton(_ sender: Any) {
        showIndicator()

        DispatchQueue.main.async {
            sleep(3)
            self.indicator.stopAnimating()
            self.showDoneImage()
        }
    }

    private func showIndicator() {
        guard let indicator = indicator else {
            return
        }
        indicator.center = view.center
        indicator.style = .whiteLarge
        indicator.color = .darkGray

        indicator.startAnimating()
    }

    private func showDoneImage() {
        let image = UIImage(named: "Done")
        let imageView = UIImageView(image: image)

        imageView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        view.addSubview(imageView)
    }

//    func hideIndicator(){
//        // viewにローディング画面が出ていれば閉じる
//        if let viewWithTag = self.view.viewWithTag(100100) {
//            viewWithTag.removeFromSuperview()
//        }
//    }
}

//extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
//
//}

