//
//  ViewController.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2016/12/25.
//  Copyright © 2016年 YamadaKeita. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds
import Accounts
import SnapKit
import StoreKit
import FirebaseUI
import Firebase

class MainViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, UITableViewDataSource, GADBannerViewDelegate, UIDocumentPickerDelegate, CategoryDelegate, TestCellProtocol, FirebaseProtocol, PurchaseManagerDelegate, FUIAuthDelegate {

    @IBOutlet private weak var buttonCategory: ButtonCustom!
    @IBOutlet private weak var buttonExpand: UIButton!
    @IBOutlet weak var tableExam: UITableView!
    @IBOutlet private weak var fieldTitle: UITextField!
    @IBOutlet private weak var buttonAdd: UIButton!
    @IBOutlet private weak var stackAdd: UIStackView!

    @IBOutlet private weak var menuConstraint: NSLayoutConstraint!

    @IBOutlet private weak var smallButtonConstraint: NSLayoutConstraint!
    @IBOutlet private weak var largeButtonConstraint: NSLayoutConstraint!

    @IBOutlet private weak var largeTableConstraint: NSLayoutConstraint!
    @IBOutlet private weak var smallTableConstraint: NSLayoutConstraint!

    @IBOutlet private weak var tableBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var colorChooserView: ColorChooserView!

    var admobView: GADBannerView!

    let productIdentifiers: [String] = ["removeAd"]
    
    var selectedTest: Test? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = Realm.Configuration(schemaVersion: 11)
        Realm.Configuration.defaultConfiguration = config

        let ud = UserDefaults.standard
        ud.register(defaults: ["BGM": true, "Self": false, "Reverse": false, "RemoveAd": false, "WrongOnly": false, "Random": true])

        initAd()

