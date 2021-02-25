//
//  GMWebView.swift
//  LoginSDK
//
//  Created by 张海川 on 2021/2/24.
//

import UIKit
import WebKit

class GMWebView: GMBaseView {
    
    init(urlString: String) {
        super.init(frame: .zero)
        
        snp.updateConstraints { (make) in
            make.width.equalTo(ScreenWidth - ScaleWidth(30))
        }
        
        let webView = WKWebView()
        contentView.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(ScreenHeight - StatusBarHeight - tabBarHeight - 34)
        }
        
        webView.load(URLRequest(url: URL(string: urlString)!))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
