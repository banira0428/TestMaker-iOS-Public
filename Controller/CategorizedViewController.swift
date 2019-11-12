//
//  CategorizedViewController.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/11/11.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FirebaseUI
import Firebase

class CategorizedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, TestCellProtocol, FirebaseProtocol { //カテゴリ分けされたリストの表示画面

    // swiftlint:disable private_outlet
    @IBOutlet weak var tableCategorizedTest: UITableView!
    // swiftlint:enable private_outlet

    @IBOutlet private weak var tableBottomConstraint: NSLayoutConstraint!
    
    var selectedTest: Test? = nil

    var category: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        initAd()

        tableCategorizedTest.register(UINib(nibName: "TestCell", bundle: nil), forCellReuseIdentifier: "TestCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableCategorizedTest.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return Model.sharedInstance.getCategorizedList(category: category).count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell") as? TestCell {

            let test = Model.sharedInstance.getCategorizedList(category: category)[indexPath.row]

            cell.delegate = self
            cell.setValue(test: test)
            cell.setTag(tag: indexPath.row)
            return cell

        }

        return TestCell()
    }

    func actionPlay(tag: Int) {
        playTest(test: Model.sharedInstance.getCategorizedList(category: category)[tag])
    }

    func actionEdit(tag: Int) {
        editTest(test: Model.sharedInstance.getCategorizedList(category: category)[tag])
    }

    func actionDelete(tag: Int) {
        deleteTest(test: Model.sharedInstance.getCategorizedList(category: category)[tag])
    }

    func actionShare(tag: Int) {
        shareTest(test: Model.sharedInstance.getCategorizedList(category: category)[tag])
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

    func initAd() {

        let ud = UserDefaults.standard
        if ud.bool(forKey: "RemoveAd") {

            tableBottomConstraint.constant = 10

            return
        }
        showAd()

    }
}
