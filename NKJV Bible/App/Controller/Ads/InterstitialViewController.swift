//
//  InterstitialViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 07/01/23.
//

import UIKit
import IronSource

class InterstitialViewController: UIViewController, LevelPlayInterstitialDelegate, LevelPlayRewardedVideoDelegate {


    
    

    
    
    @IBOutlet weak var Loader: UIActivityIndicatorView!
    var testmode:Bool = false
    
    
    func CloseVc() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////    rewarded Ad    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    

    var imageView:UIImageView!
    var LoadAdCatagory = ""
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch LoadAdCatagory {
        case "INTERSTITIAL":
            self.IronSource_Interstitial_AdLoad()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) {
                self.IronSource_Interstitial_ShowAds()
            }
            break
        case "REWARDED":
            self.IronSource_Reward_AdLoad()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) {
                self.IronSource_Reward_ShowAds()
            }
            break
        default:
            self.IronSource_Interstitial_AdLoad()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                self.IronSource_Interstitial_ShowAds()
            }
            
          break
        }
    }
    

    



}







extension  InterstitialViewController: ISInitializationDelegate  {
    func initializationDidComplete() {
        
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////    Iron Source    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////   Iron Source  Interstitial Ads   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func IronSource_Interstitial_AdLoad() {
        IronSource.setLevelPlayInterstitialDelegate(self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, delegate: self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, adUnits:[IS_INTERSTITIAL])
        DispatchQueue.main.async {
            IronSource.loadInterstitial()
        }
    }
    
    
    
    func IronSource_Interstitial_ShowAds() {
        if IronSource.hasInterstitial() {
            DispatchQueue.main.async {
                IronSource.showInterstitial(with: self)
            }
        } else {
            print("Print No ads")
            self.CloseVc()
        }
    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////   Iron Source  reward Ads   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
    
    func IronSource_Reward_AdLoad() {
        
        IronSource.setLevelPlayRewardedVideoDelegate(self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, delegate: self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, adUnits:[IS_INTERSTITIAL])
        DispatchQueue.main.async {
            IronSource.loadRewardedVideo()
        }
    }
    
    
    
    func IronSource_Reward_ShowAds() {
        if IronSource.hasInterstitial() {
            DispatchQueue.main.async {
                IronSource.showRewardedVideo(with: self)
            }
        } else {
            print("Print No ads")
            self.CloseVc()
        }
    }
    
    
}





extension InterstitialViewController  {
    
    func didLoad(with adInfo: ISAdInfo!) {
        print("did Load")
    }
    
    func didFailToLoadWithError(_ error: Error!) {
        print("did Fail To Load With Error")
    }
    
    func didOpen(with adInfo: ISAdInfo!) {
        print("did Open")
    }
    
    func didShow(with adInfo: ISAdInfo!) {
        print("did Show")
    }
    
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: ISAdInfo!) {
        print("did Fail To Show With Error")
    }
    
    func didClick(with adInfo: ISAdInfo!) {
        print("did Click")
    }
    
    func didClose(with adInfo: ISAdInfo!) {
        print("did Close")
    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////   Iron Source  reward Ads    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func rewardedVideoHasChangedAvailability(_ available: Bool) {
        
    }
 
    
    func rewardedVideoDidFailToShowWithError(_ error: Error!) {
        
    }
    
    func rewardedVideoDidOpen() {
        
    }
    
    func rewardedVideoDidClose() {
        self.CloseVc()
    }
    
    
    
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        CoreDataModel.sharedInstance.deleteAllData(CDPaymentdateAPI)
        CoreDataModel.sharedInstance.coreDataInsertEndDate(CDPaymentdateAPI, endDate: Date.tomorrow.string(format: "dd-MM-yyyy"))
    }
    
    func didClick(_ placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        print("did Click ")
    }
    
    
    func hasAvailableAd(with adInfo: ISAdInfo!) {
        print("has Available Ad")
    }
    
    func hasNoAvailableAd() {
        print("has No Available Ad")
    }
    

        
}

