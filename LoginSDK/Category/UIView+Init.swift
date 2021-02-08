//
//  UIView+Init.swift
//  CharPI
//
//  Created by cy on 2019/11/15.
//  Copyright © 2019 青色石头. All rights reserved.
//

import UIKit

extension UIView {

    convenience init(backgroundColor: UIColor, radius: CGFloat = 0, frame: CGRect = .zero) {
        self.init()
        self.frame = frame
        self.backgroundColor = backgroundColor
        if radius > 0 {
            layer.cornerRadius = radius
        }
    }
}
