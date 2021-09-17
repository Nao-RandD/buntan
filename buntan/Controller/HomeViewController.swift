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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

//extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
//
//}

