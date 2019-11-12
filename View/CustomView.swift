//
//  CustomView.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/03/02.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        myInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        myInit()
    }

    func myInit() {

        // 角を丸くする
        self.layer.cornerRadius = 3
        self.clipsToBounds = true

    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

}
