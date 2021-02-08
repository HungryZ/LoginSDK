//
//  String+Encoding.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CommonCrypto.CommonHMAC

extension String {
    
    func hash(name:String) -> Data {
        let algos = ["MD2":    (CC_MD2,    CC_MD2_DIGEST_LENGTH),
                     "MD4":    (CC_MD4,    CC_MD4_DIGEST_LENGTH),
                     "MD5":    (CC_MD5,    CC_MD5_DIGEST_LENGTH),
                     "SHA1":   (CC_SHA1,   CC_SHA1_DIGEST_LENGTH),
                     "SHA224": (CC_SHA224, CC_SHA224_DIGEST_LENGTH),
                     "SHA256": (CC_SHA256, CC_SHA256_DIGEST_LENGTH),
                     "SHA384": (CC_SHA384, CC_SHA384_DIGEST_LENGTH),
                     "SHA512": (CC_SHA512, CC_SHA512_DIGEST_LENGTH)]
        guard let (hashAlgorithm, length) = algos[name]  else { return Data() }
        var hashData = Data(count: Int(length))
        
        let data = self.data(using: .utf8)!
        _ = hashData.withUnsafeMutableBytes {digestBytes in
            data.withUnsafeBytes {messageBytes in
                hashAlgorithm(messageBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return hashData
    }
    
    static func sha256_2(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    
    func base64String() -> String {
        self.data(using: .utf8)!.base64EncodedString(options: .lineLength64Characters)
    }
    
    static func random(_ length: Int) -> String {
     
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
     
        var randomString = ""
     
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar,length: 1) as String
        }
     
        return randomString
    }
    
    func MD5String() -> String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
}
