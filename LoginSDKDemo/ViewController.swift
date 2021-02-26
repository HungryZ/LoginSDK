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
        view.backgroundColor = .white
        
        let button = UIButton(frame: CGRect(x: 50, y: 300, width: 100, height: 100))
        button.setTitle("BUY1", for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        view.addSubview(button)
        
        let button2 = UIButton(frame: CGRect(x: 200, y: 300, width: 100, height: 100))
        button2.setTitle("BUY2", for: .normal)
        button2.backgroundColor = .lightGray
        button2.addTarget(self, action: #selector(buttonClicked2), for: .touchUpInside)
        view.addSubview(button2)
    }
    
    @objc
    func buttonClicked() {
        let param: [String : Any] = [
            "notify_url"    : "",
            "coins"         : 6,
            "item_id"       : "1101",
            "item_price"    : 6,
            "item_name"     : "60金币",
            "developerinfo" : "49289091",
            "pay_version"   : "3.0",
            "serverid"      : "1",
            "roleid"        : "554",
            "gss_appid"     : "773",
            "uid"           : "11609707",
        ]
        GMIAPManager.shared.startIAP(param) { (succeed) in
            
        }
    }
    
    @objc
    func buttonClicked2() {
//        GMIAPManager.shared.startIAP(withProductId: "com.cqhaowan.gamezero.test2")
    }
    
}