        buttonExpand.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 0, bottom: 0, right: 0)
        menuConstraint.constant = self.view.frame.width

        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = UIColor.clear
        tableExam.tableFooterView = v
        tableExam.tableHeaderView = v

        tableExam.register(UINib(nibName: "TestCell", bundle: nil), forCellReuseIdentifier: "TestCell")
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideSideMenu)))

        fieldTitle.delegate = self
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.viewController = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        tableExam.reloadData()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fieldTitle.resignFirstResponder()

        NotificationCenter.default.removeObserver( self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadFromUrl(_ url:URL){
        self.navigationController?.popToRootViewController(animated: true)
        downloadTest(id: String("\(url)".split(separator: "/").last ?? ""), endListener: {
            self.tableExam.reloadData()
        })
    }

    func initAd() {

        let ud = UserDefaults.standard
        if ud.bool(forKey: "RemoveAd") {

            tableBottomConstraint.constant = 10

            return
        }
        showAd()
    }

    //------------------------------------
    // MARK: - キーボード関連処理
    //------------------------------------

    @objc func keyboardWillChange(notification: NSNotification) {
        let keyboardHeight = self.view.frame.height - (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue.minY
        KeyboardOverlay.newTop = keyboardHeight

        if let ad = admobView {
            ad.frame.origin.y = admobView.frame.origin.y + (KeyboardOverlay.currentTop - KeyboardOverlay.newTop)
        }

        KeyboardOverlay.currentTop = keyboardHeight
    }

    class KeyboardOverlay {
        static var newTop: CGFloat = 0
        static var currentTop: CGFloat = 0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)

        return true
    }

    //------------------------------------
    // MARK: - 新規テスト登録関連処理
    //------------------------------------

    @IBAction private func actionExpand(_ sender: UIButton) {

        if stackAdd.isHidden {

            sender.setTitle(NSLocalizedString("close", comment: ""), for: .normal)

            NSLayoutConstraint.deactivate([smallButtonConstraint])
            NSLayoutConstraint.activate([largeButtonConstraint])
            NSLayoutConstraint.activate([largeTableConstraint])
            NSLayoutConstraint.deactivate([smallButtonConstraint])

            self.fieldTitle.becomeFirstResponder()

        } else {

            hiddenButtonExpand()

        }

        stackAdd.isHidden.toggle()

    }

    /// 新規登録用の部品を非表示にする処理
    func hiddenButtonExpand() {

        buttonExpand.setTitle(NSLocalizedString("add_test", comment: ""), for: .normal)

        NSLayoutConstraint.activate([smallButtonConstraint])
        NSLayoutConstraint.deactivate([largeButtonConstraint])
        NSLayoutConstraint.deactivate([largeTableConstraint])
        NSLayoutConstraint.activate([smallButtonConstraint])

        self.fieldTitle.resignFirstResponder()

    }

    @IBAction private func actionCategory(_ sender: Any) {

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)

        if let popupView: CategoryViewController = storyBoard.instantiateViewController(withIdentifier: "CategoryView") as? CategoryViewController {

            popupView.modalPresentationStyle = .overFullScreen
            popupView.modalTransitionStyle = .coverVertical
            popupView.delegate = self
            popupView.selectedCategory = buttonCategory.titleLabel?.text ?? ""

            self.present(popupView, animated: true, completion: nil)

        }
    }

    func setCategory(category: Category) {

        buttonCategory.setTitle(category.category, for: UIControlState.normal)

        buttonCategory.contentHorizontalAlignment = .center
        buttonCategory.backgroundColor = UIColor(
            hue: CGFloat(category.color) / CGFloat(COLORMAX),
            saturation: 0.5,
            brightness: 0.9,
            alpha: 1.0)

    }

    /// 「カテゴリ」ボタンを長押しした時にカテゴリを取り消す
    @IBAction private func cancelCategory(_ sender: UILongPressGestureRecognizer) {

        if sender.state == UIGestureRecognizerState.began {

            showAskPermitDialog(message: NSLocalizedString("msg_reset_category", comment: ""), handler: {(_: UIAlertAction!) -> Void in

                self.buttonCategory.setTitle(NSLocalizedString("category", comment: ""), for: UIControlState.normal)

                self.buttonCategory.backgroundColor = UIColor(
                    hue: 0.56,
                    saturation: 0.52,
                    brightness: 0.98,
                    alpha: 1.0)

                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {() -> Void in

                    self.buttonCategory.selectView.alpha = 0.0

                }, completion: {(_: Bool) -> Void in
                })
            })
        }
    }

    @IBAction private func actionAdd(_ sender: Any) {

        logEvent(title: "add test")

        if fieldTitle.isEmpty {

            showToastWithConfirm(message: NSLocalizedString("msg_null_title", comment: ""))

            return
        }

        let test = Test()
        test.title = fieldTitle.text ?? ""
        test.color = colorChooserView.getCheckedTag()
        test.category = buttonCategory.titleLabel?.text ?? ""

        Model.sharedInstance.addTest(test: test)

        fieldTitle.text = ""
        tableExam.reloadData()

        stackAdd.isHidden = true

        hiddenButtonExpand()

        showToast(message: NSLocalizedString("msg_saved", comment: ""))

    }

    //------------------------------------
    // MARK: - テーブル操作関連処理
    //------------------------------------

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    /// セルの個数を指定するデリゲートメソッド（必須）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.sharedInstance.getMixedListCount()
    }

    /// セルに値を設定するデータソースメソッド（必須）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let numCategory = Model.sharedInstance.getExistingCategories().count

        if indexPath.row < numCategory {

            if let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as? CategoryCell {

                cell.textCategory.text = Model.sharedInstance.getExistingCategories()[indexPath.row].category

                cell.textNumber.text = String(format: NSLocalizedString("num_questions", comment: ""), Model.sharedInstance.getCategorizedList(category: Model.sharedInstance.getExistingCategories()[indexPath.row].category).count)

                cell.colorView.backgroundColor = UIColor(
                    hue: CGFloat(Model.sharedInstance.getExistingCategories()[indexPath.row].color) / CGFloat(colorChooserView.colorViews.count),
                    saturation: 0.5,
                    brightness: 0.9,
                    alpha: 1.0)

                cell.setTag(tag: indexPath.row)

                return cell

            }

        } else {

            if let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell") as? TestCell {

                cell.delegate = self

                let test = Model.sharedInstance.getNonCategorizedList()[indexPath.row - numCategory]

                cell.setValue(test: test)

                cell.setTag(tag: indexPath.row - numCategory)

                return cell

            }

        }

        return TestCell()

    }

    func reloadTable() {
        tableExam.reloadData()
    }

    func actionPlay(tag: Int) {
        playTest(test: Model.sharedInstance.getNonCategorizedList()[tag])
    }

    func actionEdit(tag: Int) {
        editTest(test: Model.sharedInstance.getNonCategorizedList()[tag])
    }

    func actionDelete(tag: Int) {
        deleteTest(test: Model.sharedInstance.getNonCategorizedList()[tag])
    }

    func actionShare(tag: Int) {
        shareTest(test: Model.sharedInstance.getNonCategorizedList()[tag])
    }

    @IBAction private func actionOpen(_ sender: UIButton) {

        if let targetViewController = self.storyboard?.instantiateViewController( withIdentifier: "CategorizedView" ) as? CategorizedViewController {

            targetViewController.category = Model.sharedInstance.getExistingCategories()[sender.tag].category

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.navigationController?.pushViewController( targetViewController, animated: true)
            }
        }
    }
    
    //TOP画面
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if user != nil {
            if let test = selectedTest {
                let data = [
                            "name": test.title,
                            "color": test.color,
                            "size": test.questions.count,
                            "userId": Auth.auth().currentUser?.uid ?? "",
                            "userName": Auth.auth().currentUser?.displayName ?? "",
                            "overview": "",
                            "created_at": Timestamp(date: Date()),
                            "locale": NSLocale.preferredLanguages.first?.prefix(2) ?? "ja"
                            ] as [String : Any]
                
                self.uploadTest(test: test,data: data, endListener: {url in
                    
                    self.shareTestByUrl(url: url,test: test)
                    self.selectedTest = nil
                    
                })
            }
        }
    }
    
    func uploadTestToFireStore(test: Test){
        
        let data = [
        "name": test.title,
        "color": test.color,
        "size": test.questions.count,
        "userId": Auth.auth().currentUser?.uid ?? "",
        "userName": Auth.auth().currentUser?.displayName ?? "",
        "overview": "",
        "created_at": Timestamp(date: Date()),
        "locale": NSLocale.preferredLanguages.first?.prefix(2) ?? "ja"
        ] as [String : Any]
        
        uploadTest(test: test, data: data, endListener: {url in
            self.shareTestByUrl(url: url,test: test)
        })
    }

    //------------------------------------
    // MARK: - 左メニューの機能
    //------------------------------------

    ///スワイプによる左メニューの表示非表示の制御
    @IBAction private func panEdge(_ sender: UIScreenEdgePanGestureRecognizer) {

        //移動量を取得する。
        let move: CGPoint = sender.translation(in: view)

        //位置の制約に垂直方向の移動量を加算する。
        menuConstraint.constant -= move.x

        //画面表示を更新する。
        self.view.layoutIfNeeded()

        //ドラッグ終了時の処理
        if sender.state == UIGestureRecognizerState.ended {
            if menuConstraint.constant > view.frame.size.width * 0.8 {
                //ドラッグの距離が画面高さの半分に満たない場合はビュー画面外に戻す。
                menuConstraint.constant = view.frame.width

            } else {
                //ドラッグの距離が画面高さの半分以上の場合はそのままビューを下げる。
                menuConstraint.constant = 0

                self.fieldTitle.resignFirstResponder()

            }
            //アニメーションさせる。
            UIView.animate(withDuration: 0.2, animations: { self.view.layoutIfNeeded() }, completion: nil)
        }
        //移動量をリセットする。
        sender.setTranslation(.zero, in: view)
    }

    @IBAction private func actionMenu(_ sender: Any) {

        self.fieldTitle.resignFirstResponder()

        if menuConstraint.constant != 0 {
            menuConstraint.constant = 0
        } else {
            menuConstraint.constant = self.view.frame.width
        }

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()})
    }

    @IBAction private func hideMenu(_ sender: UISwipeGestureRecognizer) {
        hideSideMenu()
    }

    @objc func hideSideMenu() {

        menuConstraint.constant = self.view.frame.width

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    @IBAction func actionHelp(_ sender: Any) {
        hideSideMenu()

        guard let url = URL(string: "https://testmaker-1cb29.firebaseapp.com/help") else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
            // Fallback on earlier versions
        }
    }
    
    @IBAction private func actionReview(_ sender: Any) {

        hideSideMenu()

        guard let url = URL(string: "https://itunes.apple.com/app/id1201200202?action=write-review") else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
            // Fallback on earlier versions
        }
    }

    @IBAction private func actionFileImport(_ sender: Any) {

        hideSideMenu()

        let array = ["public.text"]
        let documentPicker = UIDocumentPickerViewController(documentTypes: array, in: UIDocumentPickerMode.open)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)

    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // 「ファイルURL」を「パス」に変換

        var test = Test()
        let realm = try! Realm()

        try! realm.write {

            CFURLStartAccessingSecurityScopedResource(url as CFURL)

            //csvBundleのパスを読み込み、UTF8に文字コード変換して、NSStringに格納
            let testData = try String(contentsOfFile: url.path,
                                      encoding: String.Encoding.utf8)

            CFURLStopAccessingSecurityScopedResource(url as CFURL)

            test = convert(testData: testData)

        }

        Model.sharedInstance.addTest(test: test)
        tableExam.reloadData()
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {

    }

    @IBAction private func actionpaste(_ sender: Any) {

        let message =  "\n\n\n\n\n\n\n\n"
        let alert = UIAlertController(title: NSLocalizedString("msg_load_by_paste", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)

        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 3
        textView.returnKeyType = .done

        let board = UIPasteboard.general
        if let value = board.value(forPasteboardType: "public.text") as? String {
            textView.text = value
        } else {
            textView.text = NSLocalizedString("msg_null_paste", comment: "")
        }
        textView.isEditable = false

        // textView を追加して Constraints を追加
        alert.view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(65)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-60)
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))

        alert.addAction(UIAlertAction(title: NSLocalizedString("load", comment: ""), style: UIAlertActionStyle.default, handler: {(_: UIAlertAction!) -> Void in

            //各textにアクセス
            let test = self.convert(testData: textView.text ?? "")

            Model.sharedInstance.addTest(test: test)
            self.tableExam.reloadData()

            self.hideSideMenu()

        }))

        self.present(alert, animated: true, completion: nil)

    }

    func convert(testData: String) -> Test {

        logEvent(title: "import")

        let test = TextToTestConverter.textToTest(text: testData)
        showToast(message: String(format: NSLocalizedString("msg_load_success", comment: ""), test.title))

        return test
    }

    @IBAction private func actionRemoveAd(_ sender: Any) {

        let ud = UserDefaults.standard

        if ud.bool(forKey: "RemoveAd") {
            showToast(message: NSLocalizedString("msg_removed", comment: ""))
            return
        }

        startPurchase(productIdentifier: productIdentifiers[0])

    }

    @IBAction private func actionRestore(_ sender: Any) {

        let ud = UserDefaults.standard

        if ud.bool(forKey: "RemoveAd") {
            showToast(message: NSLocalizedString("msg_removed", comment: ""))
            return
        }

        startRestore()

    }
    
    @IBAction private func actionOnline(_ sender: Any) {
        if let targetViewController = self.storyboard?.instantiateViewController( withIdentifier: "OnlineView" ) as? OnlineViewController {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                
                self.hideSideMenu()
                
                self.navigationController?.pushViewController( targetViewController, animated: true)
            }
        }
    }
    

    //------------------------------------
    // 課金処理開始
    //------------------------------------
    func startPurchase(productIdentifier: String) {
        print("課金処理開始!!")
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //プロダクト情報を取得
        ProductManager.productsWithProductIdentifiers(productIdentifiers: [productIdentifier], completion: { products, error -> Void in

            if products == nil {
                return
            }

            if (products?.count)! > 0 {
                //課金処理開始
                PurchaseManager.sharedManager().startWithProduct((products?[0])!)
            }
            if error != nil {
                print(error ?? "")
            }
        })
    }
    // リストア開始
    func startRestore() {
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //リストア開始
        PurchaseManager.sharedManager().startRestore()
    }

    //------------------------------------
    // MARK: - PurchaseManager Delegate
    //------------------------------------
    //課金終了時に呼び出される

    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------

        let ud = UserDefaults.standard
        ud.set(true, forKey: "RemoveAd")

        if let ad = admobView {
            ad.removeFromSuperview()
        }

        tableBottomConstraint.constant = 10

        //AppDelegate にも同様の内容を記載

        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {

        print("課金終了（指定プロダクトID以外）！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    //課金失敗時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFailWithError error: NSError!) {
        print("課金失敗！！")
    }
    // リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager!) {
        print("リストア終了！！")

        let ud = UserDefaults.standard
        //購入済みかどうか
        if !(ud.bool(forKey: "RemoveAd")) {

            showToast(message: "未購入です")

        }
    }
    // 承認待ち状態時に呼び出される(ファミリー共有)
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager!) {
        print("承認待ち！！")
    }
    // プロダクト情報取得
    fileprivate func fetchProductInformationForIds(_ productIds: [String]) {
        ProductManager.productsWithProductIdentifiers(productIdentifiers: productIds, completion: {[weak self] (products: [SKProduct]?, error: NSError?) -> Void in
            if error != nil {
                if self != nil {
                }
                print(error?.localizedDescription ?? "")
                return
            }
            for product in products! {
                let priceString = ProductManager.priceStringFromProduct(product: product)
                if self != nil {
                    print(product.localizedTitle + ":\(priceString)")

                }
                print(product.localizedTitle + ":\(priceString)" )
            }
        })
    }

}
