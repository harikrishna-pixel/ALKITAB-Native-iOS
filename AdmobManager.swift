//
//  AdmobManager.swift
//  WhtasWeb
//
//  Created by CATALINA on 11/09/20.
//  Copyright © 2020 MehulKathiriya. All rights reserved.
//

import Foundation
import IronSource
 
class AdmobManager : NSObject {
   

    static let shared = AdmobManager()
    
    var vc : UIViewController?
    var RewardAd = ""
    var Interstitial_ID = ""
    /// When true, show interstitial as soon as the next `didLoad` arrives.
    private var pendingInterstitialShow = false

     
}
    



//  MARK: Interstitial Ad

extension AdmobManager: LevelPlayInterstitialDelegate {
    
    func IronSource_Interstitial_AdLoad() {
        IronSource.setLevelPlayInterstitialDelegate(self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, delegate: self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, adUnits:[IS_INTERSTITIAL])
        DispatchQueue.main.async {
            IronSource.loadInterstitial()
        }
    }
    
    
    func IronSource_Interstitial_ShowAds(vw : UIViewController, waitForLoadIfNeeded: Bool = false) {
        vc = vw
        if IronSource.hasInterstitial() {
            pendingInterstitialShow = false
            DispatchQueue.main.async {
                IronSource.showInterstitial(with: vw)
            }
        } else if waitForLoadIfNeeded {
            // Verse Image 20/30…: wait for load, then show — no Loading VC.
            pendingInterstitialShow = true
            IronSource_Interstitial_AdLoad()
        } else {
            pendingInterstitialShow = false
            IronSource_Interstitial_AdLoad()
        }
    }
    
    func didLoad(with adInfo: ISAdInfo!) {
        print("interstitial Did Load ")
        guard pendingInterstitialShow, let host = vc, IronSource.hasInterstitial() else { return }
        pendingInterstitialShow = false
        DispatchQueue.main.async {
            IronSource.showInterstitial(with: host)
        }
    }
    
    func didFailToLoadWithError(_ error: Error!) {
        pendingInterstitialShow = false
        var dispatchAfter = DispatchTimeInterval.seconds(ADS_DURATION*60)
        
        if RewardAd == "Tryagain" {
            QuizProtocol.ResultProtocoldelegate?.AdNotAvailable()
        } else if RewardAd == "FreeCoins" {
            QuizProtocol.WalletProtocoldelegate?.AdNotAvailable()
        } else if RewardAd == "MainFreeCoins" {
            QuizProtocol.QuizMaindelegate?.AdNotAvailable()
        } else if RewardAd == "WatchAd" {
           App_Protocol.UnituAdCallDelegate?.NoAdClosed()
        } else if RewardAd == "Scratch" {
            QuizProtocol.CardDelegate?.AdNotAvailable()
        } else if RewardAd == "ImageWatermark" {
            ImageAppProtocol.ImageTxtEditDelegate?.AdNotAvailable()
        } else if RewardAd == "OpenCard" {
            App_Protocol.CardShowdelegate?.AdNotAvailable()
            RewardAd = ""
        } else if RewardAd == "SubscrbViewController" {
            App_Protocol.UnituAdCallDelegate?.NoAdClosed()
        }
            
        
        
        if Interstitial_ID == "OpenSplash" {
            App_Protocol.DelegateSplash?.OpenAd()
            Interstitial_ID = ""
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+dispatchAfter) {
            self.IronSource_Reward_AdLoad()
        }
        
    }
    
    
    func didOpen(with adInfo: ISAdInfo!) {
        print("Ad opened")
    }
    
    func didShow(with adInfo: ISAdInfo!) {
        print("Ad showing")
    }
    
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: ISAdInfo!) {
        pendingInterstitialShow = false
        // Reload promptly so Verse Image 20/30… can show again.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.IronSource_Interstitial_AdLoad()
        }
        
        if RewardAd == "Tryagain" {
            QuizProtocol.ResultProtocoldelegate?.AdNotAvailable()
        } else if RewardAd == "FreeCoins" {
            QuizProtocol.WalletProtocoldelegate?.AdNotAvailable()
        } else if RewardAd == "MainFreeCoins" {
            QuizProtocol.QuizMaindelegate?.AdNotAvailable()
        } else if RewardAd == "WatchAd" {
           App_Protocol.UnituAdCallDelegate?.NoAdClosed()
        } else if RewardAd == "Scratch" {
            QuizProtocol.CardDelegate?.AdNotAvailable()
        } else if RewardAd == "ImageWatermark" {
            ImageAppProtocol.ImageTxtEditDelegate?.AdNotAvailable()
        } else if RewardAd == "OpenCard" {
            App_Protocol.CardShowdelegate?.AdNotAvailable()
            RewardAd = ""
        } else if RewardAd == "SubscrbViewController" {
            App_Protocol.UnituAdCallDelegate?.NoAdClosed()
        }
        
        if Interstitial_ID == "OpenSplash" {
            App_Protocol.DelegateSplash?.OpenAd()
            Interstitial_ID = ""
        }
        var dispatchAfter = DispatchTimeInterval.seconds(ADS_DURATION*60)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+dispatchAfter) {
            self.IronSource_Reward_AdLoad()
        }
        
    }
    
    func didClick(with adInfo: ISAdInfo!) {
        print("did Click ")
    }
    
    func didClose(with adInfo: ISAdInfo!) {
        
        pendingInterstitialShow = false
        
        if Interstitial_ID == "OpenSplash" {
            App_Protocol.DelegateSplash?.OpenAd()
            Interstitial_ID = ""
        }
        
        // Reload immediately so the next 10th/20th/30th Verse Image trigger has an ad ready.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.IronSource_Interstitial_AdLoad()
        }
        
    }
    
}





