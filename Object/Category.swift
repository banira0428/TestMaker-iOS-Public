//
//  Category.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/10/28.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var category: String=""
    @objc dynamic var color = 0

    // idをプライマリキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
