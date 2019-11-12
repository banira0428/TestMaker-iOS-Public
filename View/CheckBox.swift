//
//  CheckBox.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/09/24.
//  Copyright © 2018年 YamadaKeita. All rights reserved.
//

import UIKit

/// Androidのチェックボックスのようなもの
@IBDesignable
class CheckBox: UIButton {

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

    var selectView: UIView! = nil

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

        // ボタンを押している時にボタンの色を暗くするためのView
        selectView = UIView(frame: self.bounds)
        selectView.backgroundColor = UIColor.black
        selectView.alpha = 0.0
        self.addSubview(selectView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        selectView.frame = self.bounds
    }

    // タッチ開始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {() -> Void in

            self.selectView.alpha = 0.5

        }, completion: {(_: Bool) -> Void in
        })
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {() -> Void in

            self.selectView.alpha = 0.0

        }, completion: {(_: Bool) -> Void in
        })
    }
    // タッチ終了
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {() -> Void in

            self.selectView.alpha = 0.0

        }, completion: {(_: Bool) -> Void in
        })
    }

    @IBInspectable var notSelectedBackgroundColor: UIColor?

    @IBInspectable var selectedBackgroundColor: UIColor?

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

    // Bool property
    public var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.backgroundColor = selectedBackgroundColor
                self.imageView?.layer.transform = CATransform3DIdentity
            } else {
                self.backgroundColor = notSelectedBackgroundColor
                self.imageView?.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)

            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }

    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked.toggle()
        }
    }

}
