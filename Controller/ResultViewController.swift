//
//  ResultView.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2017/01/15.
//  Copyright © 2017年 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import GoogleMobileAds


class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate { //テスト結果画面

    var testId: String = ""

    var questions = List<Question>()

    @IBOutlet private weak var text: UILabel!

    @IBOutlet private weak var tableBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        initAd()

        self.navigationItem.hidesBackButton = true

        text.text = String(format: NSLocalizedString("show_result", comment: ""), questions.filter { $0.correct }.count, questions.count)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction private func actionHome(_ sender: Any) {

        navigationController?.popToRootViewController(animated: true)

    }

    @IBAction private func actionRetry(_ sender: Any) {

        let test = Model.sharedInstance.getTest(id: testId)

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let popupView: PlayConfigViewController = storyBoard.instantiateViewController(withIdentifier: "PlayConfigView") as? PlayConfigViewController {

            popupView.modalPresentationStyle = .overFullScreen
            popupView.modalTransitionStyle = .coverVertical

            popupView.testName = test.title
            popupView.onClickStartListener = {

                let ud = UserDefaults.standard
                if test.isAllCorrect() && ud.bool(forKey: "WrongOnly") {
                    self.showToastWithConfirm(message: NSLocalizedString("msg_null_wrong", comment: ""))
                    return
                }

                if let targetViewController = self.storyboard?.instantiateViewController( withIdentifier: "playView" ) as? PlayViewController {
                    targetViewController.testId = test.id
                    targetViewController.isRetry = true
                    self.navigationController?.pushViewController( targetViewController, animated: true)
                }
            }
            self.present(popupView, animated: true, completion: nil)
        }
        return
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return questions.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell") as? ResultCell {

            cell.textProblem.text = questions[indexPath.row].problem
            cell.textAnswer.text = questions[indexPath.row].getAnswer()
            cell.switchCheck.tag = indexPath.row
            cell.setImageMistakeOrCorrect(correct: questions[indexPath.row].correct)

            return cell
        }

        return ResultCell()

    }

    @IBAction private func checkedChanged(_ sender: UISwitch) {

        Model.sharedInstance.checkQuestion(question: questions[sender.tag], check: sender.isOn)

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
