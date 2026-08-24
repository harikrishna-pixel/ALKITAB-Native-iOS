//
//  SendMail.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 29/12/22.
//

import UIKit
import MessageUI

class SendMail: NSObject, MFMailComposeViewControllerDelegate {
    
    
    static let shared = SendMail()
    
    // MARK:- send email Delegate
    
    func sendEmailToUsers(presentViewcontroll:UIViewController) {
        
        if MFMailComposeViewController.canSendMail()
         {
           let composeVC = MFMailComposeViewController()
           composeVC.mailComposeDelegate = self
           composeVC.setToRecipients([FEEDBACKMAIL])
           composeVC.setSubject("App feedback")
           composeVC.setMessageBody("", isHTML: false)
            presentViewcontroll.present(composeVC, animated: true, completion: nil)
        } else {
            presentViewcontroll.view.makeToast(NSLocalizedString("Please Login your email id", comment: ""), duration: 1.0, position: .bottom)
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    

    
    func FeedbackNavigation(presentViewcontroll:UIViewController) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            presentViewcontroll.navigationController?.pushViewController(vc, animated: true)
        } else {
            presentViewcontroll.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
     }
    
    
    
}
