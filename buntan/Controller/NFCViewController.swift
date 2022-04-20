//
//  NFCViewController.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/04/19.
//

import UIKit

class NFCViewController: UIViewController {
    var manager: NFCManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        // NFCマネージャー
        manager = NFCManager()
    }
    
    /// NFCを読み取る
    @IBAction func tappedReadButton(_ sender: Any) {
        print("NFCセッション - Read -")
        manager?.startSession(state: .read)
    }

    /// NFCに書き込む
    @IBAction func tappedWriteButton(_ sender: Any) {
        print("NFCセッション - Write -")
        manager?.startSession(state: .write)
    }
}
