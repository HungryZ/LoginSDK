//
//  LoginManager.swift
//  GMLogin
//
//  Created by 张海川 on 2021/1/29.
//

import IQKeyboardManagerSwift
//import DoraemonKit

func GMPrint(_ msg: String) {
    if LoginManager.shared.logEnable {
        print(msg)
    }
}

@objc public protocol LoginSDKDelegate: NSObjectProtocol {
    func userLoginSucceed()
    func userLogout()
}

@objcMembers public class LoginManager: NSObject {
    
    let key_token = "LoginSDK.user.token"
    
    static let noti_user_login = NSNotification.Name(rawValue: "LoginSDK.noti_user_login")
    
    // 配置参数
    var gameId: String!
    var host: String!
    
    private override init() {
        super.init()
        config()
    }
    
    /// 打印开关
    public var logEnable = false
    
    public weak var delegate: LoginSDKDelegate?
    
    var memoryToken: String?
    
    var user: GMUserModel?
    
    private var enableRealNameVerify: Bool?
}

// MARK: - public

extension LoginManager {
    /// 单例
    public static let shared = LoginManager()
    
    /// 是否登录
    public var isLogin: Bool {
        token != nil
    }
    
    /// user token
    public var token: String? {
        get {
            if let mToken = memoryToken {
                return mToken
            } else {
                if let uToken = UserDefaults.standard.string(forKey: key_token) {
                    memoryToken = uToken
                    return memoryToken
                } else {
                    return nil
                }
            }
        }
        set {
            if let token = newValue, token.count > 0 {
                memoryToken = token
                UserDefaults.standard.setValue(memoryToken, forKey: key_token)
            }
        }
    }
    
    /// 初始化SDK
    /// - Parameters:
    ///   - gameId: game_id
    ///   - host: 接口地址
    ///   - trackingKey: 热云appKey
    public static func register(gameId: String, host: String, trackingKey: String) {
        self.shared.gameId = gameId
        self.shared.host = host
        
        Tracking.initWithAppKey(trackingKey, withChannelId: "_default_")
    }
    
    /// 获取登录控制器
    public func getLoginController() -> UIViewController {
        GMLoginNaviController(root: GMSMSPhoneView())
    }
    
    /// 退出登录
    public func logout() {
        memoryToken = nil
        UserDefaults.standard.removeObject(forKey: key_token)
        delegate?.userLogout()
    }
    
    /// 显示悬浮小球（未登录状态无效）
    public func showFloatBallIfNeeded() {
        if isLogin {
            GMFloatButtonManager.showFloatButton()
        }
    }
    
    /// 显示实名认证弹窗（已实名用户不会弹出）
    public func showRealNameCerAlertIfNeeded() {
        getRealNameVerifyStatus { (enable) in
            if enable {
                self.showRealNameCerAlert()
            }
        }
    }
}

// MARK: - Private

extension LoginManager {
    
    func config() {
//        DoraemonManager.shareInstance().install()
        
        SVProgressHUD.setMaximumDismissTimeInterval(1.2)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.clear)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        _ = GMIAPManager.shared
        // 开启心跳
        DispatchQueue.global().async {
            self.getRealNameVerifyStatus { (_) in
                DispatchQueue.main.async {
                    GMHeartbeatManager.shared.timer.fire()
                }
            }
        }
    }
    
    func loginSucceed(token: String) {
        self.token = token
        NotificationCenter.default.post(name: LoginManager.noti_user_login, object: nil)
        // 登陆成功立即触发心跳
        GMHeartbeatManager.shared.needSetIntervalTo1 = true
        GMHeartbeatManager.shared.timer.fire()
        delegate?.userLoginSucceed()
    }
    
    func showPersonalView() {
        rootVC()?.present(GMLoginNaviController(root: GMPersonalView()), animated: true, completion: nil)
        GMFloatButtonManager.hideFloatButton()
    }
    
    func getRealNameVerifyStatus(result: @escaping (Bool) -> Void) {
        if let status = enableRealNameVerify {
            result(status)
        } else {
            GMNet.request(GMLogin.realNameSwitch) { (response) in
                if let enable = response["enableRealname"] as? Bool {
                    self.enableRealNameVerify = enable
                    result(enable)
                } else {
                    result(false)
                }
            }
        }
    }
    
    func showRealNameCerAlert() {
        GMNet.request(GMLogin.userInfo) { (response) in
            self.user = response.decode(to: GMUserModel.self)
            guard self.user!.needBindIdCardInfo else {
                GMFloatButtonManager.showFloatButton()
                return
            }
            let message = "根据国家新闻出版署发布的《关于防止未成年人沉迷网络游戏的通知》，未实名制认证的账号只能体验一次游戏且时长上限为1个小时，建议立即进行实名制认证。"
            GMAlertView.show(title: "实名制认证", message: message, confirmStr: "前往认证", cancelStr: "下次再说", confirmAction: {
                let vc = GMLoginNaviController(root: GMPersonalView())
                vc.pushView(GMRealNameCerView())
                rootVC()?.present(vc, animated: true, completion: nil)
            }) {
                GMFloatButtonManager.showFloatButton()
            }
            GMFloatButtonManager.hideFloatButton()
        }
    }
}
