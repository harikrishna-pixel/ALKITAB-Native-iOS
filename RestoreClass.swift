//
//  RestoreClass.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 25/11/23.
//

import UIKit





class RestoreClass: NSObject {
    
static let shared = RestoreClass()
    
    var SourceVC:UIViewController!
    
    
    
    func paidResult(productID: String, transId: String) {
        
        var transDate: String = ""
        if productID == SUBSCRIPTIONID_Six_month {
            transDate = Date().sixmonthAfter.string(format: "dd-MM-yyyy")
        } else if productID == SUBSCRIPTIONID_OneYear {
            transDate = Date().oneYearAfter.string(format: "dd-MM-yyyy")
        } else if productID == SUBSCRIPTIONID_LifeTime || productID == SUBSCRIPTIONID_ExitOffer {
            // BUG FIX: Lifetime purchase (including exit offer) needs a far future date to work properly
            // Set to 100 years in the future to effectively make it "lifetime"
            let calendar = Calendar.current
            if let futureDate = calendar.date(byAdding: .year, value: 100, to: Date()) {
                transDate = futureDate.string(format: "dd-MM-yyyy")
            } else {
                transDate = Date().oneYearAfter.string(format: "dd-MM-yyyy") // Fallback
            }
            // Save PaymentId for lifetime purchase (use SUBSCRIPTIONID_LifeTime for both)
            UserDefaults.standard.setValue(SUBSCRIPTIONID_LifeTime, forKey: "PaymentId")
        } else {
            transDate = ""
        }
        
        
        PaymentHistory.sharedInstance.InsertSubscription_Recept(DateString: transDate, SubscriptionId: productID, TransactionId: transId)
         
        DispatchQueue.main.async {
            self.SourceVC.view.makeToast("Paid Succesfully!", duration: 2.0, position: .bottom)
        }
        
        
    }
    
    func restoreData(NavigateStatus:Bool = true) {
        let DeviceUdid = KeychainService.loadPassword(service: APPNAME, account: "UDID")
        
        if DeviceUdid == nil || DeviceUdid == "" {
            SourceVC.view.makeToast("User Does not exist", duration: 2.0, position: .bottom)
        } else {
            PaymentHistory.sharedInstance.GetSubscription_Recept(DeviceUdid: DeviceUdid!)
            App_Protocol.delegateReader?.paymentStatus()
            App_Protocol.DelegateSlideCard?.paymentStatus()
            DispatchQueue.main.async {
                if NavigateStatus {
                    self.SourceVC.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
}
