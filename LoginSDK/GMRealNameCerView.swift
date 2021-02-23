//
//  GMRealNameCerView.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class GMRealNameCerView: GMBaseView {
    
    lazy var hintLabel: UILabel = {
        let label = UILabel(font: 11, textColor: .red)
        label.numberOfLines = 0
        label.attributedText = "认证信息只能提交一次，不可修改，慎重填写！该信息仅用于实名认证，不会透露于任何第三方。".setLineSpacing(6)
        
        return label
    }()
    
    lazy var nameField: ZHCTextField = {
        let field = ZHCTextField()
        field.fieldType = .name
        field.leftImage = UIImage(fromBundle: "name")!
        field.placeholder = "请输入姓名"
        field.placeholderFont = .systemFont(ofSize: 12)
        field.placeholderColor = ._999999
        
        return field
    }()
    
    lazy var IDField: ZHCTextField = {
        let field = ZHCTextField()
        field.fieldType = .idCardNumber
        field.leftImage = UIImage(fromBundle: "id_card")!
        field.placeholder = "请输入身份证号码"
        field.placeholderFont = .systemFont(ofSize: 12)
        field.placeholderColor = ._999999
        
        return field
    }()
    
    lazy var actionButton = UIButton.themeButton(title: "确定", target: self, action: #selector(actionButtonClicked))
    
    override func buildUI() {
        super.buildUI()
        
        title = "实名制认证"
        nameField.becomeFirstResponder()
        
        contentView.addSubview(hintLabel)
        contentView.addSubview(nameField)
        contentView.addSubview(IDField)
        contentView.addSubview(actionButton)
        
        hintLabel.snp.makeConstraints { (make) in
            make.top.equalTo(25)
            make.left.right.equalTo(0).inset(ScaleWidth(30))
        }
        nameField.snp.makeConstraints { (make) in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.left.right.equalTo(0).inset(ScaleWidth(30))
            make.height.equalTo(ScaleWidth(36))
        }
        IDField.snp.makeConstraints { (make) in
            make.top.equalTo(nameField.snp.bottom).offset(20)
            make.left.right.height.equalTo(nameField)
        }
        actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(IDField.snp.bottom).offset(30)
            make.centerX.equalTo(contentView)
            make.width.equalTo(ScaleWidth(100))
            make.height.equalTo(35)
            make.bottom.equalTo(-15)
        }
    }
    
    @objc func actionButtonClicked() {
        nameField.resignFirstResponder()
        IDField.resignFirstResponder()
        
        if nameField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入姓名")
        } else if IDField.text?.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入身份证号码")
        } else if IDField.text?.count ?? 0 < 18 {
            SVProgressHUD.showError(withStatus: "身份证号码格式错误")
        } else {
            GMNet.request(GMLogin.realNameCer(name: nameField.text!, idNo: IDField.text!)) { (_) in
                self.delegate?.popBack()
            }
        }
    }
}
