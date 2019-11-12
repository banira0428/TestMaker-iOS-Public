//
//  QuestionCell.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2017/01/08.
//  Copyright © 2017年 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit

class QuestionCell: UITableViewCell { //編集画面で問題を表示するためのセル

    // swiftlint:disable private_outlet
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var textProblem: UILabel!
    @IBOutlet weak var textAnswer: UILabel!
    @IBOutlet weak var buttonEdit: UIButton!
    // swiftlint:enable private_outlet

}
