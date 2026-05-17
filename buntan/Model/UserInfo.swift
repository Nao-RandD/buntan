//
//  UserInfo.swift
//  buntan
//
//  Created by Naoyuki Kan on 2021/09/14.
//

import Foundation

struct UserInfo: Identifiable {
    var name: String
    var point: Int

    var id: String { name }

    init(name: String, point: Int) {
        self.name = name
        self.point = point
    }
}
