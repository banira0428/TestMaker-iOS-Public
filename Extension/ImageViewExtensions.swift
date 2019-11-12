//
//  ImageViewExtention.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/02/14.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

extension UIImageView {
    
    func showImageIfExisting(path: String) {
        
        self.isHidden = false
        
        if path.isEmpty {
            self.isHidden = true
            return
        }
        
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "") + path.suffix(15)
        let checkValidation = FileManager.default
        
        if (checkValidation.fileExists(atPath: imagePath)){
            self.image = UIImage(named: imagePath)
        }else{
            self.image = UIImage(named: "loading")
            
            // Create a reference to the file you want to download
            let storage = Storage.storage()
            let storageRef = storage.reference(forURL: "gs://testmaker-1cb29.appspot.com")
            let starsRef = storageRef.child(path)
            
            // Fetch the download URL
            starsRef.downloadURL { url, error in
                if error != nil {
                    self.image = UIImage(named: "no_image")
                } else {
                    // Get the download URL for 'images/stars.jpg'
                    self.af_setImage(withURL: url ?? URL(fileURLWithPath: ""))
                }
            }
        }
    }
}
