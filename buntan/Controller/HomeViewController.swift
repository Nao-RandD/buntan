//
//  HomeViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/08.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var indicator: UIActivityIndicatorView!
    private var taskList: Results<TaskItem>!
    private var realm: Realm!
    private var token: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        indicator = UIActivityIndicatorView()
        view.addSubview(indicator)

        realm = try! Realm()
        taskList = realm.objects(TaskItem.self)
        token = taskList.observe { [weak self] _ in
          self?.reload()
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "TaskCell")
    }

    private func reload() {
        tableView.reloadData()
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

    @IBAction private func exit(segue: UIStoryboardSegue) {}

//    func hideIndicator(){
//        // viewにローディング画面が出ていれば閉じる
//        if let viewWithTag = self.view.viewWithTag(100100) {
//            viewWithTag.removeFromSuperview()
//        }
//    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let taskList = taskList else {
            return 0
        }
        return taskList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell

        // カスタムセルにRealmの情報を反映
        cell.configure(taskName: taskList[indexPath.row].name,
                       point: taskList[indexPath.row].point)
        return cell
    }
}
