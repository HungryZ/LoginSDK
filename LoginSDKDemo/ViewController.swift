//
//  ViewController.swift
//  LoginSDKDemo
//
//  Created by 张海川 on 2021/2/8.
//

import UIKit
import LoginSDK

class ViewController: UIViewController, GMIAPManagerDelegate {
    
    let key_developerinfo = "key_developerinfo"
    
    let itemArray = [
        [
            "price" : 6,
            "item_id" : "1101"
        ],
        [
            "price" : 98,
            "item_id" : "1103"
        ],
        [
            "price" : 108,
            "item_id" : "1104"
        ],
        [
            "price" : 1298,
            "item_id" : "1102"]
        ,
    ]
    var selectedItem: [String : Any]!
    
    
    let developerinfoField = UITextField(frame: CGRect(x: 50, y: 200, width: 100, height: 44))
    let itemButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        GMIAPManager.shared.delegate = self
        selectedItem = itemArray.first
        
        if let developerinfo = UserDefaults.standard.string(forKey: key_developerinfo) {
            developerinfoField.text = developerinfo
        } else {
            developerinfoField.text = "49289182"
        }
        developerinfoField.borderStyle = .roundedRect
        
        itemButton.frame = CGRect(x: 50, y: 250, width: 100, height: 44)
        itemButton.setTitle("\(selectedItem["price"] as! Int)金币", for: .normal)
        itemButton.addTarget(self, action: #selector(itemButtonClicked), for: .touchUpInside)
        
        view.addSubview(developerinfoField)
        view.addSubview(itemButton)
        
        let button = UIButton(frame: CGRect(x: 50, y: 300, width: 100, height: 100))
        button.setTitle("BUY", for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc
    func buttonClicked() {
        developerinfoField.resignFirstResponder()
        UserDefaults.standard.setValue(developerinfoField.text, forKey: key_developerinfo)
        
        let param: [String : Any] = [
//            "coins"         : 6,
//            "item_id"       : "1101",
//            "item_price"    : 6,
//            "item_name"     : "60金币",
//            "developerinfo" : developerinfoField.text ?? "",
            "coins"         : selectedItem["price"] as! Int,
            "item_id"       : selectedItem["item_id"] as! String,
            "item_price"    : selectedItem["price"] as! Int,
            "item_name"     : "\(selectedItem["price"] as! Int)金币",
            "developerinfo" : developerinfoField.text ?? "",

            "pay_version"   : "3.0",
            "serverid"      : "1",
            "roleid"        : "554",
            "gss_appid"     : "773",
            "uid"           : "11609707",
            "notify_url"    : "",
        ]
        SVProgressHUD.show()
        GMIAPManager.shared.startIAP(param)
    }
    
    @objc
    func itemButtonClicked() {
        let alert = UIAlertController(title: "内购项选择", message: nil, preferredStyle: .actionSheet)
        for item in itemArray {
            alert.addAction(UIAlertAction(title: "\(item["price"] as! Int)金币", style: .default, handler: { (_) in
                self.selectedItem = item
                self.itemButton.setTitle("\(self.selectedItem["price"] as! Int)金币", for: .normal)
            }))
        }
        present(alert, animated: true, completion: nil)
    }
    
    func iapManagerDidFinishTranscation(_ transcation: [String : Any]?, succeed: Bool) {
        succeed ? SVProgressHUD.showSuccess(withStatus: "购买成功") : SVProgressHUD.showError(withStatus: "购买失败")
    }
}
