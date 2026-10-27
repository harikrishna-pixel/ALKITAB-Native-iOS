//
//  PaymentHistory.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 30/04/21.
//

import UIKit
import CoreData



class PaymentHistory: NSObject {
  static let sharedInstance = PaymentHistory()
    
    var PayList:Array<NSDictionary> = []
    var WholeList:Dictionary<String, AnyObject> = [:]
    
    var Enddate: String = ""
    var TransactionId: String = ""
    var StartDate: String = ""
    var product_id:String = ""
    /// Used only when the receipt has no expiry, for the purchase that just completed.
    var fallbackProductId: String = ""
    var fallbackTransactionId: String = ""
    
    
    var Appdate: Array<String> = []
    
    
    func paymentInfo() -> Bool {
           if storedSubscriptionIsActive() || ADS_TYPE == 0 || LegacyPaidAppService.shared.isLegacyPaidAppUser {
               return false
            } else {
                return true
            }
    }
    
    
    func paymentInfoVerify() -> Bool {
           if storedSubscriptionIsActive() || LegacyPaidAppService.shared.isLegacyPaidAppUser {
               return false
            } else {
                return true
            }
    }

    /// True only for an IAP / subscription that is currently paid (legacy paid-app status not included).
    func hasActivePurchase() -> Bool {
        return storedSubscriptionIsActive()
    }

