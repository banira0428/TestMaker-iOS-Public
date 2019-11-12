//
//  TestCell.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/11/12.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import UIKit

protocol TestCellProtocol: AnyObject {
    func actionPlay(tag: Int)
    func actionEdit(tag: Int)
    func actionDelete(tag: Int)
    func actionShare(tag: Int)
}

class TestCell: UITableViewCell { //問題集を表示するためのセル

    // swiftlint:disable private_outlet
    @IBOutlet weak var textTitle: UILabel!
    @IBOutlet weak var textNumber: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var buttonPlay: ButtonCustom!
    @IBOutlet weak var buttonEdit: ButtonCustom!
    @IBOutlet weak var buttonDelete: ButtonCustom!
    @IBOutlet weak var buttonShare: ButtonCustom!
    // swiftlint:enable private_outlet

    weak var delegate: TestCellProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setTag(tag: Int) {
        buttonPlay.tag = tag
        buttonEdit.tag = tag
        buttonDelete.tag = tag
        buttonShare.tag = tag
    }

    func setValue(test: Test) {

        textTitle.text = test.title

        textNumber.text = String(format: NSLocalizedString("achievement", comment: ""), test.getCorrectCount(), test.questions.count)

        colorView.backgroundColor = UIColor(
            hue: CGFloat(test.color) / CGFloat(COLORMAX),
            saturation: 0.5,
            brightness: 0.9,
            alpha: 1.0)
    }

    @IBAction func actionPlay(_ sender: ButtonCustom) {
        delegate?.actionPlay(tag: sender.tag)
    }

    @IBAction func actionEdit(_ sender: ButtonCustom) {
        delegate?.actionEdit(tag: sender.tag)
    }

    @IBAction func actionDelete(_ sender: ButtonCustom) {
        delegate?.actionDelete(tag: sender.tag)
    }

    @IBAction func actionShare(_ sender: ButtonCustom) {
        delegate?.actionShare(tag: sender.tag)
    }
}
