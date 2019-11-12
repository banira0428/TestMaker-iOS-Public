//
//  Test.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2017/01/01.
//  Copyright © 2017年 YamadaKeita. All rights reserved.
//

import Foundation
import RealmSwift

class Test: Object {

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var order = 0
    @objc dynamic var title: String = ""
    @objc dynamic var category: String = ""
    let questions = List<Question>()
    @objc dynamic var color = 0

    // idをプライマリキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }

    // titleにインデックスを貼る
    override static func indexedProperties() -> [String] {
        return ["title"]
    }

    func getCorrectCount() -> Int {

        let array = questions.filter { $0.correct }

        return array.count
    }

    func isAllCorrect() -> Bool {

        return getCorrectCount() == questions.count

    }

    func getQuestionsSolved() -> List<Question> {

        let array = List<Question>()
        questions.forEach { if $0.solved { array.append($0) } }

        return array
    }
}
