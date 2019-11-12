//
//  UILabelExtention.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/02/14.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {

    func showTextIfExisting(textFormated: String, text: String) {

        self.isHidden = false

        if text.isEmpty {
            self.isHidden = true
        } else {
            self.text = textFormated
        }
    }

}
