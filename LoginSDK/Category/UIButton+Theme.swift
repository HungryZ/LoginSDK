//
//  UIButton+Theme.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UIButton {
    
    static func themeButton(title: String, target: Any?, action: Selector) -> UIButton {
        let button = UIButton(title: title,
                              titleColor: ._333333,
                              font: 15,
                              cornerRadius: 17.5,
                              backgroundColor: .white,
                              target: target,
                              action: action)
    
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        button.layer.shadowOffset = .zero
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 15
        
        return button
    }
}
