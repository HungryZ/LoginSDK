//
//  GMBaseCoverView.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class GMBaseCoverView: UIView {
    
    // MARK: - Instance Property
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(coverViewClicked))
    
    // MARK: - init
    
    public required override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
        addGestureRecognizer(tapGesture)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Instance Method
    
    deinit {
        GMPrint("\(type(of: self).description()).\(#function)")
    }
    
    func disableBackgroundClick() {
        removeGestureRecognizer(tapGesture)
    }
    
    @objc func coverViewClicked() {
        removeSelf()
    }
    
    public func showSelf() {
        self.alpha = 0;
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    func removeSelf() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { (isCompleted) in
            self.removeFromSuperview()
        }
    }
}
