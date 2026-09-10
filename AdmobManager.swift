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
    /// When true, show rewarded as soon as an ad becomes available.
    private var pendingRewardedShow = false
    private var pendingRewardedPollTimer: Timer?
    private var pendingRewardedAttempts = 0

     
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
        // Availability callback means a rewarded ad is ready — show if Skip/reward was waiting.
        tryShowPendingRewardedIfPossible()
    }
    
    func hasNoAvailableAd() {
        // Do NOT clear pending here. IronSource reports "no ad" while a load is in progress;
        // cancelling immediately made Gift Card Skip always fail. Timeout poll handles final fail.
        print("has No Available Ad (ignored while pending=\(pendingRewardedShow))")
    }
    
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        clearPendingRewardedShow()
        
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
        vc = vw
        // Ready → show now. Not ready → keep intent, load, poll until ready or timeout.
        if IronSource.hasRewardedVideo() {
            clearPendingRewardedShow()
            DispatchQueue.main.async {
                IronSource.showRewardedVideo(with: vw)
            }
        } else {
            pendingRewardedShow = true
            pendingRewardedAttempts = 0
            IronSource_Reward_AdLoad()
            startPendingRewardedPoll()
        }
    }
    
    private func tryShowPendingRewardedIfPossible() {
        guard pendingRewardedShow, let host = vc else { return }
        guard IronSource.hasRewardedVideo() else { return }
        clearPendingRewardedShow()
        DispatchQueue.main.async {
            IronSource.showRewardedVideo(with: host)
        }
    }
    
    private func startPendingRewardedPoll() {
        pendingRewardedPollTimer?.invalidate()
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard self.pendingRewardedShow else {
                self.clearPendingRewardedShow()
                return
            }
            self.pendingRewardedAttempts += 1
            if IronSource.hasRewardedVideo() {
                self.tryShowPendingRewardedIfPossible()
                return
            }
            // Re-kick load every ~3s while waiting.
            if self.pendingRewardedAttempts % 6 == 0 {
                self.IronSource_Reward_AdLoad()
            }
            // Give up after ~15 seconds.
            if self.pendingRewardedAttempts >= 30 {
                self.clearPendingRewardedShow()
                DispatchQueue.main.async {
                    (UIApplication.shared.keyWindow?.rootViewController)?.view.makeToast("Ad not Available", duration: 2.0, position: .bottom)
                    self.notifyRewardedAdNotAvailable()
                }
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        pendingRewardedPollTimer = timer
    }
    
    private func clearPendingRewardedShow() {
        pendingRewardedShow = false
        pendingRewardedAttempts = 0
        pendingRewardedPollTimer?.invalidate()
        pendingRewardedPollTimer = nil
    }
    
    private func notifyRewardedAdNotAvailable() {
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
    }
    
        
    
   
        
}













