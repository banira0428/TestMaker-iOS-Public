//
//  TestCell.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/11/12.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import UIKit

protocol OnlineTestCellProtocol: AnyObject {
    func actionDownload(tag: Int)
    func actionDetail(tag: Int)
}

class OnlineTestCell: UITableViewCell { //問題集を表示するためのセル
    
    @IBOutlet weak var textTitle: UILabel!
    // swiftlint:disable private_outlet
    @IBOutlet weak var textNumber: UILabel!
    @IBOutlet weak var buttonDownLoad: ButtonCustom!
    @IBOutlet weak var buttonDetail: ButtonCustom!
    @IBOutlet weak var colorView: UIView!
    // swiftlint:enable private_outlet
    
    weak var delegate: OnlineTestCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setTag(tag: Int) {
        buttonDownLoad.tag = tag
        buttonDetail.tag = tag
    }
    
    func setValue(documentTest: DocumentTest) {
        
        textTitle.text = documentTest.test.title
        
        textNumber.text = String(format: NSLocalizedString("num_questions", comment: ""),  documentTest.size)
        
        colorView.backgroundColor = UIColor(
            hue: CGFloat(documentTest.test.color) / CGFloat(COLORMAX),
            saturation: 0.5,
            brightness: 0.9,
            alpha: 1.0)
    }
    
    @IBAction func actionDownload(_ sender: ButtonCustom) {
        delegate?.actionDownload(tag: sender.tag)
    }
    
    @IBAction func actionDetail(_ sender: ButtonCustom) {
        delegate?.actionDetail(tag: sender.tag)
    }
}
