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
        showPurchasedToast()
    }

    /// Shown on the window, so it stays visible when the paywall closes or the next screen opens.
    func showPurchasedToast() {
        DispatchQueue.main.async {
            let windows = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
            let window = windows.first(where: { $0.isKeyWindow }) ?? windows.first
            window?.makeToast("Purchased Successfully", duration: 2.0, position: .top)
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
