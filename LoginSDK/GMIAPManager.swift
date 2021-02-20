//
//  GMIAPManager.swift
//  LoginSDK
//
//  Created by 张海川 on 2021/2/9.
//

import StoreKit

public class GMIAPManager: NSObject {
    
    public static let shared = GMIAPManager()
    private override init() {
        super.init()
        
        SKPaymentQueue.default().add(self)
    }
    
    var request: SKProductsRequest!
    var order_id: String! = "515242"
    
    deinit {
        print("释放充值")
        if (self.request != nil) {
            self.request.cancel()
        }
        
        NotificationCenter.default.removeObserver(self)
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK:- 购买
    public func startIAP(withProductId productId: String) {
        if SKPaymentQueue.canMakePayments() {
            // 你的itunesConnect的商品ID
            self.getProductInfow(proId: productId)
        } else {
            print("不允许程序内付费")
        }
        
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
//        GMNet.request(GMOrder.create(para: para)) { (response) in
//            guard let order_id = response["order_id"] as? String else { return }
//            self.order_id = order_id
//            guard let productId = response["productId"] as? String else { return }
//
//            SKPaymentQueue.default().add(self)
//            if SKPaymentQueue.canMakePayments() {
//                // 你的itunesConnect的商品ID
//                self.getProductInfow(proId: productId)
//            } else {
//                print("不允许程序内付费")
//            }
//        }
    }
    
}

extension GMIAPManager: SKProductsRequestDelegate {
    
    // 苹果内购服务，下面的ProductId应该是事先在itunesConnect中添加好的，已存在的付费项目。否则查询会失败。
    func getProductInfow(proId: String){
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
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        print("支付调用完成")
    }
    
}

extension GMIAPManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("\(type(of: self).description()).\(#function)")
        
        for tran in transactions {
            switch tran.transactionState {
            case .purchased: // 购买成功，此时要提供给用户相应的内容
                SKPaymentQueue.default().finishTransaction(tran)
                
//                let receiptStr: String
//                if let url = Bundle.main.appStoreReceiptURL {
//                    receiptStr = try! Data(contentsOf: url).base64EncodedString()
//                } else {
//                    receiptStr = ""
//                }
//                
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
//                GMNet.request(GMOrder.verify(para: para)) { (response) in
//                    // ...
//                    
//                    SKPaymentQueue.default().finishTransaction(tran)
//                }
                
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

    
    // Sent when transactions are removed from the queue (via finishTransaction:).
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("\(type(of: self).description()).\(#function)")
    }

    
    // Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("\(type(of: self).description()).\(#function)")
    }

    
    // Sent when all transactions from the user's purchase history have successfully been added back to the queue.
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("\(type(of: self).description()).\(#function)")
    }

    
    // Sent when the download state has changed.
    public func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        print("\(type(of: self).description()).\(#function)")
    }

    
    // Sent when a user initiates an IAP buy from the App Store
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        print("\(type(of: self).description()).\(#function)")
        return true
    }

    
    public func paymentQueueDidChangeStorefront(_ queue: SKPaymentQueue) {
        print("\(type(of: self).description()).\(#function)")
    }

    
    // Sent when entitlements for a user have changed and access to the specified IAPs has been revoked.
    public func paymentQueue(_ queue: SKPaymentQueue, didRevokeEntitlementsForProductIdentifiers productIdentifiers: [String]) {
        print("\(type(of: self).description()).\(#function)")
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
