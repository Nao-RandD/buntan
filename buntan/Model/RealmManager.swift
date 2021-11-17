//
//  RealmManager.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/10/16.
//

import Foundation
import RealmSwift

final class RealmManager {

    public static let shared = RealmManager()

    private var realm: Realm!

    private init() {
        realm = try! Realm()
    }

    private func getTaskNumber() -> Int {
        let taskList = getTaskInRealm()
        return taskList.count
    }

    func getTaskInRealm() -> Results<TaskItem> {
        return realm.objects(TaskItem.self)
    }

    func getTotalPoint() -> Int {
        let taskHistory = getTaskInRealm()
        var point = 0
        taskHistory.forEach { point += $0.point }
        return point
    }

    func writeTaskItem(task: String, point: Int) {
        let item = setTaskItem(task: task, point: point)

        try! realm.write {
            realm.add(item)
            print("新しいリスト追加：\(task)")
        }
    }

    private func setTaskItem(task: String,
                     point: Int) -> TaskItem {
        let taskItem = TaskItem()
        let taskNum = getTaskNumber()
        taskItem.name = task
        taskItem.point = point
        taskItem.taskId = taskNum + 1

        return taskItem
    }
}
