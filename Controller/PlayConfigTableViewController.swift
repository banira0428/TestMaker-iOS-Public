//
//  PlayConfigTableViewController.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/03/03.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import UIKit

class PlayConfigTableViewController: UITableViewController {

    // swiftlint:disable private_outlet
    // swiftlint:disable private_action
    @IBOutlet weak var switchRandomOrder: UISwitch!
    @IBOutlet weak var switchWrongOnly: UISwitch!
    @IBOutlet weak var switchJudgeSelf: UISwitch!
    @IBOutlet weak var switchReverse: UISwitch!
    @IBOutlet weak var switchSound: UISwitch!
    @IBOutlet weak var switchExplanation: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        let ud = UserDefaults.standard

        switchRandomOrder.isOn = ud.bool(forKey: "Random")
        switchWrongOnly.isOn = ud.bool(forKey: "WrongOnly")
        switchJudgeSelf.isOn = ud.bool(forKey: "Self")
        switchReverse.isOn = ud.bool(forKey: "Reverse")
        switchSound.isOn = ud.bool(forKey: "BGM")
        switchExplanation.isOn = ud.bool(forKey: "Explanation")

    }

    @IBAction func changeRandomOrder(_ sender: Any) {

        let ud = UserDefaults.standard
        ud.set(switchRandomOrder.isOn, forKey: "Random")
        ud.synchronize()

    }

    @IBAction func changeWrongOnly(_ sender: Any) {

        let ud = UserDefaults.standard
        ud.set(switchWrongOnly.isOn, forKey: "WrongOnly")
        ud.synchronize()

    }

    @IBAction func changeJudgeSelf(_ sender: Any) {

        let ud = UserDefaults.standard
        ud.set(switchJudgeSelf.isOn, forKey: "Self")
        ud.synchronize()

    }

    @IBAction func changeReverse(_ sender: Any) {

        let ud = UserDefaults.standard
        ud.set(switchReverse.isOn, forKey: "Reverse")
        ud.synchronize()

    }

    @IBAction func changeAlwaysExplanation(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.set(switchExplanation.isOn, forKey: "Explanation")
        ud.synchronize()
    }

    @IBAction func changeSound(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.set(switchSound.isOn, forKey: "BGM")
        ud.synchronize()
    }

}
