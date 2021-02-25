//
//  GMFloatButtonManager.swift
//  HungryTools_Example
//
//  Created by 张海川 on 2021/2/7.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

class GMFloatButtonManager {
    
    public static let shared = GMFloatButtonManager()
    private init() {}
    
    var floatButton: UIButton!
    var previousCenter: CGPoint!
    
    var timer: Timer?
    var seconds = 1.5
    
    static func showFloatButton() {
        if shared.floatButton != nil {
            shared.floatButton.isHidden = false
            if let superview = shared.floatButton.superview {
                if superview == topWindow() {
                    superview.bringSubviewToFront(shared.floatButton)
                } else {
                    shared.floatButton.removeFromSuperview()
                    topWindow().addSubview(shared.floatButton)
                }
            } else {
                topWindow().addSubview(shared.floatButton)
            }
            return
        }
        let button = UIButton(imageName: "button_0", target: shared, action: #selector(floatButtonTouchUpInside(sender:)))
        button.setImage(UIImage(fromBundle: "button_1"), for: .selected)
        button.setImage(UIImage(fromBundle: "button_1"), for: [.selected, .highlighted])
        button.frame = CGRect(x: 45, y: StatusBarHeight + 44 + 44, width: 50, height: 50)
        button.isSelected = true
        button.addGestureRecognizer(UIPanGestureRecognizer(target: shared, action: #selector(handleGesture(gesture:))))
        
        topWindow().addSubview(button)
        shared.floatButton = button
        shared.moveButtonToSideAfterDelay()
    }
    
    static func hideFloatButton() {
        if shared.floatButton != nil {
            shared.floatButton.isHidden = true
        }
    }
    
    @objc func floatButtonTouchUpInside(sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
            floatButton.frame = CGRect(x: floatButton.frame.origin.x, y: floatButton.frame.origin.y, width: 50, height: 50)
            moveButtonToSideAfterDelay()
        } else {
            LoginManager.shared.showPersonalView()
        }
    }
    
    @objc func handleGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            previousCenter = floatButton.center
            break
        case .changed:
            let translation = gesture.translation(in: floatButton)
            floatButton.center = CGPoint(x: previousCenter.x + translation.x, y: previousCenter.y + translation.y)
            timer?.fireDate = .distantFuture
            break
        case .ended:
            floatButton.isSelected = true
            floatButton.frame = CGRect(x: floatButton.frame.origin.x, y: floatButton.frame.origin.y, width: 50, height: 50)
            timer?.fireDate = Date()
            moveButtonToSideAfterDelay()
            break
        default: break
        }
    }
    
    func moveButtonToSideAfterDelay() {
        seconds = 1.5
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    @objc func timerAction() {
        seconds -= 0.1
        if seconds <= 0 {
            moveButtonToSide()
            timer?.invalidate()
            timer = nil
        }
    }
    
    func moveButtonToSide() {
        UIView.animate(withDuration: 0.25) {
            self.floatButton.superview?.bringSubviewToFront(self.floatButton)
            let frame = self.floatButton.frame
            var x = frame.origin.x
            let imageStr = x < ScreenWidth / 2 ? "button_0_L" : "button_0_R"
            x = x < ScreenWidth / 2 ? 0 : ScreenWidth - 35
            self.floatButton.setImage(UIImage(fromBundle: imageStr), for: .normal)
            self.floatButton.frame = CGRect(x: x, y: frame.origin.y, width: 35, height: 50)
        } completion: { (_) in
            self.floatButton.isSelected = false
        }
    }
}
