//
//  ArrayExtension.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/12/13.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    var unique: [Element] {
        var r = [Element]()
        for i in self {
            r += !r.contains(i) ? [i] : []
        }
        return r
    }
}
