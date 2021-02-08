//
//  UIButton+Init.swift
//  CharPI
//
//  Created by cy on 2019/11/15.
//  Copyright © 2019 青色石头. All rights reserved.
//

import UIKit

extension UIButton {
    
//    convenience init(themeTitle: String, target: Any?, action: Selector) {
//        
//        self.init(type: .custom)
//
//        let themeImage = UIImage.image(colors: [.c_EE9D07, kColorPinkF91E85])
//        
//        setTitle(themeTitle, for: .normal)
//        setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .normal)
//        setTitleColor(UIColor.white, for: .selected)
////        setTitleColor(UIColor.white, for: [.selected, .highlighted])
//        
//        titleLabel?.font = .boldSystemFont(ofSize: 18)
//        
//        layer.cornerRadius = 2
//        clipsToBounds = true
//        
//        setBackgroundImage(UIImage.image(color: .c_878D9B), for: .normal)
//        
//        setBackgroundImage(themeImage, for: [.selected, .highlighted])
//
//        setBackgroundImage(themeImage, for: .selected)
//        adjustsImageWhenHighlighted = false
//        adjustsImageWhenDisabled = false
//        
//        addTarget(target, action: action, for: .touchUpInside)
//    }
    
    convenience init(title: String? = nil,
                     titleColor: UIColor? = nil,
                     font: Any? = nil,
                     cornerRadius: CGFloat? = nil,
                     backgroundColor: UIColor? = nil,
                     target: Any? = nil,
                     action: Selector? = nil) {
        
        self.init(type: .custom)
        
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        
        if font is Int {
            titleLabel?.font = .systemFont(ofSize: CGFloat(font as! Int))
        } else if font is Double {
            titleLabel?.font = .systemFont(ofSize: CGFloat(font as! Double))
        } else if font is CGFloat {
            titleLabel?.font = .systemFont(ofSize: font as! CGFloat)
        } else if font is UIFont {
            titleLabel?.font = font as? UIFont
        }
        
        if let radius = cornerRadius, radius > 0 {
            layer.cornerRadius = radius
        }
        self.backgroundColor = backgroundColor
        
        if target != nil && action != nil {
            addTarget(target, action: action!, for: .touchUpInside)
        }
    }
    
    convenience init(imageName: String, target: Any?, action: Selector) {
        
        self.init(type: .custom)
        
        setImage(UIImage(fromBundle: imageName), for: .normal)
        addTarget(target, action: action, for: .touchUpInside)
    }
    
//    open override var isHighlighted: Bool {
//        didSet {
//            
//        }
//    }
}
