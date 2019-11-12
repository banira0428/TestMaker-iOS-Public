//
//  TestProtocol.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/11/11.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import FirebaseUI

protocol TestProtocol: FUIAuthDelegate {
    
    func playTest(test: Test)
    func editTest(test: Test)
    func deleteTest(test: Test)
    func shareTest(test: Test)
    func reload()
    func upload(test: Test)
    
}

extension TestProtocol where Self: UIViewController { //テスト操作に関する処理の共通化
    
    func playTest(test: Test) {
        if test.questions.isEmpty {
            showToastWithConfirm(message: NSLocalizedString("msg_null_questions", comment: ""))
            return
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let popupView: PlayConfigViewController = storyBoard.instantiateViewController(withIdentifier: "PlayConfigView") as? PlayConfigViewController {
            
            popupView.modalPresentationStyle = .overFullScreen
            popupView.modalTransitionStyle = .coverVertical
            
            popupView.testName = test.title
            popupView.onClickStartListener = {
                
                let ud = UserDefaults.standard
                if test.isAllCorrect() && ud.bool(forKey: "WrongOnly") { //全問正解時
                    self.showToastWithConfirm(message: NSLocalizedString("msg_null_wrong", comment: ""))
                    return
                }
                
                if let targetViewController = self.storyboard?.instantiateViewController( withIdentifier: "playView" ) as? PlayViewController {
                    targetViewController.testId = test.id
                    self.navigationController?.pushViewController( targetViewController, animated: true)
                }
            }
            self.present(popupView, animated: true, completion: nil)
        }
        return
    }
    
    func editTest(test: Test) {
        
        if let targetViewController = self.storyboard?.instantiateViewController( withIdentifier: "editView" ) as? EditViewController {
            
            targetViewController.testId = test.id
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.navigationController?.pushViewController( targetViewController, animated: true)
                
            }
        }
    }
    
    func deleteTest(test: Test) {
        
        showAskPermitDialog(message: String(format: NSLocalizedString("msg_delete_test", comment: ""), test.title), handler: {(_: UIAlertAction!) -> Void in
            
            Model.sharedInstance.deleteTest(test: test)
            
            self.reload()
            
        })
    }
    
