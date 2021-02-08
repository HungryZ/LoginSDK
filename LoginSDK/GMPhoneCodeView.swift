//
//  GMPhoneCodeView.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class GMPhoneCodeView: GMBaseView {
    
    enum GMPhoneCodeViewType {
        case newBind
        case exchangeOld
        case exchangeNew(oldCode: String)
    }
    
    let type: GMPhoneCodeViewType
    
    init(type: GMPhoneCodeViewType) {
        self.type = type
        super.init(frame: .zero)
        
        config(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var phoneField: ZHCTextField = {
        let field = ZHCTextField()
        field.fieldType = .phoneNumber
        field.leftImage = UIImage(fromBundle: "phone")!
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
                                       stamp: nil)
        button.frame = CGRect(x: 0, y: 0, width: ScaleWidth(70), height: 20)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor._999999.cgColor
        button.addTarget(self, action: #selector(getSMSButtonClicked), for: .touchUpInside)
        
        return button
    }()
    
    lazy var actionButton = UIButton.themeButton(title: "确定", target: self, action: #selector(actionButtonClicked))
    
    override func buildUI() {
        super.buildUI()
        
        phoneField.becomeFirstResponder()
        
        contentView.addSubview(phoneField)
        contentView.addSubview(codeField)
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
        actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(codeField.snp_bottom).offset(30)
            make.centerX.equalTo(contentView)
            make.width.equalTo(ScaleWidth(100))
            make.height.equalTo(35)
            make.bottom.equalTo(-15)
        }
    }
    
    @objc func getSMSButtonClicked() {
        phoneField.resignFirstResponder()
        codeField.resignFirstResponder()
        if phoneField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入手机号")
        } else if !phoneField.phoneNumberString.isPhoneNumber() {
            SVProgressHUD.showError(withStatus: "请输入正确手机号")
        } else {
            let typeStr: String
            switch type {
            case .newBind, .exchangeNew:
                typeStr = "reg"
            case .exchangeOld:
                typeStr = "changeBind"
            }
            GMNet.request(GMLogin.getSMSCode(for: typeStr, phone: phoneField.phoneNumberString)) { (_) in
                self.getSMSButton.startCounting()
                self.codeField.becomeFirstResponder()
            }
        }
    }
    
    @objc func actionButtonClicked() {
        phoneField.resignFirstResponder()
        codeField.resignFirstResponder()
        
        if phoneField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入手机号")
        } else if !phoneField.phoneNumberString.isPhoneNumber() {
            SVProgressHUD.showError(withStatus: "请输入正确手机号")
        } else if codeField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入验证码")
        } else if codeField.text?.count ?? 0 < 4 {
            SVProgressHUD.showError(withStatus: "验证码长度不符")
        } else {
            switch type {
            case .newBind:
                GMNet.request(GMLogin.bindPhone(phone: phoneField.phoneNumberString, code: codeField.text!)) { (_) in
                    SVProgressHUD.showSuccess(withStatus: "绑定成功")
                    self.delegate?.popBack()
                }
            case .exchangeOld:
                delegate?.pushView(GMPhoneCodeView(type: .exchangeNew(oldCode: codeField.text!)))
            case .exchangeNew(oldCode: let oldCode):
                GMNet.request(GMLogin.changePhone(newPhone: phoneField.phoneNumberString, oldCode: oldCode, newCode: codeField.text!)) { (_) in
                    SVProgressHUD.showSuccess(withStatus: "绑定成功")
                    self.delegate?.popBack(count: 2)
                }
            }
        }
    }
    
    func config(type: GMPhoneCodeViewType) {
        switch type {
        case .newBind:
            title = "绑定手机号"
            phoneField.placeholder = "请输入您的手机号"
            actionButton.setTitle("确定", for: .normal)
        case .exchangeOld:
            title = "手机换绑"
            phoneField.placeholder = "请输入原绑定手机号"
            actionButton.setTitle("下一步", for: .normal)
        case .exchangeNew:
            title = "手机换绑"
            phoneField.placeholder = "请输入需要绑定的新手机号"
            actionButton.setTitle("确定", for: .normal)
        }
    }
}
