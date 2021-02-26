//
//  ViewController.swift
//  LoginSDKDemo
//
//  Created by 张海川 on 2021/2/8.
//

import UIKit
import LoginSDK

class ViewController: UIViewController {
    
    let key_developerinfo = "key_developerinfo"
    
    let field = UITextField(frame: CGRect(x: 50, y: 250, width: 100, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        if let developerinfo = UserDefaults.standard.string(forKey: key_developerinfo) {
            field.text = developerinfo
        } else {
            field.text = "49289100"
        }
        field.borderStyle = .roundedRect
        view.addSubview(field)
        
        let button = UIButton(frame: CGRect(x: 50, y: 300, width: 100, height: 100))
        button.setTitle("BUY", for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc
    func buttonClicked() {
        field.resignFirstResponder()
        UserDefaults.standard.setValue(field.text, forKey: key_developerinfo)
        
        let param: [String : Any] = [
            "notify_url"    : "",
            "coins"         : 6,
            "item_id"       : "1101",
            "item_price"    : 6,
            "item_name"     : "60金币",
            "developerinfo" : field.text ?? "",
            "pay_version"   : "3.0",
            "serverid"      : "1",
            "roleid"        : "554",
            "gss_appid"     : "773",
            "uid"           : "11609707",
        ]
        SVProgressHUD.show()
        GMIAPManager.shared.startIAP(param) { (succeed) in
            SVProgressHUD.dismiss()
        }
    }
    
}
