//
//  ConfigQuestionView.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2017/03/09.
//  Copyright © 2017年 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class ConfigQuestionView: UIViewController, GADBannerViewDelegate, CategoryDelegate { //テストの情報を編集する画面

    var admobView: GADBannerView!

    @IBOutlet private weak var buttonCategory: ButtonCustom!

    @IBOutlet private weak var colorChooserView: ColorChooserView!

    @IBOutlet private weak var fieldTitle: UITextField!

    var testId: String = ""

    var test: Test!

    override func viewDidLoad() {
        super.viewDidLoad()

        initAd()

        test = Model.sharedInstance.getTest(id: testId)
        fieldTitle.text = test.title

        if test.color >= 0 && test.color < COLORMAX {
            colorChooserView.setChecked(tag: test.color)
        } else {
            colorChooserView.setChecked(tag: 0)
        }

        if !test.category.isEmpty {
            buttonCategory.setTitle(test.category, for: UIControlState.normal)
            buttonCategory.contentHorizontalAlignment = .center
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver( self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        KeyboardOverlay.currentTop = 0
        KeyboardOverlay.newTop = 0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func keyboardWillChange(notification: NSNotification) {
        let keyboardHeight = self.view.frame.height - (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue.minY
        KeyboardOverlay.newTop = keyboardHeight

        if let ad = admobView {
            ad.frame.origin.y += (KeyboardOverlay.currentTop - KeyboardOverlay.newTop)
        }

        KeyboardOverlay.currentTop = keyboardHeight
    }

    class KeyboardOverlay {
        static var newTop: CGFloat = 0
        static var currentTop: CGFloat = 0
    }

    @IBAction private func actionSave(_ sender: Any) {

        if fieldTitle.isEmpty {

            showToastWithConfirm(message: NSLocalizedString("msg_null_title", comment: ""))

        } else {

            Model.sharedInstance.upTest(test: test, title: fieldTitle.text ?? "", color: colorChooserView.getCheckedTag(), category: buttonCategory.titleLabel?.text ?? "")

            self.fieldTitle.resignFirstResponder()

            showToast(message: NSLocalizedString("msg_saved", comment: ""))

        }

    }

    @IBAction private func actionCategory(_ sender: Any) {

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)

        if let popupView: CategoryViewController = storyBoard.instantiateViewController(withIdentifier: "CategoryView") as?
            CategoryViewController {
            popupView.modalPresentationStyle = .overFullScreen
            popupView.modalTransitionStyle = .coverVertical
            popupView.delegate = self
            popupView.selectedCategory = buttonCategory.titleLabel?.text ?? ""

            self.present(popupView, animated: true, completion: nil)

        }

    }

    func initAd() {

        let ud = UserDefaults.standard
        if ud.bool(forKey: "RemoveAd") {

            return
        }

        showAd()

    }

    func reloadTable() {}

    func setCategory(category: Category) {

        buttonCategory.setTitle(category.category, for: UIControlState.normal)

        buttonCategory.contentHorizontalAlignment = .center
        buttonCategory.backgroundColor = UIColor(
            hue: CGFloat(category.color) / CGFloat(COLORMAX),
            saturation: 0.5,
            brightness: 0.9,
            alpha: 1.0)

    }
    
    @IBAction func resetAchievement(_ sender: Any) {
        
        Model.sharedInstance.resetAchievement(test: test)
        
        showToast(message: NSLocalizedString("reset_achievement", comment: ""))
        
    }
    
}
