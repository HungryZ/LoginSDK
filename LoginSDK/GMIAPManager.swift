//
//  GMIAPManager.swift
//  LoginSDK
//
//  Created by 张海川 on 2021/2/9.
//

import StoreKit
import KeychainAccess
import SwiftyStoreKit

public protocol GMIAPManagerDelegate: class {
    func iapManagerDidFinishTranscation(_ transcation:[String : Any]?, succeed: Bool);
}

public class GMIAPManager: NSObject {
    
    /// 单例
    public static let shared = GMIAPManager()
    /// 购买结果回调代理
    public weak var delegate: GMIAPManagerDelegate?
    
    static let bundleID = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        
    private override init() {
        super.init()
        
        SwiftyStoreKit.completeTransactions(atomically: false) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    self.verifyTransaction(purchase.productId) { (param, succeed) in
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                        self.delegate?.iapManagerDidFinishTranscation(param, succeed: succeed)
                    }
                    
                default:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                    break
                }
            }
        }
    }
    
    /// 发起内购
    public func startIAP(_ model: [String : Any]) {
        verifyPurchaseRule(price: model["coins"] as! Int) { (canPurchase) in
            guard canPurchase else {
                self.delegate?.iapManagerDidFinishTranscation(model, succeed: false)
                return
            }
            
            var fullParam = model
            fullParam["pay_version"] = "3.0"
            fullParam["payment_code"] = "ios"
            
            GMNet.request(GMOrder.create(para: fullParam)) { (response) in
                guard let order_id = response["order_id"] as? String else {
                    self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false)
                    return
                }
                guard let productId = response["productId"] as? String else {
                    self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false)
                    return
                }
                
                guard SKPaymentQueue.canMakePayments() else {
                    self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false)
                    return
                }
                
                var transcationParam = model
                transcationParam["order_id"] = order_id
                transcationParam["item_id"] = productId
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: transcationParam)
                    let keyChain = Keychain(service: GMIAPManager.bundleID)
                    try keyChain.set(data, key: productId)
                } catch {
                    self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false)
                    return
                }
                
                SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: false) { iapResult in
                    switch iapResult {
                    case .success(let product):
                        // fetch content from your server, then:
                        self.verifyTransaction(product.productId) { (_, succeed) in
                            SwiftyStoreKit.finishTransaction(product.transaction)
                            self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: succeed)
                        }
                        
                    case .error:
                        self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false)
                    }
                }
            } fail: { (msg) in
                self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false)
            }
        }
    }
    
    func verifyTransaction(_ productId: String, verifyResult: @escaping ([String : Any]?, Bool) -> Void) {
        
        let keyChain = Keychain(service: GMIAPManager.bundleID)
        guard let data = try? keyChain.getData(productId),
              var localTranscationParam = try? JSONSerialization.jsonObject(with: data) as? [String : Any] else {
            verifyResult(nil, false)
            return
        }

        let receiptStr: String
        if let url = Bundle.main.appStoreReceiptURL {
            receiptStr = try! Data(contentsOf: url).base64EncodedString()
        } else {
            receiptStr = ""
        }
        localTranscationParam["apple_receipt"] = receiptStr
        localTranscationParam["type"] = "app"
        
        GMNet.request(GMOrder.verify(para: localTranscationParam)) { (response) in
            verifyResult(localTranscationParam, true)
            try? keyChain.remove(productId)

            let developerinfo = localTranscationParam["developerinfo"] as! String
            Tracking.setRyzf(developerinfo, ryzfType: "appstore", hbType: "CNY", hbAmount: 0)
        } fail: { (msg) in
            verifyResult(localTranscationParam, false)
        }
    }
    
    func verifyPurchaseRule(price: Int, callBack: @escaping (Bool) -> Void) {
        if GMHeartbeatManager.shared.enableRealNameVerify {
            GMNet.request(GMOrder.limit(price: price)) { (response) in
                if let errmsg = response["errmsg"] as? String, errmsg.count > 0 {
                    if let realname = response["realname"] as? Bool, !realname {
                        GMAlertView.show(title: "温馨提示", message: errmsg, confirmStr: "前去认证", cancelStr: "关闭") {
                            let vc = GMLoginNaviController(root: GMPersonalView())
                            vc.canDismissByClick = true
                            vc.pushView(GMRealNameCerView())
                            rootVC()?.present(vc, animated: true, completion: nil)
                        } cancelAction: {
                            
                        }
                    } else {
                        GMAlertView.show(title: "温馨提示", message: errmsg, confirmStr: "好的")
                    }
                    callBack(false)
                } else {
                    callBack(true)
                }
            }
        } else {
            callBack(true)
        }
    }
    
}
