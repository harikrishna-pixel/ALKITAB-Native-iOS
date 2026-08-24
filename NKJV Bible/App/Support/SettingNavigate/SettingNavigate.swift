//
//  SettingNavigate.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 22/05/21.
//

import UIKit

class SettingNavigate: NSObject {
    static let sharedInstance = SettingNavigate()
     
    func settingsNavigate() {
        
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    
    
   
    
    
}
