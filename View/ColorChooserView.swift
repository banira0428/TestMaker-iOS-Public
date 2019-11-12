//
//  ColorChooserView.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/10/21.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import UIKit

/// 色選択のためのレイアウト部品
class ColorChooserView: UIView {

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

    // swiftlint:disable private_outlet
    @IBOutlet var colorViews: [CheckBox]!
    // swiftlint:enable private_outlet

    //コードから生成したときに通る初期化処理
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    //InterfaceBulderで配置した場合に通る初期化処理
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    fileprivate func commonInit() {
        //MyCustomView.xibファイルからViewを生成する。
        //File's OwnerはMyCustomViewなのでselfとする。
        // File's OwnerをXibViewにしたので ownerはself になる
        guard let view = UINib(nibName: "ColorChooserView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }

        view.frame = self.bounds

        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        self.addSubview(view)

        for button in colorViews {
            button.addTarget(self, action: #selector(buttonEvent(sender:)), for: .touchUpInside)

            button.imageView?.contentMode = .scaleAspectFit
        }

        colorViews[0].isChecked = true

    }

    @objc func buttonEvent(sender: CheckBox) {

        colorViews.forEach { $0.isChecked = false }

        sender.isChecked = true

    }

    func getCheckedTag() -> Int {

        for button in colorViews where button.isChecked {

            return button.tag

        }

        return 0
    }

    func setChecked(tag: Int) {

        colorViews.forEach { $0.isChecked = false }

        colorViews.filter { $0.tag == tag }[0].isChecked = true
    }
}
