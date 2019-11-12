//
//  CustomImageView.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/09/20.
//  Copyright © 2018年 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomInageView: UIImageView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        contentMode = .scaleAspectFit

    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentMode = .scaleAspectFit

    }

}
