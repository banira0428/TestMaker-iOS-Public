//
//  Model.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2017/01/21.
//  Copyright © 2017年 YamadaKeita. All rights reserved.
//

import Foundation
import GoogleMobileAds
import RealmSwift

class Model: NSObject, GADBannerViewDelegate { //関数の集まり

    let realm = try! Realm()

    class var sharedInstance: Model {
        struct Singleton {
            static let instance = Model()
        }
        return Singleton.instance
    }

    func getTests() -> Results<Test> {

        let sortProperties = [
            SortDescriptor(keyPath: "order", ascending: true),
            SortDescriptor(keyPath: "title", ascending: true) ]

        let tests = realm.objects(Test.self).sorted(by: sortProperties)

        return tests
    }

    func getCategories() -> Results<Category> {

        let categories = realm.objects(Category.self)

        return categories

    }

    func getCategorizedList(category: String) -> Results<Test> {

        return getTests().filter(NSPredicate(format: "category = %@", category))

    }

    func getExistingCategories() -> List<Category> {

        let categories: List<Category> = List<Category>()

        for category in getCategories() {

            for test in getTests() where test.category == category.category {

                categories.append(category)
                break

            }
        }

        return categories
    }

    func getNonCategorizedList() -> List<Test> {

        let tests: List<Test> = List<Test>()

        outside:for test in getTests() {
            for category in getCategories() where category.category == test.category {

                continue outside

            }
            tests.append(test)
        }

        return tests

    }

    func getMixedListCount() -> Int {

        return getNonCategorizedList().count + getExistingCategories().count
    }

    func deleteCategory(category: Category) {
        try! realm.write {

            getTests().filter { $0.category == category.category }.forEach { $0.category = "" }

            realm.delete(category)

        }

    }

    func getTest (id: String) -> Test {

        return realm.objects(Test.self).first(where: { $0.id == id }) ?? Test()

    }

    func addTest(test: Test) {

        try! realm.write {
            realm.add(test, update: true)
        }

    }

    func addCategory(category: Category) {

        try! realm.write {
            realm.add(category, update: true)

        }

    }

    func upTest(test: Test, title: String, color: Int, category: String) {

        try! realm.write {
            test.title = title
            test.color = color
            test.category = category
        }

        addTest(test: test)
    }

    func sort (source: Test, destination: Test) {

        try! realm.write {
            let inst = source.order
            source.order = destination.order
            destination.order = inst
        }

    }

    func deleteTest (test: Test) {

        try! realm.write {

            for question in test.questions where !question.imagePath.isEmpty {

                do {

                    try FileManager.default.removeItem( atPath: question.imagePath )

                } catch {

                    //エラー処理
                    print("error")

                }

            }

            realm.delete(test)
        }

    }

    func deleteQuestion(id: Int, test: Test) {

        try! realm.write {

            if !test.questions[id].imagePath.isEmpty {

                do {

                    try FileManager.default.removeItem( atPath: test.questions[id].imagePath )

                } catch {

                    //エラー処理
                    print("error")

                }
            }

            test.questions.remove(at: id)

        }

        addTest(test: test)

    }

    func addQuestion(question: Question, test: Test, id: String) {

        try! realm.write {

            if id.isEmpty {
                test.questions.append(question)
            } else {

                for i in 0..<test.questions.count where test.questions[i].id == id {

                    test.questions[i].problem = question.problem
                    test.questions[i].answer = question.answer
                    test.questions[i].type = question.type
                    test.questions[i].imagePath = question.imagePath
                    test.questions[i].explanation = question.explanation
                    test.questions[i].correct = false
                    test.questions[i].auto = question.auto
                    test.questions[i].others.removeAll()
                    test.questions[i].answers.removeAll()
                    for j in 0..<question.others.count {
                        let s = Str()
                        s.str = question.others[j].str
                        test.questions[i].others.append(s)
                    }

                    for j in 0..<question.answers.count {
                        let s = Str()
                        s.str = question.answers[j].str
                        test.questions[i].answers.append(s)
                    }

                }
            }

        }

        addTest(test: test)
    }

    func correctQuestion(question: Question, correct: Bool) {
        try! realm.write {
            question.correct = correct
            if correct {
                question.check = false
            } else {
                question.check = true
            }

            realm.add(question, update: true)
        }
    }

    func changeQuestionSolved(question: Question, solved: Bool) {

        try! realm.write {
            question.solved = solved
            realm.add(question, update: true)
        }
    }

    func resetSolved(test: Test) {
        try! realm.write {
            test.questions.forEach { $0.solved = false }
        }
        addTest(test: test)
    }

    func checkQuestion(question: Question, check: Bool) {

        try! realm.write {
            question.check = check
            realm.add(question, update: true)
        }
    }
    
    func resetAchievement(test: Test){
        
        try! realm.write {
            test.questions.forEach { $0.correct = false }
        }
        addTest(test: test)

        
    }

}
