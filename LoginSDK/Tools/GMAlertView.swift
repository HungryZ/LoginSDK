//
//  GMAlertView.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class GMAlertView: GMBaseCoverView {
    
    lazy var contentView: UIView = {
        let view = UIView(backgroundColor: .white)
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    lazy var titleLabel = UILabel(font: UIFont.systemFont(ofSize: 15, weight: .medium), textColor: UIColor._333333)
    
    lazy var messageLabel: UILabel = {
        let label = UILabel(font: 12, textColor: ._333333)
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var confirmButton = UIButton.themeButton(title: "", target: self, action: #selector(confirmButtonClicked))
    
    lazy var cancelButton = UIButton(title: "", titleColor: ._666666, font: 15, target: self, action: #selector(cancelButtonClicked))
    
    var confrimAction: (() -> Void)?
    
    var cancelAction: (() -> Void)?

    required init(frame: CGRect) {
        super.init(frame: frame)
        
        let stack = UIStackView()
        stack.spacing = 20
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(confirmButton)
        
        addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(stack)
        
        contentView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(ScaleWidth(279))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(18)
            make.centerX.equalTo(contentView)
        }
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.left.right.equalTo(contentView).inset(30)
        }
        stack.snp.makeConstraints { (make) in
            make.top.equalTo(messageLabel.snp.bottom).offset(28)
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(-15)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: ScaleWidth(100), height: 35))
        }
        cancelButton.snp.makeConstraints { (make) in
            make.size.equalTo(confirmButton)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func confirmButtonClicked() {
        if let confirm = confrimAction {
            confirm()
        }
        removeSelf()
    }
    
    @objc func cancelButtonClicked() {
        if let cancel = cancelAction {
            cancel()
        }
        removeSelf()
    }
}

// MARK: - Public

extension GMAlertView {
    
    public static func show(title: String,
                            message: String,
                            confirmStr: String,
                            cancelStr: String? = nil,
                            confirmAction: (() -> Void)? = nil,
                            cancelAction: (() -> Void)? = nil) {
        
        let alertView = GMAlertView()
        alertView.titleLabel.text = title
        alertView.messageLabel.attributedText = message.setLineSpacing(6)
        alertView.confirmButton.setTitle(confirmStr, for: .normal)
        alertView.confrimAction = confirmAction
        if let cancelString = cancelStr {
            alertView.cancelButton.setTitle(cancelString, for: .normal)
            alertView.cancelAction = cancelAction
        } else {
            alertView.cancelButton.isHidden = true
        }
        
        alertView.showSelf()
    }
}
