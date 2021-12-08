//
//  TaskItem.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/13.
//

import Foundation
import RealmSwift

class TaskItem: Object {
    @objc dynamic var taskId = ""
    @objc dynamic var name = ""
    @objc dynamic var point = 0
    @objc dynamic var time = ""
    override static func primaryKey() -> String? {
        return "taskId"
    }
}
