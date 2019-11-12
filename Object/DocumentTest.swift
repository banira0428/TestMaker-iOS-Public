//
//  DocumentTest.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/06/08.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import Foundation
import Firebase

class DocumentTest {
    
    var test: Test = Test()
    var documentId: String = ""
    var size: Int = 0
    var creatorId: String = ""
    var creatorName: String = ""
    var date: Timestamp = Timestamp()
    var overview: String = ""
    
    init(test: Test,documentId: String,size: Int,creatorId: String,creatorName: String,date: Timestamp,overview: String) {
        self.test = test
        self.documentId = documentId
        self.size = size
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.date = date
        self.overview = overview
    }
}
