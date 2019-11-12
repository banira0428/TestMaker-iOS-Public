//
//  PlayConfigViewController.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/03/02.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import UIKit

class PlayConfigViewController: UIViewController {

    var onClickStartListener:() -> Void = {}
    var testName: String = ""

    @IBOutlet private weak var textTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        textTitle.text = testName

    }

    @IBAction private func onClickStart(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)

        onClickStartListener()

    }

    @IBAction private func onCanceled(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)

    }

}
