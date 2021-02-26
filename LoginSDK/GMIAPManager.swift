//
//  GMIAPManager.swift
//  LoginSDK
//
//  Created by 张海川 on 2021/2/9.
//

import StoreKit
import KeychainAccess
import SwiftyStoreKit

public class GMTransactionModel: Codable {
    
    var transactionIdentifier: String
    var productId: String
    var item_name: String
    var apple_receipt: String
    var order_id: String
    var developerinfo: String
    var roleid: String
    var item_price: CGFloat
    var item_id: String
    var coins: Int
    var serverid: String
    var notify_url: String?
    var uid: String?
    var type: String = "app"
    var pay_version: String = "3.0"
    var payment_code: String = "ios"
}

public class GMIAPManager: NSObject {
    
    public static let bundleID = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
    
    public static let shared = GMIAPManager()
    
    var transcationModelDic: [String : Any]?
    var transcationModel: GMTransactionModel?
    
    var result: ((Bool) -> Void)?
    
    private override init() {
        super.init()
        
        SwiftyStoreKit.completeTransactions(atomically: false) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    // MARK: - TODO: verify
                    self.verifyTransaction(purchase.transaction) { (succeed) in
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                default:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                    break
                }
            }
        }
    }
    
    public func startIAP(_ model: [String : Any], result: @escaping (Bool) -> Void) {
        
//        let para: [String : Any] = [
//            "notify_url"    : "",
//            "coins"         : 6,
//            "item_id"       : "1101",
//            "developerinfo" : "49289088",
//            "pay_version"   : "3.0",
//            "serverid"      : "1",
//            "roleid"        : "554",
//            "payment_code"  : "ios",
//        ]
//        var fullParam: [String : Any] = [
//            "pay_version"   : "3.0",
//            "payment_code"  : "ios",
//        ]
        var fullParam = model
        fullParam["pay_version"] = "3.0"
        fullParam["payment_code"] = "ios"
        
        GMNet.request(GMOrder.create(para: fullParam)) { (response) in
            guard let order_id = response["order_id"] as? String else {
                result(false)
                return
            }
            guard let productId = response["productId"] as? String else {
                result(false)
                return
            }
            
            guard SKPaymentQueue.canMakePayments() else {
                result(false)
                return
            }
            
            self.transcationModelDic = model
            self.transcationModelDic?["order_id"] = order_id
            self.transcationModelDic?["productId"] = productId
            self.transcationModelDic?["item_id"] = productId
//            self.getProductInfow(proId: productId)
            self.result = result
            
            
            SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: false) { iapResult in
                switch iapResult {
                case .success(let product):
                    // fetch content from your server, then:
                    self.verifyTransaction(product.transaction) { (succeed) in
                        SwiftyStoreKit.finishTransaction(product.transaction)
                        result(succeed)
                    }
                    print("Purchase Success: \(product.productId)")
                case .error:
                    result(false)
                }
            }
        } fail: { (msg) in
            result(false)
        }
    }
    
    func verifyTransaction(_ tran: PaymentTransaction, verifyResult: @escaping (Bool) -> Void) {
        guard let transactionId = tran.transactionIdentifier else {
            verifyResult(false)
            return
        }
        let keyChain = Keychain(service: GMIAPManager.bundleID)
        
        var nullableTranscationDic: [String : Any]?
        if self.transcationModelDic != nil {
            // self.transcationModelDic存在说明是新交易，需要存入本地
            do {
                let data = try JSONSerialization.data(withJSONObject: self.transcationModelDic!)
                try keyChain.set(data, key: transactionId)
                nullableTranscationDic = self.transcationModelDic!
            } catch {
                
            }
        } else {
            // self.transcationModelDic为空，说明是APP刚启动，是之前的未完成交易，需要从本地读取订单信息
            if let data = try? keyChain.getData(transactionId),
               let localDic = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                nullableTranscationDic = localDic
            }
        }
        guard var transcationDic = nullableTranscationDic else {
            verifyResult(false)
            return
        }
        
        let receiptStr: String
        if let url = Bundle.main.appStoreReceiptURL {
            receiptStr = try! Data(contentsOf: url).base64EncodedString()
        } else {
            receiptStr = ""
        }
        transcationDic["apple_receipt"] = receiptStr
        transcationDic["type"] = "app"
        
//                let para: [String : Any] = [
//                    "item_name"     : "60金币",
//                    "gss_appid"     : "773",
//                    "apple_receipt" : receiptStr,
//                    "order_id"      : order_id!,
//                    "type"          : "app",
//                    "developerinfo" : "49289088",
//                    "roleid"        : "554",
//                    "uid"           : "11609707",
//                    "item_price"    : 6,
//                    "item_id"       : tran.payment.productIdentifier,
//                    "coins"         : 6,
//                    "serverid"      : "1",
//                ]
        GMNet.request(GMOrder.verify(para: transcationDic)) { (response) in
            verifyResult(true)
            try? keyChain.remove(transactionId)
            
            let developerinfo = transcationDic["developerinfo"] as! String
            Tracking.setRyzf(developerinfo, ryzfType: "appstore", hbType: "CNY", hbAmount: 0)
        } fail: { (msg) in
            verifyResult(false)
        }
    }
    
}
