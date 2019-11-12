//
//  TextRowExtention.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/02/14.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import Foundation
import Eureka

extension TextRow {

    var isEmpty: Bool {

        return (self.value ?? "").isEmpty

    }

    func render(showFlg: Bool) {

        if showFlg {
            show()
        } else {
            hide()
        }

    }

    func hide() {

        self.hidden = true
        self.evaluateHidden()
        self.reload()

    }

    func show() {

        self.hidden = false
        self.evaluateHidden()

    }

}
