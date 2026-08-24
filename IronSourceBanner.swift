//
//  IronSourceBanner.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 30/01/24.
//

import UIKit
import IronSource


class IronSourceBanner: NSObject, ISInitializationDelegate, LevelPlayBannerDelegate {
   
    
   
    
     static let sharedInstance = IronSourceBanner()
    
    var ViewControl:UIViewController!
    var BannerSize: ISBannerSize = ISBannerSize(width: 198, andHeight: 198)
    var bannerHeight:Int = 200
    var bannerWidth:Int = 200
    
    //////////////////////////////////////////////////////////////////////////////////////////   Iron Source  Banner Ads   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
    // MARK: Banner Delegates
        
    func AdBannerSize() -> ISBannerSize {
        self.BannerSize = ISBannerSize(width: bannerWidth, andHeight: bannerHeight)
        return self.BannerSize
    }
    
    
    func  IronSource_Banner_AdLoad(bannerWidth:Int,bannerHeight:Int) {
        IronSource.setLevelPlayBannerDelegate(self)
        self.bannerWidth = bannerWidth
        self.bannerHeight = bannerHeight
//        IronSource.setBannerDelegate(self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, delegate: self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, adUnits:[IS_BANNER])
    }
    
    func bannerDidLoad(_ bannerView: ISBannerView!) {
        
        let keyWindow = UIApplication.shared.connectedScenes
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        
            guard let window = keyWindow else { return }
        
        
        switch window.rootViewController?.children.last {
        case is Ad_ToastController:
            let jdv = window.rootViewController?.children.last as! Ad_ToastController
            jdv.AdView.addSubview(bannerView)
            break
                        
        case is SharedViewController:
            let jdv = window.rootViewController?.children.last as! SharedViewController
            jdv.BannerView.addSubview(bannerView)
            break
            
        case is ShareViewController:
            let jdv = window.rootViewController?.children.last as! ShareViewController
            jdv.ADView.addSubview(bannerView)
            break
            
        case is QuizMainPageVC:
            let jdv = window.rootViewController?.children.last as! QuizMainPageVC
            jdv.AdsView.addSubview(bannerView)
            break
            
        case is QuizAlertVC:
            let jdv = window.rootViewController?.children.last as! QuizAlertVC
            jdv.AdBannerView.addSubview(bannerView)
            break
            
        case is ReaderSourceViewController:
            let jdv = window.rootViewController?.children.last as! ReaderSourceViewController
            jdv.ADView.addSubview(bannerView)
            break
            
            
            
        default:
            break
        }
    }
 
    func bannerDidFailToLoadWithError(_ error: Error!) {
        
        let keyWindow = UIApplication.shared.connectedScenes
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        
             guard let window = keyWindow else { return }
        
        
        switch window.rootViewController?.children.last {
        case is ShareViewController:
            let jdv = window.rootViewController?.children.last as! ShareViewController
            jdv.ADLine.isHidden = true
            break
            
        default:
            break
        }
    }
    
    
    
    func didLoad(_ bannerView: ISBannerView!, with adInfo: ISAdInfo!) {
        print("did Load")
    }
    
    func didLeaveApplication(with adInfo: ISAdInfo!) {
        print("did Leave Application")
    }
    
    func didPresentScreen(with adInfo: ISAdInfo!) {
        print("did Present Screen")
    }
    
    func didDismissScreen(with adInfo: ISAdInfo!) {
        print("did Dismiss Screen")
    }
    
    func didFailToLoadWithError(_ error: Error!) {
        print("did Fail To Load With Error")
    }
    
    func didClick(with adInfo: ISAdInfo!) {
        print("did Click")
    }
    
    
    func initializationDidComplete() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            IronSource.loadBanner(with: self.ViewControl, size: self.AdBannerSize())
            self.AdBannerSize().isAdaptive = true
        }
    }
    
    
    
}
