//
//  GMVisitorLoginAPI.swift
//  LoginSDK
//
//  Created by work on 2021/4/12.
//

import Alamofire

class GMVisitorLoginAPI: ZHCNetworking {
    
    override var baseUrl: String! {
        "https://demo.gm88.com"
    }
    
    override var path: String! {
        "/api/v1/user/fastlogin"
    }
}
