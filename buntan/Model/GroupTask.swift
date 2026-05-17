//
//  GroupTask.swift
//  buntan
//
//  Created by Naoyuki Kan on 2022/07/23.
//

import Foundation

struct GroupTask: Hashable, Identifiable {
    var group: String
    var name: String
    var point: Int

    var id: String { "\(group)/\(name)" }
}
