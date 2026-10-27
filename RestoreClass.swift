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
    
    
    
    func paidResult(productID: String, transId: String, showToast: Bool = true) {
        PaymentHistory.sharedInstance.fallbackProductId = productID
        PaymentHistory.sharedInstance.fallbackTransactionId = transId
        guard showToast else { return }
        DispatchQueue.main.async {
            self.SourceVC?.view.makeToast("Purchased Successfully", duration: 2.0, position: .top)
        }
    }
    
    func restoreData(NavigateStatus:Bool = true) {
        let DeviceUdid = KeychainService.loadPassword(service: APPNAME, account: "UDID")
        
        if DeviceUdid == nil || DeviceUdid == "" {
            SourceVC.view.makeToast("User Does not exist", duration: 2.0, position: .top)
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
