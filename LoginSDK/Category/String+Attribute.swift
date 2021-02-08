//
//  String+Attribute.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension String {
    
    func setLineSpacing(_ lineSpacing: CGFloat) -> NSMutableAttributedString {
        addAttributes(dictionary: ["lineSpacing": lineSpacing])
    }
    
    func addAttributeColor(color: UIColor, range: NSRange) -> NSMutableAttributedString {
        addAttributes(dictionary: ["color": color,
                                   "colorRange": range])
    }
    
    func addAttributeFontSize(fontSize: CGFloat, range: NSRange) -> NSMutableAttributedString {
        addAttributes(dictionary: ["fontSize": fontSize,
                                   "fontSizeRange": range])
    }
    
    /// 传入数字时需要用 CGFloat(x) 明确类型
    func addAttributes(dictionary: [String : Any]) -> NSMutableAttributedString {
        
        let attri = NSMutableAttributedString(string: self)
        
        if let color = dictionary["color"], let colorRange = dictionary["colorRange"] as? NSRange {
            attri.addAttribute(.foregroundColor, value: color, range: colorRange)
        }
        
        if let fontSize = dictionary["fontSize"] as? CGFloat, let fontRange = dictionary["fontSizeRange"] as? NSRange {
            let font = UIFont.systemFont(ofSize: fontSize)
            attri.addAttribute(.font, value: font, range: fontRange)
        }
        
        if let spacing = dictionary["lineSpacing"] as? CGFloat {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = spacing
            attri.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: self.count))
        }
        
        return attri
    }
    
    func width(withFont font: UIFont) -> CGFloat {
        self.size(withAttributes: [.font: font]).width
    }
    
    
    enum GM_CalculatesSizeType {
        case width
        case height
    }
    
    func calculates(type: GM_CalculatesSizeType, maxValue: CGFloat, font: UIFont) -> CGFloat {
        let nStr = self as NSString
        var size: CGSize
        switch type {
        case .width:
            size = CGSize(width: CGFloat(MAXFLOAT), height: maxValue)
            return nStr.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).width
        case .height:
            size = CGSize(width: maxValue, height: CGFloat(MAXFLOAT))
            return nStr.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).height
        }
    }
    
    func attributedString(withLineHeight height: CGFloat, font: UIFont) -> NSAttributedString {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.minimumLineHeight = height
        paragraphStyle.maximumLineHeight = height
        let baselineOffset = (height - font.lineHeight) / 4
        let contentAttr = NSAttributedString(string: self, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle, NSAttributedString.Key.baselineOffset:baselineOffset, NSAttributedString.Key.font:font])
        return contentAttr
    }

}
