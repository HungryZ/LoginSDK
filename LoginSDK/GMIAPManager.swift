//
//  GMIAPManager.swift
//  LoginSDK
//
//  Created by 张海川 on 2021/2/9.
//

import StoreKit
import KeychainAccess

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
        
        SKPaymentQueue.default().add(self)
    }
    
    var request: SKProductsRequest!
    
    deinit {
        print("释放充值")
        if (self.request != nil) {
            self.request.cancel()
        }
        
        NotificationCenter.default.removeObserver(self)
        SKPaymentQueue.default().remove(self)
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
            self.getProductInfow(proId: productId)
            self.result = result
        } fail: { (msg) in
            result(false)
        }
    }
    
}

extension GMIAPManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tran in transactions {
            switch tran.transactionState {
            case .purchased: // 购买成功，此时要提供给用户相应的内容
                guard let transactionId = tran.transactionIdentifier else {
                    SKPaymentQueue.default().finishTransaction(tran)
                    return
                }
                let keyChain = Keychain(service: GMIAPManager.bundleID)
                
                var nullableTranscationDic: [String : Any]?
                if self.transcationModelDic != nil {
                    // self.transcationModelDic存在说明是新交易，需要存入本地
                    nullableTranscationDic = self.transcationModelDic!
                    if let data = try? JSONSerialization.data(withJSONObject: self.transcationModelDic!) {
                        try? keyChain.set(data, key: transactionId)
                    }
                } else {
                    // self.transcationModelDic为空，说明是APP刚启动，是之前的未完成交易，需要从本地读取订单信息
                    if let data = try? keyChain.getData(transactionId) {
                        if let localDic = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                            nullableTranscationDic = localDic
                        }
                    }
                }
                guard var transcationDic = nullableTranscationDic else {
                    SKPaymentQueue.default().finishTransaction(tran)
                    return
                }
                
                let receiptStr: String
                if let url = Bundle.main.appStoreReceiptURL {
                    receiptStr = try! Data(contentsOf: url).base64EncodedString()
                } else {
                    receiptStr = ""
                }
                transcationDic["apple_receipt"] = receiptStr
                transcationDic["item_id"] = tran.payment.productIdentifier
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
                    SKPaymentQueue.default().finishTransaction(tran)
                    try? keyChain.remove(transactionId)
                    
                    let developerinfo = transcationDic["developerinfo"] as! String
                    Tracking.setRyzf(developerinfo, ryzfType: "appstore", hbType: "CNY", hbAmount: 0)
                }
                
                break
                
            case .purchasing: // 购买中，此时可更新UI来展现购买的过程
                break
            
            case .restored: // 恢复已购产品，此时需要将已经购买的商品恢复给用户
                SKPaymentQueue.default().finishTransaction(tran)
                print("恢复已购产品")
                break
            
            case .failed: // 购买错误，此时要根据错误的代码给用户相应的提示
                SKPaymentQueue.default().finishTransaction(tran)
                print("购买失败")
                break
                
            default:
                break
                
            }
        }
    }
    
}

extension GMIAPManager: SKProductsRequestDelegate {
    
    // 苹果内购服务，下面的ProductId应该是事先在itunesConnect中添加好的，已存在的付费项目。否则查询会失败。
    func getProductInfow(proId: String) {
        self.request = SKProductsRequest(productIdentifiers: [proId])
        self.request.delegate = self
        self.request.start()
        
        print("请求开始请等待...")
    }
    
    // 收到产品返回信息
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("--------------收到产品反馈消息---------------------")
        if response.products.count == 0 || response.invalidProductIdentifiers.count > 0 {
            print("查找不到商品信息")
            result!(false)
            return
        }
        
        let product = response.products.first!
        print(product.description)
        print(product.localizedTitle)
        print(product.localizedDescription)
        print(product.price)
        print(product.productIdentifier)
        print("发送购买请求")
        SKPaymentQueue.default().add(SKPayment(product: product))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("请求失败 \(error)")
        result!(false)
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        print("支付调用完成")
    }
    
}

extension GMIAPManager {
    
    /// 获取票据的base64数据
    /// - Parameter callback: 获取成功的回调
    func base64Receipt(callback: @escaping(_ base64: String) -> Void) {
        if let url = Bundle.main.appStoreReceiptURL {
            let string = try! Data(contentsOf: url).base64EncodedString(options: .lineLength64Characters)
            callback(string)
        } else {
//            refreshReceiptService.refreshReceipt {[weak self] in
//                if let url = Bundle.main.appStoreReceiptURL {
//                    guard let base64 = self?._base64Receipt(with: url) else { return }
//                    callback(base64)
//                }else {
//                    // 出错
//                    DDLogInfo("unknow no appStoreReceiptURL")
//                }
//            }
        }
    }
}
