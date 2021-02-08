//
//  ViewController.swift
//  LoginSDKDemo
//
//  Created by 张海川 on 2021/2/8.
//

import UIKit
import LoginSDK

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        LoginManager.shared.setDelegate(self)
        view.backgroundColor = .purple
        
        LoginManager.shared.checkStatus()
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        view.addSubview(button)
        button.setTitle("BUTTON", for: .normal)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    @objc func buttonClicked() {
        LoginManager.shared.checkStatus()
    }
}

extension ViewController: LoginSDKDelegate {
    
    func userLoginSucceed() {
        print("userLoginSucceed-\(LoginManager.shared.token)")
    }
    
    func userLogout() {
        print("userLogout-\(LoginManager.shared.token)")
    }
}

