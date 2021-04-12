//
//  ZHCNetworking.swift
//  LoginSDK
//
//  Created by work on 2021/4/12.
//

import Alamofire

public struct ZHCResponse {
    let data: Any
    let jsonData: [String : Any]?
}

public class ZHCNetworking {
    
    private(set) var baseUrl: String!
    
    private(set) var path: String!
    
    private(set) var method = HTTPMethod.post
    
    var parameters: [String: Any]?
    
    var headers: HTTPHeaders?
    
    var showLoading = true
    
    var HUD: UIView?
    
    var timeoutInterval: TimeInterval = 60
    
    // todo cache
}

/// chain syntax
public extension ZHCNetworking {
    
    func setParameters(_ params: [String: Any]?) -> ZHCNetworking {
        parameters = params
        return self
    }
    
    func setHUD(_ hud: UIView?) -> ZHCNetworking {
        HUD = hud
        return self
    }
    
    func request(succeed: @escaping (ZHCResponse) -> Void, fail: ((AFError) -> Void)? = nil) {
        AF.request(baseUrl + path, method: method, parameters: parameters, headers: headers, requestModifier: { (urlRequest) in
            urlRequest.timeoutInterval = self.timeoutInterval
            
        }).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let result):
                succeed(ZHCResponse(data: result, jsonData: result as? [String: Any]))
                
            case .failure(let error):
                if let failAction = fail {
                    failAction(error)
                }
            }
        })
    }
}
