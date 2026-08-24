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
    
    
    var Appdate: Array<String> = []
    
    
    func paymentInfo() -> Bool {
        var date = CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI)
                if date == "" {
                    date = Date().string(format: "dd-MM-yyyy")
                }
                let showDate1 = GetReceptKey.shared.convertData(date: date)
        
        
           if showDate1.isGreaterThan(Date()) || (IS_SUBSCRIPTION_ENABLE == 1 && SUBSCRIPTIONID_LifeTime != "" && UserDefaults.standard.string(forKey: "PaymentId") ?? "" == SUBSCRIPTIONID_LifeTime) || ADS_TYPE == 0 {
               return false
            } else {
                return true
            }
    }
    
    
    func paymentInfoVerify() -> Bool {
        var date = CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI)
                if date == "" {
                    date = Date().string(format: "dd-MM-yyyy")
                }
                let showDate1 = GetReceptKey.shared.convertData(date: date)
            
           if showDate1.isGreaterThan(Date()) || (IS_SUBSCRIPTION_ENABLE == 1 && SUBSCRIPTIONID_LifeTime != "" && UserDefaults.standard.string(forKey: "PaymentId") ?? "" == SUBSCRIPTIONID_LifeTime) {
               return false
            } else {
                return true
            }
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
                            UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("Paid successfully", duration: 2.0, position: .bottom)
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
                            
                            
                            
                            var date = CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI)
                            let showDate1 = GetReceptKey.shared.convertData(date: date)
                            
                            
                            if showDate1.isGreaterThan(Date()) {
                                UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("Restored successfully!", duration: 2.0, position: .bottom)
                            } else {
                                UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("subscription expired", duration: 2.0, position: .bottom)
                            }
                            

                        }
                    }
            })
    }
    
    
    
    
    func Getpayment(completion:@escaping () -> ()) {
        NetworkManager.sharedInstance.GetPay_History(url: API_VERIFY_RECEIPT, completion:{ (resultDictionary, error) -> () in
                        
            
            if resultDictionary != nil {
                if resultDictionary!.count > 3 {
                    self.product_id.removeAll()
                    self.Appdate.removeAll()
                    var product:[String] = []
                    if resultDictionary != nil  {
                          self.WholeList = resultDictionary?["receipt"] as! Dictionary<String, AnyObject>
                          self.PayList = self.WholeList["in_app"] as! Array<NSDictionary>
                                        
                        for i in 0..<self.PayList.count {
                            let dic = self.PayList[i] as! Dictionary<String, AnyObject>
                            let purchacedate = dic.stringValueForKey("original_purchase_date").components(separatedBy: " ")
                            
                            self.product_id = dic.stringValueForKey("product_id")
                            
                            // BUG FIX: Save PaymentId for all product types, not just lifetime
                            if dic.stringValueForKey("product_id") == SUBSCRIPTIONID_LifeTime || dic.stringValueForKey("product_id") == SUBSCRIPTIONID_ExitOffer {
                                // Both lifetime and exit offer are treated as lifetime
                                UserDefaults.standard.setValue(SUBSCRIPTIONID_LifeTime, forKey: "PaymentId")
                            } else if dic.stringValueForKey("product_id") == SUBSCRIPTIONID_OneYear {
                                UserDefaults.standard.setValue(SUBSCRIPTIONID_OneYear, forKey: "PaymentId")
                            } else if dic.stringValueForKey("product_id") == SUBSCRIPTIONID_Six_month {
                                UserDefaults.standard.setValue(SUBSCRIPTIONID_Six_month, forKey: "PaymentId")
                            }
                            
                            self.TransactionId = dic.stringValueForKey("original_transaction_id")
                            self.StartDate = dic.stringValueForKey("original_purchase_date")
                            product.append(self.product_id)
                            self.Appdate.append(purchacedate[0])
                          }
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        let DicTionaryArray = self.PayList.sorted(by: { dateFormatter.date(from:($0 as! Dictionary<String, AnyObject>).stringValueForKey("original_purchase_date").components(separatedBy: " ")[0])!.compare(dateFormatter.date(from:($1 as! Dictionary<String, AnyObject>).stringValueForKey("original_purchase_date").components(separatedBy: " ")[0])!) == .orderedDescending })
                        

//                        self.DateOrder(DateArray: self.Appdate)
                        self.DateOrder(DicArray: DicTionaryArray)
                        completion()
                    }
                } else {
                    completion()
                }
            } else {
                completion()
            }
            
        })
    }
        
    func DateConvert(dateString:String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        return date!
    }
    

//    func DateOrder(DateArray:Array<String>) {
        func DateOrder(DicArray:[NSDictionary]) {
            
            let Dic = DicArray[0]  as! Dictionary<String, AnyObject>
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
            
            
            let Current_Date = Dic.stringValueForKey("original_purchase_date").components(separatedBy: " ")
            self.product_id = Dic.stringValueForKey("product_id")
            
        if self.product_id == SUBSCRIPTIONID_Six_month {
            let next1Year = Calendar.current.date(byAdding: .day, value: 180, to: self.DateConvert(dateString: Current_Date[0]))
            self.Enddate = next1Year!.string(format: "dd-MM-yyyy")
        } else if self.product_id == SUBSCRIPTIONID_OneYear {
            let next1Year = Calendar.current.date(byAdding: .day, value: 365, to: self.DateConvert(dateString: Current_Date[0]))
            self.Enddate = next1Year!.string(format: "dd-MM-yyyy")
        } else if self.product_id == SUBSCRIPTIONID_LifeTime || self.product_id == SUBSCRIPTIONID_ExitOffer {
            // BUG FIX: Handle lifetime purchase (including exit offer) - set to 100 years in the future
            let lifetimeDate = Calendar.current.date(byAdding: .year, value: 100, to: self.DateConvert(dateString: Current_Date[0]))
            self.Enddate = lifetimeDate!.string(format: "dd-MM-yyyy")
            // Save PaymentId for lifetime purchase (use SUBSCRIPTIONID_LifeTime for both)
            UserDefaults.standard.setValue(SUBSCRIPTIONID_LifeTime, forKey: "PaymentId")
        } else {
            // Fallback for any other subscription type - treat as yearly
            let next1Year = Calendar.current.date(byAdding: .day, value: 365, to: self.DateConvert(dateString: Current_Date[0]))
            self.Enddate = next1Year!.string(format: "dd-MM-yyyy")
        }
        self.saveEndDAte()
        NotificationCenter.default.post(name: Notification.Name("ReloadTable"), object: nil)
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
                    do {
                        try managedContext.save()
                        NetworkManager.sharedInstance.requestPOSTTestData(urlString: SUBSCRIPTION_API,params:parameters,  completion:
                            { (resultDictionary, error) -> () in
                             
                            })
                } catch let error  as NSError {
                        print("Could not save: \(error),\(error.userInfo)")
            }
    }
    

    
    
}



