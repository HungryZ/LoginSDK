//
//  GMForgotPsdView.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class GMForgotPsdView: GMBaseView {
    
    lazy var phoneField: ZHCTextField = {
        let field = ZHCTextField()
        field.fieldType = .phoneNumber
        field.leftImage = UIImage(fromBundle: "phone")!
        field.placeholder = "请输入您的手机号"
        field.placeholderFont = .systemFont(ofSize: 12)
        field.placeholderColor = ._999999
        #if DEBUG
        field.text = "128 8880 3905"
        #endif
        
        return field
    }()
    
    lazy var codeField: ZHCTextField = {
        let field = ZHCTextField()
        field.fieldType = .number
        field.maxLength = 6
        field.leftImage = UIImage(fromBundle: "sms_code")!
        field.placeholder = "请输入验证码"
        field.placeholderFont = .systemFont(ofSize: 12)
        field.placeholderColor = ._999999
        
        let rightView = UIView(frame: getSMSButton.frame)
        rightView.addSubview(getSMSButton)
        field.rightView = rightView
        field.rightViewMode = .always
        
        return field
    }()
    
    lazy var getSMSButton: ZHCCountingButton = {
        let button = ZHCCountingButton(normalTitle: "获取验证码",
                                       countingTitle: "%d秒后重试",
                                       recoveredTitle: "重新发送",
                                       normalTitleColor: ._333333,
                                       countingTitleColor: ._999999,
                                       fontSize: 11,
                                       countingSeconds: 60,
                                       stamp: "sms_forgot")
        button.frame = CGRect(x: 0, y: 0, width: ScaleWidth(70), height: 20)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor._999999.cgColor
        button.addTarget(self, action: #selector(getSMSButtonClicked), for: .touchUpInside)
        
        return button
    }()
    
    lazy var psdField: ZHCTextField = {
        let field = ZHCTextField()
        field.fieldType = .password
        field.leftImage = UIImage(fromBundle: "password")!
        field.secureButtonImages = [UIImage(fromBundle: "eye_1")!, UIImage(fromBundle: "eye_0")!]
        field.placeholder = "请输入新密码"
        field.placeholderFont = .systemFont(ofSize: 12)
        field.placeholderColor = ._999999
        
        return field
    }()
    
    lazy var psdField2: ZHCTextField = {
        let field = ZHCTextField()
        field.fieldType = .password
        field.leftImage = UIImage(fromBundle: "password")!
        field.secureButtonImages = [UIImage(fromBundle: "eye_1")!, UIImage(fromBundle: "eye_0")!]
        field.placeholder = "请再次输入新密码"
        field.placeholderFont = .systemFont(ofSize: 12)
        field.placeholderColor = ._999999
        
        return field
    }()
    
    lazy var actionButton = UIButton.themeButton(title: "确定", target: self, action: #selector(actionButtonClicked))
    
    override func buildUI() {
        super.buildUI()
        
        title = "重置密码"
        phoneField.becomeFirstResponder()
        
        contentView.addSubview(phoneField)
        contentView.addSubview(codeField)
        contentView.addSubview(psdField)
        contentView.addSubview(psdField2)
        contentView.addSubview(actionButton)
        
        phoneField.snp.makeConstraints { (make) in
            make.top.equalTo(25)
            make.left.right.equalTo(0).inset(ScaleWidth(30))
            make.height.equalTo(ScaleWidth(36))
        }
        codeField.snp.makeConstraints { (make) in
            make.top.equalTo(phoneField.snp_bottom).offset(20)
            make.left.right.height.equalTo(phoneField)
        }
        psdField.snp.makeConstraints { (make) in
            make.top.equalTo(codeField.snp_bottom).offset(20)
            make.left.right.height.equalTo(phoneField)
        }
        psdField2.snp.makeConstraints { (make) in
            make.top.equalTo(psdField.snp_bottom).offset(20)
            make.left.right.height.equalTo(phoneField)
        }
        actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(psdField2.snp_bottom).offset(30)
            make.centerX.equalTo(contentView)
            make.width.equalTo(ScaleWidth(100))
            make.height.equalTo(35)
            make.bottom.equalTo(-15)
        }
    }
    
    @objc func getSMSButtonClicked() {
        phoneField.resignFirstResponder()
        codeField.resignFirstResponder()
        psdField.resignFirstResponder()
        psdField2.resignFirstResponder()
        
        if phoneField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入手机号")
        } else if !phoneField.phoneNumberString.isPhoneNumber() {
            SVProgressHUD.showError(withStatus: "请输入正确手机号")
        } else {
            GMNet.request(GMLogin.getSMSCode(for: "forgetpass", phone: phoneField.phoneNumberString)) { (response) in
                self.getSMSButton.startCounting()
                self.codeField.becomeFirstResponder()
            }
        }
    }
    
    @objc func actionButtonClicked() {
        phoneField.resignFirstResponder()
        codeField.resignFirstResponder()
        psdField.resignFirstResponder()
        psdField2.resignFirstResponder()
        
        if phoneField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入手机号")
        } else if !phoneField.phoneNumberString.isPhoneNumber() {
            SVProgressHUD.showError(withStatus: "请输入正确手机号")
        } else if codeField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入验证码")
        } else if codeField.text?.count ?? 0 < 4 {
            SVProgressHUD.showError(withStatus: "验证码长度不符")
        } else if psdField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入密码")
        } else if psdField2.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请再次输入密码")
        } else if psdField.text != psdField2.text {
            SVProgressHUD.showError(withStatus: "两次输入密码不符")
        } else {
            GMNet.request(GMLogin.resetPassword(phone: phoneField.phoneNumberString, code: codeField.text!, psd: psdField.text!)) { (response) in
                self.delegate?.popBack()
            }
        }
    }
}
