//
//  CategoryCell.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/11/10.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit

class CategoryCell: UITableViewCell { //カテゴリを表示するためのセル

    // swiftlint:disable private_outlet
    @IBOutlet weak var textCategory: UILabel!
    @IBOutlet weak var textNumber: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var buttonOpen: ButtonCustom!
    // swiftlint:enable private_outlet

    func setTag(tag: Int) {
        textCategory.tag = tag
        textNumber.tag = tag
        colorView.tag = tag
        buttonOpen.tag = tag
    }
}
