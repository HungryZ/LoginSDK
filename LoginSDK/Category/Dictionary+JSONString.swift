//
//  Dictionary+JSONString.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/6.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

extension Dictionary {
    
    func jsonString() -> String {
        let data = try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let jsonStr = String(data: data, encoding: .utf8)
        
        return jsonStr!
    }
    
    func decode<T>(to type: T.Type) -> T where T: Codable {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return try JSONDecoder().decode(type, from: data)
        } catch let error {
            print(error)
            fatalError()
        }
    }
}
