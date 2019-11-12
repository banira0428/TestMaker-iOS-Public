//
//  Str.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2017/01/02.
//  Copyright © 2017年 YamadaKeita. All rights reserved.
//

import Foundation
import RealmSwift

class Str: Object {

    @objc dynamic var str = ""

    // Specify properties to ignore (Realm won't persist these)

    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}
