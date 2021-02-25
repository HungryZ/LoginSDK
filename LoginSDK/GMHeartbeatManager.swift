//
//  GMHeartbeatManager.swift
//  LoginSDK
//
//  Created by 张海川 on 2021/2/25.
//

class GMHeartbeatManager {
    
    lazy var timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
    
    var enableRealNameVerify: Bool = false
    
    
    public static let shared = GMHeartbeatManager()
    private init() {
        DispatchQueue.global().async {
            GMNet.request(GMLogin.realNameSwitch) { (response) in
                if let enable = response["enableRealname"] as? Bool {
                    self.enableRealNameVerify = enable
                }
                self.timer.fire()
            }
        }
    }
    
    @objc
    func timerEvent() {
        guard LoginManager.shared.isLogin else { return }
        
        GMNet.request(GMLogin.heartbeat(isFront: true)) { (response) in
            
            guard self.enableRealNameVerify else { return }
            guard let limit = response["limit_login"] as? Int, limit != 0 else { return }
            guard let timeLeft = response["time_left"] as? Int else { return }
            
            switch limit {
            
            case 1: // 未进行实名认证的用户，每15天只能玩1个小时，超过1个小时后提示该用户需要进行实名
                if timeLeft == 15 {
                    GMAlertView.show(title: "温馨提示", message: "根据规定未实名制认证用户只能游玩60分钟 您还可游玩15分钟", confirmStr: "前去认证", cancelStr: "关闭") {
                        let vc = GMLoginNaviController(root: GMPersonalView())
                        vc.canDismissByClick = false
                        vc.pushView(GMRealNameCerView())
                        rootVC()?.present(vc, animated: true, completion: nil)
                    } cancelAction: {
                        
                    }
                } else if timeLeft <= 0 {
                    GMAlertView.show(title: "温馨提示", message: "根据规定未实名用户只能游玩60分钟，您已游玩60分钟，请前往实名认证。", confirmStr: "前去认证", cancelStr: "切换账号") {
                        let vc = GMLoginNaviController(root: GMPersonalView())
                        vc.canDismissByClick = false
                        vc.pushView(GMRealNameCerView())
                        rootVC()?.present(vc, animated: true, completion: nil)
                    } cancelAction: {
                        LoginManager.shared.logout()
                    }
                }
            
            case 2: // 进行实名认证了，但是是18岁以下，平时1.5个小时游玩，超过1.5个小时后，提示用户今天可玩时间为0。节假日，3个小时，超过了提示可玩时间为0
                if timeLeft == 15 {
                    guard let isHoliday = response["holiday"] as? Bool else { return }
                    let message = isHoliday ? "根据规定未成年人节假日累计游玩时长不可超过180分钟。您还可游玩15分钟" : "根据规定未成年人累计游玩时长不可超过90分钟。您还可游玩15分钟"
                    GMAlertView.show(title: "温馨提示", message: message, confirmStr: "关闭")
                } else if timeLeft <= 0 {
                    GMAlertView.show(title: "温馨提示", message: "您今天的游玩时长已到达上限，请休息下，明天再来游玩！", confirmStr: "退出游戏", cancelStr: "切换账号") {
                        exit(0)
                    } cancelAction: {
                        LoginManager.shared.logout()
                    }
                }
                
            case 3: // 进行实名认证了的，且年龄在18岁以下的，宵禁时间(22-8)，提示不能游玩
                GMAlertView.show(title: "温馨提示", message: "每日22:00至次日08:00未成年人用户不可登录游戏", confirmStr: "退出游戏", cancelStr: "切换账号") {
                    exit(0)
                } cancelAction: {
                    LoginManager.shared.logout()
                }
                
            default: break  // 0不受限制
                
            }
        }
    }
}
