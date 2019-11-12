//
//  Editview.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2017/01/07.
//  Copyright © 2017年 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import GoogleMobileAds

class EditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, UINavigationControllerDelegate { //問題集内の問題一覧画面

    @IBOutlet private weak var buttonExpand: UIButton!
    // swiftlint:disable private_outlet
    @IBOutlet weak var tableQuestion: UITableView!
    // swiftlint:enable private_outlet
    @IBOutlet private weak var tableBottomConstraint: NSLayoutConstraint!

    var testId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        initAd()

        let ud = UserDefaults.standard
        ud.register(defaults: ["others": 4])

        navigationController?.delegate = self

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableQuestion.reloadData()

    }

    @IBAction private func actionConfig(_ sender: Any) {

        if let targetViewController = self.storyboard?.instantiateViewController( withIdentifier: "configQuestionView" ) as? ConfigQuestionView {

            targetViewController.testId = self.testId

            self.navigationController?.pushViewController( targetViewController, animated: true)

        }
    }

    func getTest() -> Test {
        return Model.sharedInstance.getTest(id: testId)
    }

    /// セルの個数を指定するデリゲートメソッド（必須）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return getTest().questions.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "Quecell") as? QuestionCell {

            cell.textProblem.text = getTest().questions[indexPath.row].problem
            cell.textAnswer.text = getTest().questions[indexPath.row].getAnswer()
            cell.buttonEdit.tag = indexPath.row
            cell.buttonDelete.tag = indexPath.row

            return cell

        }

        return QuestionCell()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction private func actionExpand(_ sender: UIButton) {

        if let targetViewController = self.storyboard?.instantiateViewController( withIdentifier: "eu" ) as? EurekaViewController {

            targetViewController.testId = self.testId

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.navigationController?.pushViewController( targetViewController, animated: true)

            }

        }
    }

    @IBAction private func editQuestion(_ button: UIButton) {

        let test = getTest()

        if let targetViewController = self.storyboard?.instantiateViewController( withIdentifier: "eu" ) as? EurekaViewController {

            targetViewController.testId = self.testId
            targetViewController.questionId = test.questions[button.tag].id

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.navigationController?.pushViewController( targetViewController, animated: true)

            }
        }

    }

    @IBAction private func deleteQuestion(_ sender: UIButton) {

        let test = getTest()

        showAskPermitDialog(message: String(format: NSLocalizedString("msg_delete_question", comment: ""), test.questions[sender.tag].problem), handler: {(_: UIAlertAction!) -> Void in

            Model.sharedInstance.deleteQuestion(id: sender.tag, test: test)
            self.tableQuestion.reloadData()

        })
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        tableQuestion.reloadData()
    }

    func initAd() {

        let ud = UserDefaults.standard
        if ud.bool(forKey: "RemoveAd") {

            tableBottomConstraint.constant = 10

            return
        }

        showAd()

    }
}