    func shareTest(test: Test) {
        
        let dialog = UIAlertController(title: "", message: NSLocalizedString("title_dialog_share", comment: ""), preferredStyle: .actionSheet)
        
        dialog.addAction(UIAlertAction(title: NSLocalizedString("action_share_upload", comment: ""), style: .default, handler: {(_: UIAlertAction!) -> Void in
            
            if Auth.auth().currentUser != nil {
                self.upload(test: test)
            }else{
                
                if self is MainViewController {
                    (self as! MainViewController).selectedTest = test
                }else if self is CategorizedViewController {
                    (self as! CategorizedViewController).selectedTest = test
                }
                
                self.showAskPermitDialog(message: String(format: NSLocalizedString("msg_not_login", comment: "")), handler: {(_: UIAlertAction!) -> Void in
                    
                    let authUI = FUIAuth.defaultAuthUI()
                    authUI?.delegate = self
                    authUI?.tosurl = URL(string: "https://testmaker-1cb29.firebaseapp.com/terms")!
                    authUI?.privacyPolicyURL = URL(string: "https://testmaker-1cb29.firebaseapp.com/privacy")!

                    
                    let providers: [FUIAuthProvider] = [
                        FUIEmailAuth(),
                        FUIGoogleAuth()
                    ]
                    
                    authUI?.providers = providers
                    
                    if let authViewController = authUI?.authViewController() {
                        self.present(authViewController, animated: true, completion: {
                            
                            self.shareTest(test: test)
                            
                        })
                    }
                    
                })
            }
        }))
        
        dialog.addAction(UIAlertAction(title: NSLocalizedString("action_share_csv", comment: ""), style: .default, handler: {(_: UIAlertAction!) -> Void in
            
            var backup = ""
            
            for i in 0..<test.questions.count {
                
                let q = test.questions[i]
                
                let problem = q.problem.replacingOccurrences(of: ",", with: "<comma>")
                let answer = q.answer.replacingOccurrences(of: ",", with: "<comma>")
                let explanation = q.explanation.replacingOccurrences(of: ",", with: "<comma>")
                
                var answers: [String] = [String]()
                var others: [String] = [String]()
                
                q.answers.forEach { answers.append($0.str.replacingOccurrences(of: ",", with: "<comma>")) }
                q.others.forEach { others.append($0.str.replacingOccurrences(of: ",", with: "<comma>")) }
                
                var lineWrite = ""
                
                switch q.type {
                case WRITE:
                    
                    lineWrite.append(String(format: NSLocalizedString("share_short_question", comment: ""), problem, answer))
                    
                case SELECT:
                    if q.auto {
                        
                        lineWrite.append(String(format: NSLocalizedString("share_select_auto_question", comment: ""), problem, answer, String(others.count)))
                        
                    } else {
                        
                        lineWrite.append(String(format: NSLocalizedString("share_select_question", comment: ""), problem, answer))
                        
                        others.forEach { lineWrite.append("\($0),") }
                        
                        lineWrite = String(lineWrite.prefix(lineWrite.count - 1))
                        
                    }
                    
                case COMPLETE:
                    
                    if q.isCheckOrder {
                        
                        lineWrite.append(String(format: NSLocalizedString("share_complete_order_question", comment: ""), problem))
                        
                    } else {
                        lineWrite.append(String(format: NSLocalizedString("share_complete_question", comment: ""), problem))
                    }
                    
                    answers.forEach { lineWrite.append("\($0),") }
                    
                    lineWrite = String(lineWrite.prefix(lineWrite.count - 1))
                    
                case SELECTCOMPLETE:
                    
                    if q.auto {
                        
                        lineWrite.append(String(format: NSLocalizedString("share_select_complete_auto_question", comment: ""), problem))
                        
                        lineWrite.append("\(others.count),")
                        
                        answers.forEach { lineWrite.append("\($0),") }
                        
                        lineWrite = String(lineWrite.prefix(lineWrite.count - 1))
                        
                    } else {
                        
                        lineWrite.append(String(format: NSLocalizedString("share_select_complete_question", comment: ""), problem))
                        
                        lineWrite.append("\(answers.count),")
                        
                        lineWrite.append("\(others.count),")
                        
                        answers.forEach { lineWrite.append("\($0),") }
                        
                        others.forEach { lineWrite.append("\($0),") }
                        
                        lineWrite = String(lineWrite.prefix(lineWrite.count - 1))
                        
                    }
                    
                default:
                    
                    break
                    
                }
                
                if lineWrite.contains("\n") {
                    lineWrite = lineWrite.replacingOccurrences(of: "\n", with: "<br>")
                }
                
                backup.append(lineWrite)
                
                if !explanation.isEmpty {
                    
                    backup.append(String(format: NSLocalizedString("share_explanation", comment: ""), explanation))
                }
                
                backup.append("\n")
                
            }
            
            backup.append(String(format: NSLocalizedString("share_title", comment: ""), test.title))
            
            backup.append(String(format: NSLocalizedString("share_color", comment: ""), test.color))
            
            let activityItems = [backup]
            
            // 初期化処理
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            
            self.present(self.createDialogForIPad(dialog: activityVC), animated: true, completion: nil)
            
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(createDialogForIPad(dialog: dialog), animated: true, completion: nil)
        
    }
    
    func shareTestByUrl(url: String,test: Test){
        
        guard let link = URL(string: "https://testmaker-1cb29.com/\(url)") else { return }
        let dynamicLinksDomainURIPrefix = "https://testmaker.page.link"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "jp.gr.java-conf.foobar.testmaker.service")
        linkBuilder?.iOSParameters?.appStoreID = "1201200202"
        linkBuilder?.iOSParameters?.minimumAppVersion = "2.1.5"
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "jp.gr.java_conf.foobar.testmaker.service")
        linkBuilder?.androidParameters?.minimumVersion = 87

        
        guard let longDynamicLink = linkBuilder?.url else { return }
        
        let activityItems = [String(format: NSLocalizedString("msg_share_test", comment: ""),test.title, longDynamicLink.absoluteString)]
        
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = self.view //iPadでのクラッシュ回避のため
        
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2, y: screenSize.size.height, width: 0, height: 0)
        
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension MainViewController: TestProtocol {
    func upload(test: Test){
        uploadTestToFireStore(test: test)
    }
    
    func reload() {
        tableExam.reloadData()
    }
}
extension CategorizedViewController: TestProtocol {
    func upload(test: Test){
        uploadTestToFireStore(test: test)
    }
    
    func reload() {
        tableCategorizedTest.reloadData()
    }
}
