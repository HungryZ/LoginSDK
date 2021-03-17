//
//  AppDelegate.swift
//  LoginSDKDemo
//
//  Created by 张海川 on 2021/2/8.
//

import UIKit
import LoginSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        LoginManager.register(gameId: "773", host: "https://demo.gm88.com", trackingKey: "6e4444b67f30314e699f983c197f21a6")
        LoginManager.shared.delegate = self
        
        let rootVC: UIViewController
        
        if LoginManager.shared.isLogin {
            // 已经登录，进入游戏
            rootVC = ViewController()
            LoginManager.shared.showRealNameCerAlertIfNeeded()
        } else {
            // 没有登录
            rootVC = LoginManager.shared.getLoginController()
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        LoginManager.shared.showFloatBallIfNeeded() // 需在 makeKeyAndVisible() 之后调用
        
        return true
    }

}

extension AppDelegate: LoginSDKDelegate {
    
    func userLoginSucceed() {
        print("userLoginSucceed-\(LoginManager.shared.token!)")
        
        // 登录成功，进入游戏
        // ...
        
        window?.rootViewController = ViewController()
        LoginManager.shared.showFloatBallIfNeeded()
        LoginManager.shared.showRealNameCerAlertIfNeeded()
    }
    
    func userLogout() {
        print("userLogout")
        
        // 退出登录
        // ...
        
        window?.rootViewController = LoginManager.shared.getLoginController()
    }
}
