//
//  SettingAlert.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 23/08/23.
//

import UIKit

class SettingAlert: NSObject {
    
    

    static func GallaryPermission(SorceVc:UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "No permission to access Gallery. Please go to app settings to allow permission", message: "To display your saved verse images and wallpapers, this app needs access to your photo library. \n You can enable access anytime in Settings" , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
                }))
                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler:{ (UIAlertAction)in
                    SettingNavigate.sharedInstance.settingsNavigate()
                }))
            
            alert.popoverPresentationController?.sourceView = SorceVc.view
            SorceVc.present(alert, animated: true, completion: {
                })
        }
        
    }
    
    
}