    /// Active through the expiry calendar day, or when a lifetime purchase is on the receipt.
    func storedSubscriptionIsActive() -> Bool {
        if UserDefaults.standard.bool(forKey: "HasLifetimePurchase") {
            return true
        }
        if IS_SUBSCRIPTION_ENABLE == 1 && SUBSCRIPTIONID_LifeTime != "" && UserDefaults.standard.string(forKey: "PaymentId") ?? "" == SUBSCRIPTIONID_LifeTime {
            return true
        }
        let stamp = UserDefaults.standard.double(forKey: "SubscriptionExpiryGMT")
        if stamp > 0 {
            return Date().timeIntervalSince1970 <= stamp
        }
        let date = CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI)
        guard !date.isEmpty else { return false }
        let expiryDay = Calendar.current.startOfDay(for: GetReceptKey.shared.convertData(date: date))
        let today = Calendar.current.startOfDay(for: Date())
        return expiryDay >= today
    }
    
    
    

    func InsertSubscription_Recept(DateString:String,SubscriptionId:String,TransactionId:String) {
                
        KeychainService.removePassword(service: APPNAME, account: "UDID")
        
        
        CoreDataModel.sharedInstance.deleteAllData(CDPaymentdateAPI)
        CoreDataModel.sharedInstance.saveValidityDate(CDPaymentdateAPI, Enddate: DateString, TransactionId: TransactionId, StartDate: DateString, product_id: SubscriptionId)
        
        KeychainService.savePassword(service: APPNAME, account: "UDID", data: Udid)
        
        let ResultString = "\(DateString)--\(SubscriptionId)--\(TransactionId)"
        let value = ResultString.toBase64()
        let parameters:Dictionary<String, AnyObject> = ["dev_app_id": bundleID as AnyObject,
                                                         "dev_type": "2" as AnyObject,
                                                         "udid": Udid as AnyObject,
                                                         "receipt_data": value as AnyObject]
        
        NetworkManager.sharedInstance.SubscriptionInsertReceipt(urlString: SUBSCRIPTION_INSERT, params: parameters,  completion:
                { (resultDictionary, error) -> () in
                    if resultDictionary != nil {
                        DispatchQueue.main.async {
                            UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("Paid successfully", duration: 2.0, position: .top)
                        }
                        App_Protocol.delegateReader?.paymentStatus()
                        App_Protocol.DelegateSlideCard?.paymentStatus()
                    }
            })
    }
    
    
    func GetSubscription_Recept(DeviceUdid:String) {
        
        
        let dic:Dictionary<String, AnyObject> = ["dev_app_id": bundleID as AnyObject,
                                                                 "dev_type": "2" as AnyObject,
                                                                 "udid": DeviceUdid as AnyObject]
        NetworkManager.sharedInstance.SubscriptionGetReceipt(urlString: SUBSCRIPTION_GETRECREPT,params:dic,  completion:
                { (resultDictionary, error) -> () in
                    if resultDictionary != nil {
                                                
                        let data = resultDictionary!["data"] as! Dictionary<String, AnyObject>
                        let receiptdata = data["receiptdata"]! as! String
                        
                        let Result = receiptdata.fromBase64()?.components(separatedBy: "--")
                    
                        DispatchQueue.main.async {
                            CoreDataModel.sharedInstance.saveValidityDate(CDPaymentdateAPI, Enddate: Result![0], TransactionId: Result![2], StartDate: Result![0], product_id: Result![1])
                            
                            
                            
                            if self.storedSubscriptionIsActive() {
                                UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("Restored successfully!", duration: 2.0, position: .top)
                            } else {
                                UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("subscription expired", duration: 2.0, position: .top)
                            }
                            

                        }
                    }
            })
    }
    
    
    
    
    func Getpayment(completion:@escaping () -> ()) {
        verifyReceipt(url: API_VERIFY_RECEIPT, allowEnvironmentRetry: true, completion: completion)
    }

    /// Reads the latest plan from the receipt and does not save it.
    func peekLatestReceiptPlan(completion: @escaping (_ productId: String?, _ purchasedAt: Date?) -> Void) {
        peekReceipt(url: API_VERIFY_RECEIPT, allowEnvironmentRetry: true, completion: completion)
    }

    private func peekReceipt(url: String, allowEnvironmentRetry: Bool, completion: @escaping (_ productId: String?, _ purchasedAt: Date?) -> Void) {
        NetworkManager.sharedInstance.GetPay_History(url: url, completion: { (resultDictionary, error) -> () in
            let status = self.receiptStatus(resultDictionary)
            if allowEnvironmentRetry, status == 21007 || status == 21008 {
                let otherURL = status == 21007
                    ? "https://sandbox.itunes.apple.com/verifyReceipt"
                    : "https://buy.itunes.apple.com/verifyReceipt"
                self.peekReceipt(url: otherURL, allowEnvironmentRetry: false, completion: completion)
                return
            }
            var productId: String?
            var purchasedAt: Date?
            if let resultDictionary = resultDictionary, status == 0 {
                for item in self.receiptEntries(from: resultDictionary) {
                    guard let entitlement = self.entitlement(from: item) else { continue }
                    if purchasedAt == nil || entitlement.purchase > purchasedAt! {
                        purchasedAt = entitlement.purchase
                        productId = entitlement.productId
                    }
                }
            }
            DispatchQueue.main.async {
                completion(productId, purchasedAt)
            }
        })
    }

    private func verifyReceipt(url: String, allowEnvironmentRetry: Bool, completion: @escaping () -> ()) {
        NetworkManager.sharedInstance.GetPay_History(url: url, completion: { (resultDictionary, error) -> () in
            let status = self.receiptStatus(resultDictionary)
            if allowEnvironmentRetry, status == 21007 || status == 21008 {
                let otherURL = status == 21007
                    ? "https://sandbox.itunes.apple.com/verifyReceipt"
                    : "https://buy.itunes.apple.com/verifyReceipt"
                self.verifyReceipt(url: otherURL, allowEnvironmentRetry: false, completion: completion)
                return
            }
            if let resultDictionary = resultDictionary, status == 0 {
                self.applyVerifiedReceipt(resultDictionary)
            }
            let bought = self.fallbackProductId
            let saved = UserDefaults.standard.string(forKey: "PaymentId") ?? ""
            // A new buy must not keep an older plan from the receipt. Restore leaves fallback empty, so it still uses the receipt.
            if !bought.isEmpty && !saved.isEmpty && !self.isSamePurchasedPlan(saved, bought) {
                self.applyFallbackPurchaseIfNeeded()
            } else if !self.storedSubscriptionIsActive() {
                self.applyFallbackPurchaseIfNeeded()
            }
            self.fallbackProductId = ""
            self.fallbackTransactionId = ""
            completion()
        })
    }

    private func receiptStatus(_ result: Dictionary<String, AnyObject>?) -> Int {
        if let number = result?["status"] as? NSNumber {
            return number.intValue
        }
        if let number = result?["status"] as? Int {
            return number
        }
        return -1
    }

    /// Saves the latest purchase. An older lifetime purchase does not replace a newer plan.
    private func applyVerifiedReceipt(_ result: Dictionary<String, AnyObject>) {
        var latest: (purchase: Date, end: Date, productId: String, transactionId: String, lifetime: Bool)?
        var hasLifetime = false
        for item in receiptEntries(from: result) {
            guard let entitlement = entitlement(from: item) else { continue }
            if entitlement.lifetime {
                hasLifetime = true
            }
            if latest == nil || entitlement.purchase > latest!.purchase {
                latest = (entitlement.purchase, entitlement.date, entitlement.productId, entitlement.transactionId, entitlement.lifetime)
            }
        }
        UserDefaults.standard.set(hasLifetime, forKey: "HasLifetimePurchase")
        guard let best = latest else { return }
        self.product_id = best.productId
        self.TransactionId = best.transactionId
        self.StartDate = ""
        self.rememberExpiry(best.end)
        if best.lifetime {
            UserDefaults.standard.setValue(SUBSCRIPTIONID_LifeTime, forKey: "PaymentId")
        } else {
            UserDefaults.standard.setValue(best.productId, forKey: "PaymentId")
        }
        self.saveEndDAte()
        NotificationCenter.default.post(name: Notification.Name("ReloadTable"), object: nil)
    }

    private func receiptEntries(from result: Dictionary<String, AnyObject>) -> [[String: AnyObject]] {
        var entries = dictionaryEntries(result["latest_receipt_info"])
        if let receipt = result["receipt"] as? [String: AnyObject] {
            entries.append(contentsOf: dictionaryEntries(receipt["in_app"]))
        }
        return entries
    }

    private func dictionaryEntries(_ value: Any?) -> [[String: AnyObject]] {
        guard let list = value as? [Any] else { return [] }
        var entries: [[String: AnyObject]] = []
        for item in list {
            if let entry = item as? [String: AnyObject] {
                entries.append(entry)
            } else if let entry = item as? NSDictionary {
                var converted: [String: AnyObject] = [:]
                for (key, object) in entry {
                    if let key = key as? String {
                        converted[key] = object as AnyObject
                    }
                }
                entries.append(converted)
            }
        }
        return entries
    }

    private func entitlement(from item: [String: AnyObject]) -> (purchase: Date, date: Date, productId: String, transactionId: String, lifetime: Bool, fromAppleExpiry: Bool)? {
        if !item.stringValueForKey("cancellation_date_ms").isEmpty || !item.stringValueForKey("cancellation_date").isEmpty {
            return nil
        }
        let productId = item.stringValueForKey("product_id")
        guard !productId.isEmpty else { return nil }
        let transactionId = item.stringValueForKey("transaction_id")
        let bought = purchaseDate(from: item) ?? Date()
        let isLifetime = productId == SUBSCRIPTIONID_LifeTime || productId == SUBSCRIPTIONID_ExitOffer
        if isLifetime {
            let end = globalDate(byAddingDays: 36500, to: bought)
            return (bought, end, productId, transactionId, true, false)
        }
        if let end = globalPlanEnd(productId: productId, purchased: bought) {
            return (bought, end, productId, transactionId, false, false)
        }
        if let expiry = expiresDate(from: item) {
            return (bought, expiry, productId, transactionId, false, true)
        }
        return nil
    }

    /// 1 month is 30 days and 1 year is 365 days, measured from the purchase instant in GMT.
    private func globalPlanEnd(productId: String, purchased: Date) -> Date? {
        if isMonthlyPlan(productId) {
            return globalDate(byAddingDays: 30, to: purchased)
        }
        if isYearlyPlan(productId) {
            return globalDate(byAddingDays: 365, to: purchased)
        }
        return nil
    }

    private func isMonthlyPlan(_ productId: String) -> Bool {
        if !SUBSCRIPTIONID_Six_month.isEmpty && productId == SUBSCRIPTIONID_Six_month {
            return true
        }
        return productId == FallbackIAPConstants.oneMonthProductID
    }

    private func isYearlyPlan(_ productId: String) -> Bool {
        if !SUBSCRIPTIONID_OneYear.isEmpty && productId == SUBSCRIPTIONID_OneYear {
            return true
        }
        return productId == FallbackIAPConstants.oneYearProductID
    }

    /// Month, year, and lifetime stay distinct. Two ids of the same plan count as the same purchase.
    private func isSamePurchasedPlan(_ saved: String, _ bought: String) -> Bool {
        if saved == bought { return true }
        func kind(_ id: String) -> String {
            let lower = id.lowercased()
            if id == SUBSCRIPTIONID_LifeTime || id == SUBSCRIPTIONID_ExitOffer
                || id == FallbackIAPConstants.lifetimeProductID
                || id == FallbackIAPConstants.exitOfferProductID
                || lower.contains("lifetime") {
                return "lifetime"
            }
            if isYearlyPlan(id) || lower.contains("oneyear") || lower.contains("1year") {
                return "year"
            }
            if isMonthlyPlan(id) || lower.contains("onemonth") || lower.contains("sixmonth") || lower.contains("month") {
                return "month"
            }
            return id
        }
        return kind(saved) == kind(bought)
    }

    private func globalDate(byAddingDays days: Int, to date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.date(byAdding: .day, value: days, to: date) ?? date
    }

    private func expiresDate(from item: [String: AnyObject]) -> Date? {
        let milliseconds = item.stringValueForKey("expires_date_ms")
        if let value = Double(milliseconds), value > 0 {
            return Date(timeIntervalSince1970: value / 1000)
        }
        return appleDate(item.stringValueForKey("expires_date"))
    }

    private func purchaseDate(from item: [String: AnyObject]) -> Date? {
        let milliseconds = item.stringValueForKey("purchase_date_ms")
        if let value = Double(milliseconds), value > 0 {
            return Date(timeIntervalSince1970: value / 1000)
        }
        return appleDate(item.stringValueForKey("purchase_date"))
    }

    private func appleDate(_ text: String) -> Date? {
        guard !text.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Etc/GMT")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        if let date = formatter.date(from: text) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: text)
    }

    /// Days left until the App Store expiry, counted in GMT so the phone timezone cannot turn a 1-month plan into 0.
    func subscriptionDaysLeft() -> (days: Int, expiryText: String) {
        let expiry = expiryDateForDisplay()
        let text = PaymentHistory.gmtText(expiry)
        let seconds = expiry.timeIntervalSince(Date())
        if seconds <= 0 {
            return (0, text)
        }
        let days = Int(ceil(seconds / 86400.0))
        return (days, text)
    }

    private func rememberExpiry(_ date: Date) {
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "SubscriptionExpiryGMT")
        self.Enddate = PaymentHistory.gmtText(date)
    }

    private func expiryDateForDisplay() -> Date {
        let stamp = UserDefaults.standard.double(forKey: "SubscriptionExpiryGMT")
        if stamp > 0 {
            return Date(timeIntervalSince1970: stamp)
        }
        let stored = CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI)
        return PaymentHistory.dateFromGMTText(stored) ?? Date()
    }

    private static func gmtText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }

    private static func dateFromGMTText(_ text: String) -> Date? {
        guard !text.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.date(from: text)
    }

    private func applyFallbackPurchaseIfNeeded() {
        let productId = fallbackProductId
        guard !productId.isEmpty else { return }
        let start = Date()
        let end: Date
        let lifetime: Bool
        if productId == SUBSCRIPTIONID_LifeTime || productId == SUBSCRIPTIONID_ExitOffer {
            end = globalDate(byAddingDays: 36500, to: start)
            lifetime = true
        } else if let planEnd = globalPlanEnd(productId: productId, purchased: start) {
            end = planEnd
            lifetime = false
        } else {
            return
        }
        self.product_id = productId
        self.TransactionId = fallbackTransactionId
        self.rememberExpiry(end)
        UserDefaults.standard.setValue(lifetime ? SUBSCRIPTIONID_LifeTime : productId, forKey: "PaymentId")
        self.saveEndDAte()
    }
        
    func saveEndDAte() {
         CoreDataModel.sharedInstance.deleteAllData(CDPaymentdateAPI)
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: CDPaymentdateAPI, in: managedContext)
            let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                           
                    user.setValue(self.Enddate, forKey: "endDate")
                    user.setValue(self.TransactionId, forKey: "transactionId")
                    user.setValue(self.StartDate, forKey: "startDate")
                    user.setValue(self.product_id, forKey: "productId")
        
                   let parameters = ["udid":Udid,
                                     "dev_app_id":push_appid,
                                     "dev_type":dev_id_type,
                          "receipt_data": GetReceptKey.shared.ReceptId() ] as [String : AnyObject]
                    let savedPlan = "\(self.Enddate)--\(self.product_id)--\(self.TransactionId)"
                    let planParameters: Dictionary<String, AnyObject> = ["dev_app_id": bundleID as AnyObject,
                                                                         "dev_type": "2" as AnyObject,
                                                                         "udid": Udid as AnyObject,
                                                                         "receipt_data": savedPlan.toBase64() as AnyObject]
                    do {
                        try managedContext.save()
                        KeychainService.savePassword(service: APPNAME, account: "UDID", data: Udid)
                        NetworkManager.sharedInstance.requestPOSTTestData(urlString: SUBSCRIPTION_API,params:parameters,  completion:
                            { (resultDictionary, error) -> () in
                             
                            })
                        NetworkManager.sharedInstance.SubscriptionInsertReceipt(urlString: SUBSCRIPTION_INSERT, params: planParameters, completion: { _, _ in })
                } catch let error  as NSError {
                        print("Could not save: \(error),\(error.userInfo)")
            }
    }
    

    
    
}