//  MARK: Reward Ad

extension AdmobManager: ISInitializationDelegate, LevelPlayRewardedVideoDelegate  {
    
    func initializationDidComplete() {
        print("initialization Did Complete")
    }
    
     
    
    func IronSource_Reward_AdLoad() { 
        IronSource.setLevelPlayRewardedVideoDelegate(self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, delegate: self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, adUnits:[IS_REWARDED_VIDEO])
        DispatchQueue.main.async {
            IronSource.loadRewardedVideo()
        }
    }
    
    
    
    func hasAvailableAd(with adInfo: ISAdInfo!) {
        print("has Available Ad")
    }
    
    func hasNoAvailableAd() {        
        if RewardAd != "" {
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Ad not Available", duration: 2.0, position: .bottom)
        }
    }
    
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        
        if RewardAd == "OpenCard" {
            UserDefaults.standard.setValue(Date().string(format: "MM/dd/yy HH:mm:ss"), forKey: "CardAdTime")
        }
        
        if RewardAd == "Tryagain" {
            QuizProtocol.ResultProtocoldelegate?.NavigateBack()
        } else if RewardAd == "FreeCoins" {
            QuizProtocol.WalletProtocoldelegate?.CollectCoin()
        } else if RewardAd == "MainFreeCoins" {
            QuizProtocol.QuizMaindelegate?.CollectCoin()
        } else if RewardAd == "WatchAd" {
            App_Protocol.UnituAdCallDelegate?.AdDidClosed()
        } else if RewardAd == "Scratch" {
            QuizProtocol.CardDelegate?.CollectCoin()
        } else if RewardAd == "ImageWatermark" {
            ImageAppProtocol.ImageTxtEditDelegate?.CollectCoin()
        } else if RewardAd == "OpenCard" {
            App_Protocol.CardShowdelegate?.cardNavigate()
        } else if RewardAd == "SubscrbViewController" {
            App_Protocol.UnituAdCallDelegate?.AdDidClosed()
        }
        
        
        self.IronSource_Reward_AdLoad()
    }
    
    func didClick(_ placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        print("Ad Clicked")
    }

    
    
    

    func IronSource_Reward_ShowAds(vw : UIViewController, RewardAd:String) {
        self.RewardAd = RewardAd
        if IronSource.hasInterstitial() {
            DispatchQueue.main.async {
                IronSource.showRewardedVideo(with: vw)
            }
        } else {
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Ad not Available", duration: 2.0, position: .bottom)
            
            if self.RewardAd == "Tryagain" {
                QuizProtocol.ResultProtocoldelegate?.AdNotAvailable()
            } else if self.RewardAd == "FreeCoins" {
                QuizProtocol.WalletProtocoldelegate?.AdNotAvailable()
            } else if self.RewardAd == "MainFreeCoins" {
                QuizProtocol.QuizMaindelegate?.AdNotAvailable()
            } else if self.RewardAd == "WatchAd" {
               App_Protocol.UnituAdCallDelegate?.NoAdClosed()
            } else if self.RewardAd == "Scratch" {
                QuizProtocol.CardDelegate?.AdNotAvailable()
            } else if self.RewardAd == "ImageWatermark" {
                ImageAppProtocol.ImageTxtEditDelegate?.AdNotAvailable()
            } else if self.RewardAd == "OpenCard" {
                App_Protocol.CardShowdelegate?.AdNotAvailable()
                self.RewardAd = ""
            } else if self.RewardAd == "SubscrbViewController" {
                App_Protocol.UnituAdCallDelegate?.NoAdClosed()
            }
            
        }
    }
    
        
    
   
        
}













