//
//  TextToTestConverter.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/03/09.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import Foundation

public class TextToTestConverter {

    static func textToTest(text: String) -> Test {

        let test = Test()
        test.title = NSLocalizedString("unknown", comment: "")
        //改行コードが"\r"で行なわれている場合は"\n"に変更する
        let lineChange = text.replacingOccurrences(of: "\r\n", with: "\n")
        //"\n"の改行コードで区切って、配列csvArrayに格納する
        let testArray = lineChange.components(separatedBy: "\n")

        var sizeOfQuestions: Int = 0

        for string in testArray {
            var backup = string.replacingOccurrences(of: "<br>", with: "\n").components(separatedBy: ",").filter { !$0.isEmpty }

            for (i, s) in backup.enumerated() {
                backup[i] = s.replacingOccurrences(of: "<comma>", with: ",")
            }

            if backup.count > 2 {

                let q = Question()
                q.problem = backup[1]

                switch backup[0] {
                case NSLocalizedString("load_write", comment: ""):

                    q.answer = backup[2]
                    q.type = WRITE

                    test.questions.append(q)

                    sizeOfQuestions += 1

                case NSLocalizedString("load_complete", comment: ""):

                    q.type = COMPLETE

                    if backup.count - 2 > ANSWERMAX {
                        break
                    }

                    for i in 2..<backup.count {
                        let s = Str()
                        s.str = backup[i]
                        q.answers.append(s)
                    }

                    test.questions.append(q)

                    sizeOfQuestions += 1
                    
                case NSLocalizedString("load_complete_order", comment: ""):
                    
                    q.type = COMPLETE
                    q.isCheckOrder = true
                    
                    if backup.count - 2 > ANSWERMAX {
                        break
                    }
                    
                    for i in 2..<backup.count {
                        let s = Str()
                        s.str = backup[i]
                        q.answers.append(s)
                    }
                    
                    test.questions.append(q)
                    
                    sizeOfQuestions += 1

                case NSLocalizedString("load_select", comment: ""):
                    q.type = SELECT

                    q.answer = backup[2]

                    if backup.count - 3 > OTHERSELECTMAX {
                        break
                    }

                    for i in 3..<backup.count {
                        let s = Str()
                        s.str = backup[i]
                        q.others.append(s)
                    }

                    test.questions.append(q)
                    sizeOfQuestions += 1

                case NSLocalizedString("load_select_auto", comment: ""):

                    q.type = SELECT
                    q.answer = backup[2]
                    q.auto = true

                    let otherNum = Int(backup[3].prefix(1)) ?? 0

                    if otherNum > OTHERSELECTMAX {
                        break
                    }

                    for _ in 0..<otherNum {
                        let s = Str()
                        s.str = NSLocalizedString("value_auto", comment: "")
                        q.others.append(s)
                    }

                    test.questions.append(q)
                    sizeOfQuestions += 1

                case NSLocalizedString("load_select_complete_auto", comment: ""):

                    let otherNum = Int(backup[2].prefix(1)) ?? 0

                    if otherNum <= OTHERSELECTMAX {

                        if otherNum + backup.count - 3 > SELECTCOMPLETEMAX {
                            continue //要素数オーバー
                        }

                        for _ in 0..<otherNum {
                            let s = Str()
                            s.str = NSLocalizedString("value_auto", comment: "")
                            q.others.append(s)
                        }

                        backup.suffix(backup.count - 3).forEach {
                            let s = Str()
                            s.str = $0
                            q.answers.append(s)
                        }

                        q.auto = true
                        q.type = SELECTCOMPLETE

                        test.questions.append(q)
                        sizeOfQuestions += 1

                    }

                case NSLocalizedString("load_select_complete", comment: ""):
                    let answerNum = Int(backup[2].prefix(1)) ?? 0

                    let otherNum = Int(backup[3].prefix(1)) ?? 0

                    if answerNum == 0 || otherNum == 0 {

                        continue
                    }

                    if otherNum + answerNum > SELECTCOMPLETEMAX {

                        continue
                    } //要素数オーバー

                    Array(backup[4..<4 + answerNum]).forEach {
                        let s = Str()
                        s.str = $0
                        q.answers.append(s)
                    }

                    Array(backup[4 + answerNum..<4 + answerNum + otherNum]).forEach {
                        let s = Str()
                        s.str = $0
                        q.others.append(s)
                    }

                    q.type = SELECTCOMPLETE

                    test.questions.append(q)

                    sizeOfQuestions += 1

                default:
                    break

                }
            } else if backup.count == 2 {

                switch backup[0] {
                case NSLocalizedString("title", comment: ""):
                    test.title = backup[1]
                case NSLocalizedString("explanation", comment: ""):
                    if sizeOfQuestions > 0 {
                        test.questions[sizeOfQuestions - 1].explanation = backup[1]
                    }
                case NSLocalizedString("color", comment: ""):
                    test.color = Int(backup[1]) ?? 0

                default:
                    break
                }

            }

        }

        return test

    }

}
