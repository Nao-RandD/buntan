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

    private var realm: Realm

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

    func deleteTaskItem(item: ObjectBase) {
        try! realm.write {
            print("\(item)を削除")
            realm.delete(item)
        }
    }

    func deleteAllTaskItem() {
        try! realm.write {
            print("すべてのタスクデータを削除")
            realm.deleteAll()
        }
    }

    private func setTaskItem(task: String,
                     point: Int) -> TaskItem {
        let taskItem = TaskItem()
        taskItem.name = task
        taskItem.point = point
        taskItem.time = getTime()
        taskItem.taskId = getPrimaryKey()

        return taskItem
    }

    private func getPrimaryKey() -> String {
        let uuid = UUID()
        let uniqueIdString = uuid.uuidString
        return uniqueIdString
    }

    private func getTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let strDate = formatter.string(from: date)

        return strDate
    }
}
