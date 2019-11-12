//
//  CategoryViewController.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/10/28.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate { //カテゴリ設定画面

    var delegate: CategoryDelegate?

    @IBOutlet private weak var fieldCategory: UITextField!

    @IBOutlet private weak var colorChooserView: ColorChooserView!

    @IBOutlet private weak var tableCategory: UITableView!

    var selectedCategory: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        fieldCategory.delegate = self

        tableCategory.reloadData()

        // UILongPressGestureRecognizer宣言
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))

        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        longPressRecognizer.delegate = self

        // tableViewにrecognizerを設定
        tableCategory.addGestureRecognizer(longPressRecognizer)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.sharedInstance.getCategories().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let category = Model.sharedInstance.getCategories()[indexPath.row]

        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // セルに表示する値を設定する
        if let label = cell.textLabel {

            label.text = category.category

            label.textColor = UIColor(
                hue: CGFloat(category.color) / CGFloat(COLORMAX),
                saturation: 0.5,
                brightness: 0.9,
                alpha: 1.0)

        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let delegate = delegate else {
            // 処理を任せる相手が決まっていない場合
            return
        }

        delegate.setCategory(category: Model.sharedInstance.getCategories()[indexPath.row])

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

        self.dismiss(animated: true, completion: nil)

    }

    @objc func cellLongPressed(recognizer: UILongPressGestureRecognizer) {

        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: tableCategory)
        let indexPath = tableCategory.indexPathForRow(at: point)

        if indexPath == nil {

        } else if recognizer.state == UIGestureRecognizerState.began {
            // 長押しされた場合の処理
            //("長押しされたcellのindexPath:\(indexPath?.row)")

            showAskPermitDialog(message: String(format: NSLocalizedString("msg_delete_category", comment: ""), Model.sharedInstance.getCategories()[(indexPath?.row)!].category), handler: {(_: UIAlertAction!) -> Void in

                if Model.sharedInstance.getCategories()[(indexPath?.row) ?? 0].category == self.selectedCategory {

                    self.showToastWithConfirm(message: NSLocalizedString("msg_unable_delete_category", comment: ""))

                    return
                }

                Model.sharedInstance.deleteCategory(category: Model.sharedInstance.getCategories()[(indexPath?.row) ?? 0])

                self.tableCategory.reloadData()

                self.delegate?.reloadTable()

            })
        }
    }

    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        self.view.endEditing(true)

        return true
    }

    @IBAction private func actionOk(_ sender: Any) {

        if fieldCategory.isEmpty {

            showToastWithConfirm(message: NSLocalizedString("msg_null_category", comment: ""))

            return
        }

        if isAlreadyExist(category: fieldCategory.text ?? "") {

            showToastWithConfirm(message: NSLocalizedString("msg_exist_category", comment: ""))

            return
        }

        let category = Category()
        category.category = fieldCategory.text ?? ""
        category.color = colorChooserView.getCheckedTag()

        Model.sharedInstance.addCategory(category: category)

        self.dismiss(animated: true, completion: nil)

        guard let delegate = delegate else {
            // 処理を任せる相手が決まっていない場合
            return
        }

        delegate.setCategory(category: category)
    }

    func isAlreadyExist(category: String) -> Bool {

        let categories = Model.sharedInstance.getCategories()

        return !categories.filter { $0.category == category }.isEmpty

    }

    @IBAction private func actionCancel(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)

    }
}
