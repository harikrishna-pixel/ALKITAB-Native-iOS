//
//  AppConstrains.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 23/01/23.
//

import UIKit


var FrameConstrains:CGFloat = 80.0
var HeadPhoneRadius:CGFloat = 30.0
var BookCatagorytxtSize:CGFloat = 22.0
var PlayerSuvViewConstrain:CGFloat = 45.0

var isIpad:Bool = true





// MARK: App Constrains Class

class AppConstrains: NSObject {
    
    public static let shared = AppConstrains()
    
    func Constrains() {
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            FrameConstrains = 80.0
            HeadPhoneRadius = 30.0
            BookCatagorytxtSize = 20.0
            PlayerSuvViewConstrain = 45.0
            isIpad = true
            kStoryboardMainIphone = UIStoryboard(name: "MainIpad", bundle: nil)
        } else {
            HeadPhoneRadius = 25.0
            BookCatagorytxtSize = 15.0
            PlayerSuvViewConstrain = 25.0
            
            isIpad = false
            FrameConstrains = (StatusbarHeight > 30.0 ? 90.0:70.0)
            kStoryboardMainIphone = UIStoryboard(name: "Main", bundle: nil)
        }
    }
}
