//
//  OpenVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 07/07/23.
//

import UIKit

class OpenVC: NSObject {
    
    
    static let shared = OpenVC()
    
    
    
    func OpenInterstitialAd(presentViewcontroll:UIViewController) {
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "NewAdViewController") as! NewAdViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        presentViewcontroll.present(vc, animated: true, completion: nil)
     }
    
    
}
