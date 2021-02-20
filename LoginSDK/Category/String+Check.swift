//
//  String+Check.swift
//  Pai_SwiftLibrary
//
//  Created by cy on 2019/10/30.
//

extension String {
    
    func checkWithRegexString(regex: String) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    func isPhoneNumber() -> Bool {
        checkWithRegexString(regex: "^1[2-9]\\d{9}$")
    }
    
    func isPassword() -> Bool {
        checkWithRegexString(regex: "^(?=.*\\d)(?=.*[A-Za-z]).{6,18}$")
    }
    
    func phoneFormat() -> String {
        if !self.isPhoneNumber() {
            return ""
        }
        
        let index2 = self.index(self.startIndex, offsetBy: 3)
        let index6 = self.index(self.startIndex, offsetBy: 7)
        
        let str1 = String(self.prefix(upTo: index2))
        let str2 = String(self[index2 ..< index6])
        let str3 = String(self.suffix(from: index6))
        
        return str1 + " " + str2 + " " + str3
    }
    
    func securityPhoneStr() -> String {
        if !self.isPhoneNumber() {
            return ""
        }
        
        let index2 = self.index(self.startIndex, offsetBy: 3)
        let index6 = self.index(self.startIndex, offsetBy: 7)
        
        let str1 = String(self.prefix(upTo: index2))
        let str3 = String(self.suffix(from: index6))
        
        return str1 + "****" + str3
    }
    
    func securityIDStr() -> String {
        if self.count != 18 {
            return ""
        }
        
        let index2 = self.index(self.startIndex, offsetBy: 4)
        let index6 = self.index(self.startIndex, offsetBy: 14)
        
        let str1 = String(self.prefix(upTo: index2))
        let str3 = String(self.suffix(from: index6))
        
        return str1 + "****" + str3
    }
    
    /// 获取字符串字符数字
    func charactersCount() -> UInt {
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let da = self.data(using: String.Encoding.init(rawValue: enc))
        
        return UInt(da?.count ?? 0)
    }
}
