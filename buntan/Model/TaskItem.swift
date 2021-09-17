//
//  TaskItem.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/13.
//

import Foundation
import RealmSwift

class TaskItem: Object {
    @objc dynamic var taskId = 0
    @objc dynamic var name = ""
    @objc dynamic var point = ""
    override static func primaryKey() -> String? {
        return "taskItem"
    }
}
