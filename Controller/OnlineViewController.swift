//
//  OnlineViewController.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/06/07.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import FirebaseUI
import GoogleMobileAds
import MessageUI
import FirebaseStorage

class OnlineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate,OnlineTestCellProtocol,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,FirebaseProtocol,FUIAuthDelegate,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var uploadForm: UIVisualEffectView!
    @IBOutlet weak var detailView: UIVisualEffectView!
    @IBOutlet weak var tableTests: UITableView!
    @IBOutlet weak var editTestOverview: UITextField!
    @IBOutlet weak var pickerTests: UIPickerView!
    @IBOutlet weak var editOverView: UITextField!
    @IBOutlet weak var ScrollLimitConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTest: UILabel!
    @IBOutlet weak var textCreator: UILabel!
    @IBOutlet weak var textDate: UILabel!
    @IBOutlet weak var textOverView: UILabel!
    
    private var tests: [DocumentTest] = []
    
    private var database: Firestore!
    
    let refreshCtl = UIRefreshControl()
    
    @IBOutlet weak var progressUpload: UIActivityIndicatorView!
    
    var admobView: GADBannerView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableTests.dequeueReusableCell(withIdentifier: "OnlineTestCell") as? OnlineTestCell {
            
            cell.delegate = self
            cell.setValue(documentTest: tests[indexPath.row])
            cell.setTag(tag: indexPath.row)
            return cell
        }
        
        return OnlineTestCell()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadForm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideForm)))
        detailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideDetail)))

        tableTests.delegate = self
        tableTests.dataSource = self
        
        tableTests.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(fetchData), for: .valueChanged)

        pickerTests.delegate = self
        pickerTests.dataSource = self
        
        editTestOverview.delegate = self
        
        tableTests.register(UINib(nibName: "OnlineTestCell", bundle: nil), forCellReuseIdentifier: "OnlineTestCell")
        
        database = Firestore.firestore()
        initAd()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    @IBAction func actionUpload(_ sender: Any) {
        
        if Auth.auth().currentUser != nil {
            
            UIView.transition(with: uploadForm,duration: 0.3,  options: .transitionCrossDissolve, animations: {
                self.uploadForm.alpha = 1
            },completion: nil)
            
        }else{
            
            showAskPermitDialog(message: String(format: NSLocalizedString("msg_not_login", comment: "")), handler: {(_: UIAlertAction!) -> Void in
                
                self.actionLogin()
                
            })
        }
    }
    
    @IBAction func actionCancelUpload(_ sender: Any) {
        hideForm()
    }
    
    @IBAction func actionConfirm(_ sender: ButtonCustom) {
        
        progressUpload.startAnimating()
        
        sender.isEnabled = false
        
        let test = Model.sharedInstance.getTests()[pickerTests.selectedRow(inComponent: 0)]
        let db = Firestore.firestore()
        let ref = db.collection("tests").document()
        var imageRef = ""
        
        ref.setData([
            "name": test.title,
            "color": test.color,
            "size": test.questions.count,
            "userId": Auth.auth().currentUser?.uid ?? "",
            "userName": Auth.auth().currentUser?.displayName ?? "",
            "overview": editTestOverview.text ?? "",
            "created_at": Timestamp(date: Date()),
            "locale": NSLocale.preferredLanguages.first?.prefix(2) ?? "ja"
        ]){ err in
            
            if let err = err {
                self.progressUpload.stopAnimating()
                self.hideForm()
                self.showToast(message: String(format: NSLocalizedString("msg_network_error", comment: "")))
            }else{
                let batch = db.batch()
                
                test.questions.forEach{
                    
                    let answers: Array<String> = $0.answers.map{answer -> String in answer.str}
                    let others: Array<String> = $0.others.map{other -> String in other.str}
                    
                    let questionRef = ref.collection("questions").document()
                    
                    if !$0.imagePath.isEmpty {
                        let storage = Storage.storage()
                        let storageRef = storage.reference(forURL: "gs://testmaker-1cb29.appspot.com")
                        imageRef = "\(Auth.auth().currentUser?.uid ?? "")\($0.imagePath.suffix(15))"
                        let ref = storageRef.child(imageRef)
                        guard let image = UIImage(named: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "") + $0.imagePath.suffix(15)) else {
                            return
                        }
                        
                        let imageData = UIImageJPEGRepresentation(image, 0.5)!
                        let meta = StorageMetadata()
                        meta.contentType = "image/jpeg"
                        ref.putData(imageData, metadata: meta) { metadata, error in
                        }
                    }
                    
                    batch.setData([
                        "question":$0.problem,
                        "answer":$0.answer,
                        "type":$0.type,
                        "answers":answers,
                        "others":others,
                        "explanation":$0.explanation,
                        "imageRef":imageRef,
                        "isAuto":$0.auto,
                        "checkOrder":$0.isCheckOrder
                        ], forDocument: questionRef)
                }
                
                batch.commit(){ err in
                    self.progressUpload.stopAnimating()
                    self.hideForm()
                    sender.isEnabled = true
                    self.fetchData()
                }
            }
        }
    }
    
    @objc func hideForm() {
        
        if self.progressUpload.isAnimating {
            return
        }
        
        UIView.transition(with: uploadForm,duration: 0.3,  options: .curveEaseOut, animations: {
            self.uploadForm.alpha = 0
        })
        self.view.endEditing(true)
    }
    
    @objc func hideDetail() {
        
        UIView.transition(with: detailView,duration: 0.3,  options: .curveEaseOut, animations: {
            self.detailView.alpha = 0
        })
    }
    
    @objc func fetchData() {
        
        refreshCtl.beginRefreshing()
        database.collection("tests").order(by: "created_at",descending: true).limit(to: 50).getDocuments(completion: {(querySnapshot, err) in
            if let err = err {
                self.refreshCtl.endRefreshing()
                self.showToast(message: String(format: NSLocalizedString("msg_network_error", comment: "")))
            } else {
                
                self.tests = querySnapshot!.documents.filter{$0.data()["locale"] as? String ?? "" == NSLocale.preferredLanguages.first?.prefix(2) ?? "ja" }.map{documentTest -> DocumentTest in
                    
                    let data = documentTest.data()
                    let test = Test()
                    test.title = data["name"] as? String ?? ""
                    test.color = data["color"] as? Int ?? 0
                    return DocumentTest(test: test,
                                        documentId: documentTest.documentID,
                                        size: data["size"] as? Int ?? 0,
                                        creatorId: data["userId"] as? String ?? "",
                                        creatorName: data["userName"] as? String ?? "",
                                        date: data["created_at"] as? Timestamp ?? Timestamp(),
                                        overview: data["overview"] as? String ?? "")
                    }
                
                self.tests.sort{ "\($0.date)".lowercased() > "\($1.date)".lowercased()}
                self.refreshCtl.endRefreshing()
                self.tableTests.reloadData()
                
            }})
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Model.sharedInstance.getTests().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        return Model.sharedInstance.getTests()[row].title
        
    }
    
    func actionDetail(tag: Int) {
        
        self.titleTest.text = String(format: NSLocalizedString("title_online", comment: ""),self.tests[tag].test.title)
        self.textCreator.text = String(format: NSLocalizedString("username_online", comment: ""),self.tests[tag].creatorName)
        self.textDate.text =  String(format: NSLocalizedString("date_online", comment: ""),"\(self.tests[tag].date.dateValue())".prefix(10) as CVarArg)
        self.textOverView.text =  String(format: NSLocalizedString("overview_online", comment: ""),self.tests[tag].overview)
        
        UIView.transition(with: uploadForm,duration: 0.3,  options: .transitionCrossDissolve, animations: {
            self.detailView.alpha = 1
            
        },completion: nil)
        
    }
    
    func actionDownload(tag: Int) {
        
        let documentTest = tests[tag]
    
        downloadTest(id: documentTest.documentId, endListener: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func actionUser(_ sender: Any) {
        
        if Auth.auth().currentUser != nil {
            
            if let targetViewController = self.storyboard?.instantiateViewController( withIdentifier: "MyPageViewController" ) as? MyPageViewController {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
                    self.navigationController?.pushViewController( targetViewController, animated: true)
                }
            }
            
        }else{
            
            showAskPermitDialog(message: String(format: NSLocalizedString("msg_not_login_mypage", comment: "")), handler: {(_: UIAlertAction!) -> Void in
                self.actionLogin()
                
            })
        }
    }
    
    func actionLogin(){
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        authUI?.tosurl = URL(string: "https://testmaker-1cb29.firebaseapp.com/terms")!
        authUI?.privacyPolicyURL = URL(string: "https://testmaker-1cb29.firebaseapp.com/privacy")!
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIEmailAuth()
        ]
        
        authUI?.providers = providers
        
        if let authViewController = authUI?.authViewController() {
            self.present(authViewController, animated: true, completion: nil)
        }
    }
    
    //　認証画面から離れたときに呼ばれる（キャンセルボタン押下含む）
    public func authUI(_ authUI: FUIAuth, didSignInWith u: User?, error: Error?){
        // 認証に成功した場合
        if error == nil {
            
            guard let user = u else{
                return
            }
            
            let db = Firestore.firestore()
            let ref = db.collection("users").document(user.uid)
            ref.setData(["id": user.uid,
                         "name": user.displayName])
            
        }
        // エラー時の処理をここに書く
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func initAd() {
        
        let ud = UserDefaults.standard
        if ud.bool(forKey: "RemoveAd") {
            
            ScrollLimitConstraint.constant = 10
            return
        }
        
        showAd()

    }
    @IBAction func actionReport(_ sender: Any) {
        let mailViewController = MFMailComposeViewController()
        let toRecipients = ["testmaker.contact@gmail.com"]
        
        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("問題集の報告")
        mailViewController.setToRecipients(toRecipients) //Toアドレスの表示
        mailViewController.setMessageBody("以下に報告する理由を記載してください", isHTML: false)
        
        present(mailViewController, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
