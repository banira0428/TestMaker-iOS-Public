//
//  Question.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2017/01/02.
//  Copyright © 2017年 YamadaKeita. All rights reserved.
//

import Foundation
import RealmSwift

class Question: Object { //realmのバージョンも変える

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var problem: String=""
    @objc dynamic var answer: String=""
    @objc dynamic var correct: Bool = false
    @objc dynamic var solved: Bool = false
    @objc dynamic var auto: Bool = false
    @objc dynamic var isCheckOrder: Bool = false
    @objc dynamic var check: Bool = false
    @objc dynamic var type: Int = -1
    @objc dynamic var explanation: String = ""
    @objc dynamic var imagePath: String = ""
    let others = List<Str>()
    let answers = List<Str>()

    // idをプライマリキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }

    func getAnswer () -> String {

        if type == COMPLETE || type == SELECTCOMPLETE {

            var string = ""

            for str in answers {
                string.append(str.str)
                string.append(" ")
            }

            return string

        } else {
            return answer
        }
    }

    func getProblem(isReverse: Bool) -> String {
        if type != WRITE {
            return problem
        }

        if isReverse {
            return answer
        } else {
            return problem
        }
    }

    func getAnswer(isReverse: Bool) -> String {

        if type != WRITE {
            return getAnswer()
        }

        if isReverse {
            return problem
        } else {
            return answer
        }
    }
}
