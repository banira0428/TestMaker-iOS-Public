//
//  CategoryProtocol.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/10/28.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import Foundation

protocol CategoryDelegate {

    func setCategory(category: Category)

    func reloadTable()
}
