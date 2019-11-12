//
//  String.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2018/12/11.
//  Copyright © 2018 YamadaKeita. All rights reserved.
//

import UIKit

extension String { //labelの高さを可変にするための拡張

    func getTextSize(font: UIFont, viewWidth: CGFloat, padding: CGFloat) -> CGSize {

        var size = CGSize.zero

        let s: CGSize = self.makeSize(width: viewWidth, font: font)

        size = CGSize(width: s.width, height: s.height + padding)

        return size
    }

    func makeSize(width: CGFloat, font: UIFont) -> CGSize {

        var size = CGSize.zero

        if self.responds(to: #selector(NSString.boundingRect(with:options:attributes:context:))) {

            let bounds = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)

            let attributes: Dictionary = [NSAttributedStringKey.font: font]

            let options = unsafeBitCast(NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.usesFontLeading.rawValue, to: NSStringDrawingOptions.self)

            let rect: CGRect = self.boundingRect(with: bounds, options: options, attributes: attributes, context: nil)

            size = CGSize(width: rect.size.width, height: rect.size.height)
        }
        return size
    }
}
