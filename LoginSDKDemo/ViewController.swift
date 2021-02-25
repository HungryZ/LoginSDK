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
        GMIAPManager.shared.startIAP(withProductId: "com.cqhaowan.gamezero.test1")
    }
    
    @objc
    func buttonClicked2() {
        GMIAPManager.shared.startIAP(withProductId: "com.cqhaowan.gamezero.test2")
    }
    
}
