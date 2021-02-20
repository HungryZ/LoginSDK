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
        
        let button = UIButton(frame: CGRect(x: 100, y: 300, width: 100, height: 100))
        button.setTitle("BUY", for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc
    func buttonClicked() {
        GMIAPManager.shared.startIAP(withProductId: "com.cqhaowan.gamezero.test1")
    }
    
}
