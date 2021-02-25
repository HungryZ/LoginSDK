//
//  GMSMSCodeView.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class GMSMSCodeView: GMBaseView {
    
    let phone: String
    
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
                                       stamp: "sms_login")
        button.frame = CGRect(x: 0, y: 0, width: ScaleWidth(70), height: 20)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor._999999.cgColor
        button.addTarget(self, action: #selector(getSMSButtonClicked), for: .touchUpInside)
        
        return button
    }()
    
    lazy var checkButton: UIButton = {
        let button = UIButton(imageName: "protocol_0", target: self, action: #selector(checkButtonClicked))
        button.setImage(UIImage(fromBundle: "protocol_1"), for: .selected)
        
        return button
    }()
    
    lazy var protocolButton = UIButton(title: "用户服务协议",
                                       titleColor: .init("#2DA0F7"),
                                       font: 10,
                                       target: self,
                                       action: #selector(protocolButtonClicked))
    
    lazy var actionButton = UIButton.themeButton(title: "确定", target: self, action: #selector(actionButtonClicked))
    
    init(phone: String) {
        self.phone = phone
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(type(of: self).description()).\(#function)")
    }
    
    override func buildUI() {
        super.buildUI()
        
        title = ""
        
        checkButton.adjustsImageWhenHighlighted = false
        
        let hintLabel = UILabel(font: 10, textColor: ._999999, text: "我已阅读并同意")
        let protocolRow = UIView()
        protocolRow.addSubview(checkButton)
        protocolRow.addSubview(hintLabel)
        protocolRow.addSubview(protocolButton)
        checkButton.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(0)
        }
        hintLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(checkButton)
            make.left.equalTo(checkButton.snp.right).offset(10)
        }
        protocolButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(checkButton)
            make.left.equalTo(hintLabel.snp.right)
            make.right.equalTo(0)
        }
        
        contentView.addSubview(codeField)
        contentView.addSubview(protocolRow)
        contentView.addSubview(actionButton)
        
        codeField.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.right.equalTo(0).inset(ScaleWidth(30))
            make.height.equalTo(ScaleWidth(36))
        }
        protocolRow.snp.makeConstraints { (make) in
            make.top.equalTo(codeField.snp.bottom).offset(17)
            make.centerX.equalTo(contentView)
        }
        actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(protocolRow.snp.bottom).offset(17)
            make.centerX.equalTo(contentView)
            make.width.equalTo(ScaleWidth(100))
            make.height.equalTo(35)
            make.bottom.equalTo(-15)
        }
    }
    
    @objc func getSMSButtonClicked() {
        GMNet.request(GMLogin.getSMSCode(for: "login", phone: phone)) { (response) in
            self.getSMSButton.startCounting()
            self.codeField.becomeFirstResponder()
        }
    }
    
    @objc func checkButtonClicked() {
        checkButton.isSelected = !checkButton.isSelected
    }
    
    @objc func protocolButtonClicked() {
        delegate?.pushView(GMWebView(urlString: "http://www.howanjoy.com/base_aggreement.html"))
    }
    
    @objc func actionButtonClicked() {
        codeField.resignFirstResponder()
        if !checkButton.isSelected {
            SVProgressHUD.showError(withStatus: "请同意用户服务协议")
        } else if codeField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入验证码")
        } else if codeField.text?.count ?? 0 < 4 {
            SVProgressHUD.showError(withStatus: "验证码长度不符")
        } else {
            GMNet.request(GMLogin.smsLogin(phone: phone, code: codeField.text!)) { (response) in
                let user = response.decode(to: GMUserModel.self)
                LoginManager.shared.loginSucceed(token: user.token!)
                if let register = user.new_user, register {
                    Tracking.setRegisterWithAccountID(user.uid)
                }
                GMPhoneHistoryView.savePhone(self.phone.phoneFormat())
            }
        }
    }
}
