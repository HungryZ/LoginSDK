//
//  Macro.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/1.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

let ScreenWidth = UIScreen.main.bounds.width

let ScreenHeight = UIScreen.main.bounds.height

let StatusBarHeight = UIApplication.shared.statusBarFrame.height

let bottomSafeAreaHeight: CGFloat = StatusBarHeight > 20 ? 34 : 0

let tabBarHeight = bottomSafeAreaHeight + 49

func ScaleWidth(_ width: CGFloat) -> CGFloat {
    return width * ScreenWidth / 375.0
}

func topWindow() -> UIWindow {
    if let window = UIApplication.shared.keyWindow {
        return window
    }
    return UIApplication.shared.windows.first!
}

func rootVC() -> UIViewController? {
    topWindow().rootViewController
}

extension UIColor {
    /// 黑色
    static let _333333 = UIColor("#333333")
    
    static let _666666 = UIColor("#666666")
    /// 灰色
    static let _999999 = UIColor("#999999")
}
