//
//  MyPageViewController.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/06/13.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import GoogleMobileAds

class MyPageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate,MyTestCellProtocol,FirebaseProtocol {
    
    @IBOutlet weak var tableMyTests: UITableView!
    
    private var tests: [DocumentTest] = []
    
    private var testsListener: ListenerRegistration?
    
    private var questionsListener: ListenerRegistration?
    
    @IBOutlet weak var ScrollLimitConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileView: UIVisualEffectView!
    @IBOutlet weak var fieldUserName: UITextField!
    
    @IBOutlet weak var progressProfile: UIActivityIndicatorView!
    
    private var database: Firestore!
    
    let refreshCtl = UIRefreshControl()
    
    var admobView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableMyTests.delegate = self
        tableMyTests.dataSource = self
        tableMyTests.refreshControl = refreshCtl
        tableMyTests.register(UINib(nibName: "MyTestCell", bundle: nil), forCellReuseIdentifier: "MyTestCell")
        
        initAd()
        
        database = Firestore.firestore()
        refreshCtl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        profileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideProfile)))
        fetchData()
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableMyTests.dequeueReusableCell(withIdentifier: "MyTestCell") as? MyTestCell {
            
            cell.delegate = self
            
            cell.setValue(documentTest: tests[indexPath.row])
            
            cell.setTag(tag: indexPath.row)
            
            return cell
        }
        
        
        return MyTestCell()
    }
    
    @objc func fetchData() {
        
        refreshCtl.beginRefreshing()
        database.collection("tests").whereField("userId", isEqualTo: Auth.auth().currentUser?.uid ?? "").limit(to: 50).getDocuments(completion: {(querySnapshot, err) in
            if let err = err {
                self.refreshCtl.endRefreshing()
                print("Error getting documents: \(err)")
            } else {
                
                self.tests = querySnapshot!.documents.map{documentTest -> DocumentTest in
                    
                    let data = documentTest.data()
                    let test = Test()
                    test.title = data["name"] as? String ?? ""
                    test.color = data["color"] as? Int ?? 0
                    return DocumentTest(test: test,documentId: documentTest.documentID,
                                        size: data["size"] as? Int ?? 0,
                                        creatorId: data["userId"] as? String ?? "",
                                        creatorName: data["userName"] as? String ?? "",
                                        date: (data["created_at"] as? Timestamp) ?? Timestamp(),
                                        overview: data["overview"] as? String ?? "")
                }
                
                self.refreshCtl.endRefreshing()
                self.tableMyTests.reloadData()
                
            }})
    }
    
    func actionDownload(tag: Int) {
        let documentTest = tests[tag]
        
            downloadTest(id: documentTest.documentId, endListener: {
                self.navigationController?.popToRootViewController(animated: true)
            })
    }
    
    func actionDelete(tag: Int) {
        
        let documentTest = tests[tag]
        
        showAskPermitDialog(message: String(format: NSLocalizedString("msg_delete_test", comment: ""), documentTest.test.title), handler: {(_: UIAlertAction!) -> Void in
            
            Firestore.firestore().collection("tests").document(documentTest.documentId).delete() { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            self.fetchData()
        })
    }
    
    @IBAction func actionLogout(_ sender: Any) {
        showAskPermitDialog(message: String(format: NSLocalizedString("msg_confirm_logout", comment: "")), handler: {(_: UIAlertAction!) -> Void in
            
            let authUI = FUIAuth.defaultAuthUI()
            
            do {
                try? authUI?.signOut()
                self.navigationController?.popViewController(animated: true)
            } catch {
                print("sign out error")
            }
            
        })
    }
    
    func initAd() {
        
        let ud = UserDefaults.standard
        if ud.bool(forKey: "RemoveAd") {
            
            ScrollLimitConstraint.constant = 10
            
            return
        }
        
        showAd()

    }
    
    @objc func hideProfile(){
        UIView.transition(with: profileView,duration: 0.3,  options: .curveEaseOut, animations: {
            self.profileView.alpha = 0
        },completion: nil)
    }
    
    @IBAction func actionProfile(_ sender: Any) {
        
        if profileView.alpha == 0 {
            UIView.transition(with: profileView,duration: 0.3,  options: .transitionCrossDissolve, animations: {
                self.profileView.alpha = 1
            },completion: nil)
            fieldUserName.text = Auth.auth().currentUser?.displayName
        }else{
            hideProfile()
        }
        
    }
    
    @IBAction func actionSave(_ sender: Any) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = fieldUserName.text
        progressProfile.startAnimating()
        changeRequest?.commitChanges { (error) in
            // ...
            self.progressProfile.stopAnimating()
        }
        
        
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
