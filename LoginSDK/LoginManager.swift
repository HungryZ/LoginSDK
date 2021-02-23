//
//  LoginManager.swift
//  GMLogin
//
//  Created by 张海川 on 2021/1/29.
//

public protocol LoginSDKDelegate: class {
    func userLoginSucceed()
    func userLogout()
}

public class LoginManager {
    
    let key_token = "LoginSDK.user.token"
    
    static let noti_user_login = NSNotification.Name(rawValue: "LoginSDK.noti_user_login")
    
    public static let shared = LoginManager()
    private init() {
        _ = GMIAPManager.shared
        Tracking.initWithAppKey("6e4444b67f30314e699f983c197f21a6", withChannelId: "_default_")
    }
    
    weak var delegate: LoginSDKDelegate?
    
    var memoryToken: String?
    
    var user: GMUserModel?
    
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
    
    // MARK: - Public
    
    public func setDelegate(_ delegate: LoginSDKDelegate) {
        self.delegate = delegate
    }
    
    /// 判断登录状态，如果已登录，返回为空，并判断是否需要实名认证；如果未登录，返回登录控制器
    @discardableResult
    public func checkStatus() -> UIViewController? {
        if isLogin {
            GMFloatButtonManager.showFloatButton()
            showRealNameCerAlertIfNeeded()
            return nil
        } else {
            return getLoginController()
        }
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
    
    // MARK: - Private
    
    func loginSucceed(token: String) {
        self.token = token
        NotificationCenter.default.post(name: LoginManager.noti_user_login, object: nil)
        delegate?.userLoginSucceed()
    }
    
    func showPersonalView() {
        rootVC()?.present(GMLoginNaviController(root: GMPersonalView()), animated: true, completion: nil)
        GMFloatButtonManager.hideFloatButton()
    }
    
    func rootVC() -> UIViewController? {
        UIApplication.shared.windows.first?.rootViewController
    }
    
    func showRealNameCerAlertIfNeeded() {
        guard isLogin else { return }
        GMNet.request(GMLogin.userInfo) { (response) in
            self.user = response.decode(to: GMUserModel.self)
            guard self.user!.needBindIdCardInfo else { return }
            let message = "根据国家新闻出版署发布的《关于防止未成年人沉迷网络游戏的通知》，未实名制认证的账号只能体验一次游戏且时长上限为1个小时，建议立即进行实名制认证。"
            GMAlertView.show(title: "实名制认证", message: message, confirmStr: "前往认证", cancelStr: "下次再说", confirmAction: {
                let vc = GMLoginNaviController(root: GMPersonalView())
                vc.pushView(GMRealNameCerView())
                self.rootVC()?.present(vc, animated: true, completion: nil)
            }) {
                GMFloatButtonManager.showFloatButton()
            }
            GMFloatButtonManager.hideFloatButton()
        }
    }
}
