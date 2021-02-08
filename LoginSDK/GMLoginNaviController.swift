//
//  GMLoginNaviController.swift
//  GMLogin
//
//  Created by 张海川 on 2021/1/29.
//

import UIKit
import IQKeyboardManagerSwift
import SnapKit

class GMLoginNaviController: UIViewController {
    
    var viewStack = [GMBaseView]()
    
    weak var contentView: GMBaseView! {
        didSet {
            if oldValue != nil {
                oldValue.removeFromSuperview()
            }
            view.addSubview(contentView)
            contentView.snp.makeConstraints { (make) in
                make.center.equalTo(view)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(root: GMBaseView) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        pushView(root)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
//        zhc_hideNavigationBar = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resetRootToStartView),
                                               name: LoginManager.noti_user_token_invalid,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userLoginSucceed),
                                               name: LoginManager.noti_user_login,
                                               object: nil)
        config()
        
        let bgButton = UIButton(imageName: "", target: self, action: #selector(backgroundClicked))
        view.addSubview(bgButton)
        bgButton.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    func config() {
//        SVProgressHUD.setMaximumDismissTimeInterval(1.2)
//        SVProgressHUD.setDefaultStyle(.dark)
//        SVProgressHUD.setDefaultMaskType(.clear)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    @objc func backgroundClicked() {
        dismiss(animated: true) {
            GMFloatButtonManager.showFloatButton()
        }
    }
}

extension GMLoginNaviController: GMBaseViewDelegate {
    
    func popBack() {
        viewStack.removeLast()
        
        contentView = viewStack.last
        contentView.willAppear()
    }
    
    func popBack(count: Int) {
        for _ in 0 ..< count {
            viewStack.removeLast()
        }
        contentView = viewStack.last
        contentView.willAppear()
    }
    
    func pushView(_ view: GMBaseView) {
        viewStack.append(view)
        
        contentView = view
        contentView.willAppear()
        view.delegate = self
    }
}

extension GMLoginNaviController {
    
    @objc func resetRootToStartView() {
        viewStack.removeAll()
        
        pushView(GMSMSPhoneView())
    }
    
    @objc func userLoginSucceed() {
        dismiss(animated: true) {
            LoginManager.shared.showFloatButton()
        }
    }
}

/*
 var start = DispatchTime.now()
 print(dic)
 var end = DispatchTime.now()
 var time = end.uptimeNanoseconds - start.uptimeNanoseconds
 print(Double(time) / 1_000_000_000)
 */
