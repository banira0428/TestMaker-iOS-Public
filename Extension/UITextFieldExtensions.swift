//
//  UITextFieldExtention.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2019/02/14.
//  Copyright © 2019 YamadaKeita. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {

    var isEmpty: Bool {

        return (self.text ?? "").isEmpty

    }

}
