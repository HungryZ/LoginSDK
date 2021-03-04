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
    func iapManagerDidFinishTranscation(_ transcation:[String : Any]?, succeed: Bool, errorMsg: String?);
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
                    self.verifyTransaction(purchase.productId) { (param, succeed, errorMsg) in
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                        self.delegate?.iapManagerDidFinishTranscation(param, succeed: succeed, errorMsg: errorMsg)
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
        canPurchaseByCheckServerRule(price: model["coins"] as! Int) { (canPurchase) in
            guard canPurchase else {
                self.delegate?.iapManagerDidFinishTranscation(model, succeed: false, errorMsg: "后台购买规则校验失败")
                return
            }
            
            var fullParam = model
            fullParam["pay_version"] = "3.0"
            fullParam["payment_code"] = "ios"
            
            GMNet.request(GMOrder.create(para: fullParam)) { (response) in
                guard let order_id = response["order_id"] as? String else {
                    self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false, errorMsg: "后台订单数据缺少order_id")
                    return
                }
                guard let productId = response["productId"] as? String else {
                    self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false, errorMsg: "后台订单数据缺少productId")
                    return
                }
                
                guard SKPaymentQueue.canMakePayments() else {
                    self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false, errorMsg: "内购不可用")
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
                    self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false, errorMsg: "钥匙串写入错误")
                    return
                }
                
                SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: false) { iapResult in
                    switch iapResult {
                    case .success(let product):
                        // fetch content from your server, then:
                        self.verifyTransaction(product.productId) { (_, succeed, errorMsg) in
                            SwiftyStoreKit.finishTransaction(product.transaction)
                            self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: succeed, errorMsg: errorMsg)
                        }
                    case .error(let error):
                        let errorMsg: String
                        switch error.code {
                        case .unknown: errorMsg = "内购流程中断: " + "Unknown error. Please contact support"
                        case .clientInvalid: errorMsg = "内购流程中断: " + "Not allowed to make the payment"
                        case .paymentCancelled: errorMsg = "内购流程中断: " + "用户取消"
                        case .paymentInvalid: errorMsg = "内购流程中断: " + "The purchase identifier was invalid"
                        case .paymentNotAllowed: errorMsg = "内购流程中断: " + "The device is not allowed to make the payment"
                        case .storeProductNotAvailable: errorMsg = "内购流程中断: " + "The product is not available in the current storefront"
                        case .cloudServicePermissionDenied: errorMsg = "内购流程中断: " + "Access to cloud service information is not allowed"
                        case .cloudServiceNetworkConnectionFailed: errorMsg = "内购流程中断: " + "Could not connect to the network"
                        case .cloudServiceRevoked: errorMsg = "内购流程中断: " + "User has revoked permission to use this cloud service"
                        default: errorMsg = "内购流程中断: " + (error as NSError).localizedDescription
                        }
                        self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false, errorMsg: errorMsg)
                    }
                }
            } fail: { (msg) in
                self.delegate?.iapManagerDidFinishTranscation(fullParam, succeed: false, errorMsg: "订单创建错误")
            }
        }
    }
    
    func verifyTransaction(_ productId: String, verifyResult: @escaping ([String : Any]?, Bool, String?) -> Void) {
        
        let keyChain = Keychain(service: GMIAPManager.bundleID)
        guard let data = try? keyChain.getData(productId),
              var localTranscationParam = try? JSONSerialization.jsonObject(with: data) as? [String : Any] else {
            verifyResult(nil, false, "钥匙串读取错误")
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
            verifyResult(localTranscationParam, true, nil)
            try? keyChain.remove(productId)

            let developerinfo = localTranscationParam["developerinfo"] as! String
            Tracking.setRyzf(developerinfo, ryzfType: "appstore", hbType: "CNY", hbAmount: 0)
        } fail: { (msg) in
            #warning("可能漏单，需要判断失败的情况")
            verifyResult(localTranscationParam, false, "后台校验失败")
        }
    }
    
    func canPurchaseByCheckServerRule(price: Int, callBack: @escaping (Bool) -> Void) {
        LoginManager.shared.getRealNameVerifyStatus { (enable) in
            if enable {
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
    
}
