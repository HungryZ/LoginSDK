//
//  GMPsdLoginView.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Alamofire

class GMPsdLoginView: GMBaseView {
    
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
        field.placeholder = "请输入您的账号或手机号"
        field.placeholderFont = .systemFont(ofSize: 12)
        field.placeholderColor = ._999999
        #if DEBUG
        field.text = "128 8880 3905"
        #endif
        
        return field
    }()
    
    lazy var psdField: ZHCTextField = {
        let field = ZHCTextField()
        field.fieldType = .password
        field.leftImage = UIImage(fromBundle: "password")!
        field.secureButtonImages = [UIImage(fromBundle: "eye_1")!, UIImage(fromBundle: "eye_0")!]
        field.placeholder = "请输入您密码"
        field.placeholderFont = .systemFont(ofSize: 12)
        field.placeholderColor = ._999999
        
        return field
    }()
    
    lazy var loginButton = UIButton.themeButton(title: "登录", target: self, action: #selector(loginButtonClicked))
    
    lazy var forgotPsdButton = UIButton(title: "忘记密码", titleColor: ._999999, font: 11, target: self, action: #selector(forgotPsdButtonClicked))
    
    override func buildUI() {
        super.buildUI()
        
        backButton.setImage(UIImage(fromBundle: "back_white"), for: .normal)
        
        phoneField.becomeFirstResponder()
        
        contentView.addSubview(headerImgView)
        contentView.addSubview(phoneField)
        contentView.addSubview(psdField)
        contentView.addSubview(loginButton)
        contentView.addSubview(forgotPsdButton)
        
        headerImgView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(ScaleWidth(150))
        }
        phoneField.snp.makeConstraints { (make) in
            make.top.equalTo(headerImgView.snp.bottom).offset(20)
            make.left.right.equalTo(0).inset(ScaleWidth(30))
            make.height.equalTo(ScaleWidth(36))
        }
        psdField.snp.makeConstraints { (make) in
            make.top.equalTo(phoneField.snp.bottom).offset(20)
            make.left.right.height.equalTo(phoneField)
        }
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(psdField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(ScaleWidth(100))
            make.height.equalTo(35)
        }
        forgotPsdButton.snp.makeConstraints { (make) in
            make.top.equalTo(loginButton.snp.bottom).offset(5)
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(-5)
        }
    }
    
    @objc func pullButtonClicked(sender: UIButton) {
        if sender.isSelected {
            GMPhoneHistoryView.hideCurrentView()
        } else {
            GMPhoneHistoryView.show(withHostView: self.phoneField) { (phone) in
                self.phoneField.text = phone
            }
        }
        sender.isSelected = !sender.isSelected
    }
    
    @objc func loginButtonClicked() {
        phoneField.resignFirstResponder()
        psdField.resignFirstResponder()
        if phoneField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入手机号")
        } else if !phoneField.phoneNumberString.isPhoneNumber() {
            SVProgressHUD.showError(withStatus: "请输入正确手机号")
        } else if psdField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入密码")
        } else {
            GMNet.request(GMLogin.psdLogin(phone: phoneField.phoneNumberString, psd: psdField.text!)) { (response) in
                let user = response.decode(to: GMUserModel.self)
                LoginManager.shared.loginSucceed(token: user.token!)
                if let register = user.new_user, register {
                    Tracking.setRegisterWithAccountID(user.uid)
                }
                GMPhoneHistoryView.savePhone(self.phoneField.text!)
            }
        }
    }
    
    @objc func forgotPsdButtonClicked() {
        delegate?.pushView(GMForgotPsdView())
    }
}
