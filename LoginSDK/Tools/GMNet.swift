//
//  GMNet.swift
//  HungryTools_Example
//
//  Created by work on 2021/2/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Alamofire
import AdSupport

protocol GMRequestModel {
    
    var baseUrl: String { get }
    
    var path: String { get }
    
    var method: HTTPMethod { get }
    
    var reqParameter: [String: Any] { get }
    
    var showLoading: Bool { get }
}

extension GMRequestModel {
    
    var baseUrl: String {
        "https://demo.gm88.com"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var showLoading: Bool {
        true
    }
}

enum GMLogin: GMRequestModel {
    
    case activateDevice
    case getSMSCode(for: String, phone: String)
    case smsLogin(phone: String, code: String)
    case psdLogin(phone: String, psd: String)
    case guestLogin
    case resetPassword(phone: String, code: String, psd: String)
    case bindPhone(phone: String, code: String)
    case changePhone(newPhone: String, oldCode: String, newCode: String)
    case realNameCer(name: String, idNo: String)
    case userInfo
    case heartbeat(isFront: Bool)
    case feedback
    
    var path: String {
        switch self {
        case .activateDevice:
            return "/api/v1/system/active"
        case .getSMSCode:
            return "/api/v1/user/send_captcha"
        case .smsLogin:
            return "/api/v1/user/login_by_verifycode"
        case .psdLogin:
            return "/api/v1/user/login"
        case .guestLogin:
            return "/api/v1/user/fastlogin"
        case .resetPassword:
            return "/api/v1/user/forgetpass"
        case .bindPhone:
            return "/api/v1/user/bind"
        case .changePhone:
            return "/api/v1/user/change_bind"
        case .realNameCer:
            return "/api/v1/user/bindIdCardInfo"
        case .userInfo:
            return "/api/v1/user/info"
        case .heartbeat:
            return "/api/v1/system/heartbeat"
        case .feedback:
            return "/api/v1/game/customer_service"
        }
    }
    
    var reqParameter: [String : Any] {
        switch self {
        case .activateDevice:
            return ["ts": Int(NSDate().timeIntervalSince1970)]
        case .getSMSCode(for: let `for`, phone: let phone):
            return ["for": `for`, "phone_mob": phone]
        case .smsLogin(phone: let phone, code: let code):
            return ["phone_mob": phone, "verifycode": code]
        case .psdLogin(phone: let phone, psd: let psd):
            return ["phone_mob": phone, "password": psd]
        case .guestLogin:
            return [:]
        case .resetPassword(phone: let phone, code: let code, psd: let psd):
            return ["phone_mob": phone, "verifycode": code, "newpass": psd, "step": "2"]
        case .bindPhone(phone: let phone, code: let code):
            return ["phone_mob": phone, "verifycode": code]
        case .changePhone(newPhone: let newPhone, oldCode: let oldCode, newCode: let newCode):
            return ["phone_mob": newPhone, "old_verifycode": oldCode, "verifycode": newCode]
        case .realNameCer(name: let name, idNo: let idNo):
            return ["name": name, "idNo": idNo]
        case .userInfo:
            return [:]
        case .heartbeat(isFront: let isFront):
            return ["ts": Int(NSDate().timeIntervalSince1970), "is_front": isFront, "interval": 60]
        case .feedback:
            return [:]
        }
    }
}

class GMNet {
    
    static func request(_ request: GMRequestModel,
                        succeed: @escaping ([String : Any]) -> Void,
                        fail: ((String) -> Void)? = nil) {
        
        let urlString = request.baseUrl + request.path
        let method = request.method
        var fullParam = request.reqParameter
        fullParam.merge(publicParam()) { (old, new) -> Any in
            old
        }
        let headers = HTTPHeaders(["Authorization": authStr(withParam: fullParam)])
        
        #if DEBUG
        print("""

            ============================================================
            \(urlString)
            publicParam: \(publicParam().jsonString())
            paramater: \(request.reqParameter.jsonString())
            ============================================================

            """)
        #endif
        
        AF.request(urlString, method: method, parameters: fullParam, headers: headers, requestModifier: { (urlRequest) in
            urlRequest.timeoutInterval = 8
        }).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let result):
                guard let resultDic = result as? [String: Any] else {
                    // fail
                    if let failAction = fail {
                        failAction("未知错误")
                    }
                    return
                }
                #if DEBUG
                print("""

                    ============================================================
                    \(urlString)
                    result: \(resultDic.jsonString())
                    ============================================================

                    """)
                #endif

                if let statusCode = resultDic["status"] as? Int, statusCode == 1 {
                    // success
                    succeed(resultDic)
                } else {
                    if let errorCode = resultDic["errorno"] as? Int, errorCode == 2 {
                        LoginManager.shared.logout()
                    }
                    SVProgressHUD.showError(withStatus: resultDic["errortext"] as? String)
                    if let failAction = fail {
                        failAction(resultDic["errortext"] as? String ?? "未知错误")
                    }
                }

            case .failure(_):
                if let failAction = fail {
                    failAction("未知错误")
                }
            }
        })
    }
    
    static func publicParam() -> [String : Any] {
        [
            "idfa"    : ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "idfvnom" : UIDevice.current.identifierForVendor?.uuidString ?? "",
            "idfv"    : UIDevice.current.identifierForVendor?.uuidString ?? "",
            "game_id" : "773",
            "token"   : LoginManager.shared.isLogin ? LoginManager.shared.token! : "",
            "sdk_ver" : "wsy", // 固定值
        ]
    }
    
    static func authStr(withParam param: [String : Any]) -> String {
        
        let timestamp = "\(Int(Date().timeIntervalSince1970))"
        let randomStr = String.random(32)
        let originStr = timestamp + "\n" + randomStr + "\n" + sortParam(param) + "\n"
        let signStr = originStr.MD5String()
        let authStr = "GM-MD5 nonce_str=\"\(randomStr)\",timestamp=\"\(timestamp)\",signature=\"\(signStr)\""
        
        return authStr
    }
    
    static func sortParam(_ param: [String : Any]) -> String {
        var paramStr = ""
        _ = param.sorted { (arg0, arg1) -> Bool in
            arg0.key < arg1.key
        }.map {
            paramStr += "&\($0.key)=\($0.value)"
        }
        
        if paramStr.count > 0 {
            let index1 = paramStr.index(paramStr.startIndex, offsetBy: 1)
            paramStr = String(paramStr.suffix(from: index1))
        }
        
        return paramStr
    }
}
