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
        
        LoginManager.shared.setDelegate(self)
        
        let rootVC: UIViewController
        
        let vc = LoginManager.shared.checkStatus()
        if vc != nil {
            // 返回了登录控制器说明没有登录
            rootVC = vc!
        } else {
            // 已经登录，进入游戏
            rootVC = ViewController()
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
        return true
    }

}

extension AppDelegate: LoginSDKDelegate {
    
    func userLoginSucceed() {
        print("userLoginSucceed-\(LoginManager.shared.token!)")
        
        // 登录成功，进入游戏
        // ...
        
        window?.rootViewController = ViewController()
        LoginManager.shared.checkStatus()
    }
    
    func userLogout() {
        print("userLogout")
        
        // 退出登录
        // ...
        
        window?.rootViewController = LoginManager.shared.checkStatus()
    }
}
