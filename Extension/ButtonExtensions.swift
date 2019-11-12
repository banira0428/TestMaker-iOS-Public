//
//  ButtonExtension.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/12/13.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit

extension UIButton { //ボタンのサイズを可変にするための拡張

    func resizeHeight(height: CGFloat) {

        if !constraints.isEmpty {

            removeConstraints(self.constraints)

        }

        if height > 44 {

            heightAnchor.constraint(equalToConstant: height).isActive = true

        } else {

            heightAnchor.constraint(equalToConstant: 44).isActive = true

        }

    }

}
