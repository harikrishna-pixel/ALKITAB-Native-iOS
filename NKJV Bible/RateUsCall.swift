//
//  RateUsCall.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 29/05/23.
//

import UIKit

class RateUsCall: NSObject {
    static let shared = RateUsCall()
    
    func ClickCount() {
        
        if UserDefaults.standard.integer(forKey: "OpenRate") < 45 {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "OpenRate")+1, forKey: "OpenRate")
        }
        
        if UserDefaults.standard.integer(forKey: "OpenRate") == 21 {
            App_Protocol.delegateReader?.CallRate(RateContent: "Rate Your Happiness, \nLet it Shine Bright!")
        } else if UserDefaults.standard.integer(forKey: "OpenRate") == 41 {
            App_Protocol.delegateReader?.CallRate(RateContent: "Love this app? \nYour satisfaction is our priority, \nTell us how we're doing!")
        }
        
    }
}

      
