//
//  ResultsCell.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2017/01/18.
//  Copyright © 2017年 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit

class ResultCell: UITableViewCell { //テスト結果を表示するためのセル（正解，不正解）

    // swiftlint:disable private_outlet
    @IBOutlet weak var textProblem: UILabel!
    @IBOutlet weak var textAnswer: UILabel!
    @IBOutlet weak var switchCheck: UISwitch!
    @IBOutlet weak var imageMistake: UIImageView!
    @IBOutlet weak var imageCorrect: UIImageView!
    // swiftlint:enable private_outlet

    func setImageMistakeOrCorrect(correct: Bool) {

        if correct {
            imageCorrect.alpha = 1
            imageMistake.alpha = 0
        } else {
            imageCorrect.alpha = 0
            imageMistake.alpha = 1
        }
    }

}
