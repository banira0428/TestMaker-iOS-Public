//
//  FirebaseProtocol.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/10/20.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

protocol FirebaseProtocol {
    
    func downloadTest(id: String,endListener: @escaping () -> Void)
    func uploadTest(test: Test,data: [String: Any],endListener: @escaping (_ message: String) -> Void)
}

extension FirebaseProtocol where Self: UIViewController{
    
    func downloadTest(id: String,endListener: @escaping () -> Void){
        showIndicator(message: NSLocalizedString("downloading", comment: ""))
        
        let database = Firestore.firestore()
        
        database.collection("tests").document(id).getDocument(completion: {(document, err) in
            if let err = err {
                self.hideIndicator()
                self.showToast(message: NSLocalizedString("msg_test_not_exist", comment: ""))
                print("Error getting documents: \(err)")
            } else {
                
                if let document = document, document.exists {
                    
                    let test = Test()
                    test.title = document.data()?["name"] as? String ?? ""
                    test.color = document.data()?["color"] as? Int ?? 0
                    database.collection("tests").document(id).collection("questions").getDocuments(completion: {(querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                            self.hideIndicator()
                        } else {
                            
                            let questions = querySnapshot!.documents.map { documentQuestion -> Question in
                                
                                let data = documentQuestion.data()
                                let question = Question()
                                
                                (data["answers"] as? Array<String> ?? []).forEach{answer in
                                    let str = Str()
                                    str.str = answer
                                    question.answers.append(str)
                                }
                                
                                (data["others"] as? Array<String> ?? []).forEach{other in
                                    let str = Str()
                                    str.str = other
                                    question.others.append(str)
                                }
                                
                                question.problem = data["question"] as? String ?? ""
                                question.answer = data["answer"] as? String ?? ""
                                question.type = data["type"] as? Int ?? 0
                                question.explanation = data["explanation"] as? String ?? ""
                                question.imagePath = data["imageRef"] as? String ?? ""
                                question.auto = data["auto"] as? Bool ?? false
                                question.isCheckOrder = data["checkOrder"] as? Bool ?? false
                                
                                
                                return question
                                
                            }
                            
                            questions.forEach{ test.questions.append($0) }
                            Model.sharedInstance.addTest(test: test)
                            self.hideIndicator()
                            endListener()
                        }
                    })
                    
                } else {
                    self.hideIndicator()
                    self.showToast(message: NSLocalizedString("msg_test_not_exist", comment: ""))
                }
            }})
    }
    
    func uploadTest(test: Test,data: [String: Any],endListener: @escaping (_ message: String) -> Void) {
        showIndicator(message: NSLocalizedString("uploading", comment: ""))
        let db = Firestore.firestore()
        let ref = db.collection("tests").document()
        var imageRef = ""
        
        ref.setData(data){ err in
            
            if let err = err {
                self.showToast(message: String(format: NSLocalizedString("msg_network_error", comment: "")))
                self.hideIndicator()
                
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
                    self.hideIndicator()
                    endListener(ref.documentID)
                }
            }
        }
    }
}
