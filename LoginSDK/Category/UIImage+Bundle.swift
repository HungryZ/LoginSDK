//
//  UIImage+Bundle.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

extension UIImage {

    convenience init?(fromBundle imageName: String) {
        self.init(named: "LoginSDK.bundle/\(imageName).png", in: Bundle(for: LoginManager.self), compatibleWith: nil)
    }
}
