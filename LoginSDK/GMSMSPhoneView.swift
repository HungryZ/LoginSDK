//
//  GMSMSPhoneView.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/1.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class GMSMSPhoneView: GMBaseView {
    
    lazy var headerImgView: UIImageView = {
        let view = UIImageView(image: UIImage(fromBundle: "header_bg"))
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    lazy var phoneField: ZHCTextField = {
        let field = ZHCTextField()
        field.fieldType = .phoneNumber
        field.leftImage = UIImage(fromBundle: "phone")!
        let button = UIButton(imageName: "arrow_down", target: self, action: #selector(pullButtonClicked))
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 36)
        let rightView = UIView(frame: button.frame)
        rightView.addSubview(button)
        field.rightView = rightView
        field.rightViewMode = .always
        field.placeholder = "请输入您的手机号"
        field.placeholderFont = .systemFont(ofSize: 12)
        field.placeholderColor = ._999999
        #if DEBUG
        field.text = "128 8880 3905"
        #endif
        
        return field
    }()
    
    lazy var loginButton = UIButton.themeButton(title: "短信登录", target: self, action: #selector(loginButtonClicked))
    
    lazy var psdLoginButton = UIButton(title: "账密登录",
                                       titleColor: ._666666,
                                       font: 12,
                                       target: self,
                                       action: #selector(psdLoginButtonClicked))
    
    lazy var guestButton = UIButton(title: "游客登录",
                                    titleColor: ._666666,
                                    font: 12,
                                    target: self,
                                    action: #selector(guestButtonClicked))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        canGoBack = false
        phoneField.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func buildUI() {
        super.buildUI()
        
        let hintLabel = UILabel(font: 12, textColor: ._999999, text: "其他登录方式")
        let leftLine = UIView(backgroundColor: ._999999)
        let rightLine = UIView(backgroundColor: ._999999)
        
        contentView.addSubview(headerImgView)
        contentView.addSubview(phoneField)
        contentView.addSubview(loginButton)
        contentView.addSubview(hintLabel)
        contentView.addSubview(leftLine)
        contentView.addSubview(rightLine)
        contentView.addSubview(psdLoginButton)
        contentView.addSubview(guestButton)
        
        headerImgView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(ScaleWidth(150))
        }
        phoneField.snp.makeConstraints { (make) in
            make.top.equalTo(headerImgView.snp_bottom).offset(20)
            make.left.right.equalTo(0).inset(ScaleWidth(30))
            make.height.equalTo(ScaleWidth(36))
        }
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(phoneField.snp_bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(ScaleWidth(100))
            make.height.equalTo(35)
        }
        hintLabel.snp.makeConstraints { (make) in
            make.top.equalTo(loginButton.snp_bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        leftLine.snp.makeConstraints { (make) in
            make.centerY.equalTo(hintLabel)
            make.right.equalTo(hintLabel.snp_left).offset(-10)
            make.size.equalTo(CGSize(width: ScaleWidth(60), height: 0.5))
        }
        rightLine.snp.makeConstraints { (make) in
            make.centerY.equalTo(hintLabel)
            make.left.equalTo(hintLabel.snp_right).offset(10)
            make.size.equalTo(leftLine)
        }
        psdLoginButton.snp.makeConstraints { (make) in
            make.top.equalTo(hintLabel.snp_bottom).offset(10)
            make.left.equalTo(64)
            make.bottom.equalTo(-10)
        }
        guestButton.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(psdLoginButton)
            make.right.equalTo(-64)
        }
    }
    
    @objc func pullButtonClicked() {
        
    }
    
    @objc func loginButtonClicked() {
        phoneField.resignFirstResponder()
        if phoneField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入手机号")
        } else if !phoneField.phoneNumberString.isPhoneNumber() {
            SVProgressHUD.showError(withStatus: "请输入正确手机号")
        } else {
            delegate?.pushView(GMSMSCodeView(phone: phoneField.phoneNumberString))
        }
    }
    
    @objc func psdLoginButtonClicked() {
        delegate?.pushView(GMPsdLoginView())
    }
    
    @objc func guestButtonClicked() {
        GMNet.request(GMLogin.guestLogin) { (response) in
            LoginManager.shared.loginSucceed(token: response["token"] as! String)
        }
    }
}
