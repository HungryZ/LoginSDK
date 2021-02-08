//
//  Data+Encoding.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

extension Data {
    
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }

}
