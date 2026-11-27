//
//  AdmobManager.swift
//  WhtasWeb
//
//  Created by CATALINA on 11/09/20.
//  Copyright © 2020 MehulKathiriya. All rights reserved.
//

import Foundation
import IronSource
import Toast_Swift
 
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
    /// Max poll ticks (0.5s each). Rewarded taps fail over in ~5s if still empty.
    private var pendingRewardedMaxAttempts = 10
    /// Avoid back-to-back interstitials (e.g. verse action then Mark as Read).
    private var lastInterstitialShownAt: TimeInterval = 0
    private let interstitialMinInterval: TimeInterval = 180

    /// Call when the user is inside the main app. Warms IronSource rewarded + interstitial if empty.
    /// If IronSource key is missing, warm Google AdMob instead.
    func prepareAdsForAppSession() {
        if ADS_DISABLED_FOR_TESTING { return }
        let key = IRONSOURCE_KEY.trimmingCharacters(in: .whitespacesAndNewlines)
        if key.isEmpty {
            GoogleMobileAdsSupport.shared.startIfNeeded()
            return
        }
        GoogleMobileAdsSupport.shared.startIfNeeded()
        if !IronSource.hasRewardedVideo() {
            IronSource_Reward_AdLoad()
        }
        if !IronSource.hasInterstitial() {
            IronSource_Interstitial_AdLoad()
        }
    }

    private var ironSourceKeyReady: Bool {
        !IRONSOURCE_KEY.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Deliver the same reward callbacks used by IronSource `didReceiveReward`.
    fileprivate func deliverRewardedSuccess() {
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
        } else if RewardAd == "PaywallTrigger" {
            PaywallTriggerReward.deliver()
        }
    }

    /// Try AdMob rewarded when IronSource has no fill. Returns true if AdMob presentation started.
    fileprivate func tryShowAdMobRewardedFallback() -> Bool {
        guard GoogleMobileAdsSupport.shared.hasUsableAdMobIds, let host = vc else { return false }
        return GoogleMobileAdsSupport.shared.showRewarded(from: host, onReward: { [weak self] in
            self?.deliverRewardedSuccess()
            if self?.ironSourceKeyReady == true {
                self?.IronSource_Reward_AdLoad()
            }
        })
    }

    fileprivate func tryShowAdMobInterstitialFallback() -> Bool {
        guard GoogleMobileAdsSupport.shared.hasUsableAdMobIds, let host = vc else { return false }
        return GoogleMobileAdsSupport.shared.showInterstitial(from: host)
    }
}
    



//  MARK: Interstitial Ad

extension AdmobManager: LevelPlayInterstitialDelegate {
    
    func IronSource_Interstitial_AdLoad() {
        if ADS_DISABLED_FOR_TESTING { return }
        if !ironSourceKeyReady {
            GoogleMobileAdsSupport.shared.startIfNeeded()
            GoogleMobileAdsSupport.shared.loadInterstitial()
            return
        }
        IronSource.setLevelPlayInterstitialDelegate(self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, delegate: self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, adUnits:[IS_INTERSTITIAL])
        DispatchQueue.main.async {
            IronSource.loadInterstitial()
        }
        GoogleMobileAdsSupport.shared.startIfNeeded()
    }
    
    
    func IronSource_Interstitial_ShowAds(vw : UIViewController, waitForLoadIfNeeded: Bool = false) {
        if ADS_DISABLED_FOR_TESTING { return }
        guard canShowInterstitialNow() else {
            pendingInterstitialShow = false
            return
        }
        vc = vw
        if !ironSourceKeyReady {
            pendingInterstitialShow = false
            if tryShowAdMobInterstitialFallback() {
                markInterstitialShown()
            }
            return
        }
        if IronSource.hasInterstitial() {
            pendingInterstitialShow = false
            DispatchQueue.main.async {
                self.markInterstitialShown()
                PlaybackAdHold.pause()
                IronSource.showInterstitial(with: vw)
            }
        } else if waitForLoadIfNeeded {
            // Verse Image 20/30…: wait for load, then show — no Loading VC.
            pendingInterstitialShow = true
            IronSource_Interstitial_AdLoad()
        } else {
            pendingInterstitialShow = false
            // Immediate miss → try AdMob, then warm IronSource for next time.
            if !tryShowAdMobInterstitialFallback() {
                IronSource_Interstitial_AdLoad()
            } else {
                markInterstitialShown()
                IronSource_Interstitial_AdLoad()
            }
        }
    }

    private func canShowInterstitialNow() -> Bool {
        guard lastInterstitialShownAt > 0 else { return true }
        return Date().timeIntervalSince1970 - lastInterstitialShownAt >= interstitialMinInterval
    }

    private func markInterstitialShown() {
        lastInterstitialShownAt = Date().timeIntervalSince1970
    }
    
    func didLoad(with adInfo: ISAdInfo!) {
        print("interstitial Did Load ")
        guard pendingInterstitialShow, let host = vc, IronSource.hasInterstitial() else { return }
        guard canShowInterstitialNow() else {
            pendingInterstitialShow = false
            return
        }
        pendingInterstitialShow = false
        DispatchQueue.main.async {
            self.markInterstitialShown()
            PlaybackAdHold.pause()
            IronSource.showInterstitial(with: host)
        }
    }
    
    func didFailToLoadWithError(_ error: Error!) {
        let wasPending = pendingInterstitialShow
        pendingInterstitialShow = false
        if wasPending, tryShowAdMobInterstitialFallback() {
            markInterstitialShown()
            return
        }
        var dispatchAfter = DispatchTimeInterval.seconds(ADS_DURATION*60)
        showAdUnavailableToastIfNeeded()
        
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
        PlaybackAdHold.pause()
    }
    
    func didShow(with adInfo: ISAdInfo!) {
        print("Ad showing")
    }
    
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: ISAdInfo!) {
        PlaybackAdHold.resume()
        pendingInterstitialShow = false
        showAdUnavailableToastIfNeeded()
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
        PlaybackAdHold.resume()
        pendingInterstitialShow = false
        
        if Interstitial_ID == "OpenSplash" {
            App_Protocol.DelegateSplash?.OpenAd()
            Interstitial_ID = ""
        } else {
            PaywallTriggerGate.shared.noteInterstitialClosed()
        }
        
        // Reload immediately so the next 10th/20th/30th Verse Image trigger has an ad ready.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.IronSource_Interstitial_AdLoad()
            // Shared close callback — also keep rewarded warm for Quiz Try Again / wallet.
            self.IronSource_Reward_AdLoad()
        }
        
    }
    
}





//  MARK: Reward Ad

extension AdmobManager: ISInitializationDelegate, LevelPlayRewardedVideoDelegate  {
    
    func initializationDidComplete() {
        print("initialization Did Complete")
    }
    
     
    
    func IronSource_Reward_AdLoad() { 
        if ADS_DISABLED_FOR_TESTING { return }
        if !ironSourceKeyReady {
            GoogleMobileAdsSupport.shared.startIfNeeded()
            GoogleMobileAdsSupport.shared.loadRewarded()
            return
        }
        IronSource.setLevelPlayRewardedVideoDelegate(self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, delegate: self)
        IronSource.initWithAppKey(IRONSOURCE_KEY, adUnits:[IS_REWARDED_VIDEO])
        DispatchQueue.main.async {
            IronSource.loadRewardedVideo()
        }
        GoogleMobileAdsSupport.shared.startIfNeeded()
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
        // When idle, retry load so the next Try Again / reward tap has a warmer chance.
        guard !pendingRewardedShow else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self, !self.pendingRewardedShow else { return }
            if !IronSource.hasRewardedVideo() {
                self.IronSource_Reward_AdLoad()
            }
        }
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
        } else if RewardAd == "PaywallTrigger" {
            PaywallTriggerReward.deliver()
        }
        
        
        self.IronSource_Reward_AdLoad()
    }
    
    func didClick(_ placementInfo: ISPlacementInfo!, with adInfo: ISAdInfo!) {
        print("Ad Clicked")
    }

    
    
    

    func IronSource_Reward_ShowAds(vw : UIViewController, RewardAd:String) {
        if ADS_DISABLED_FOR_TESTING { return }
        self.RewardAd = RewardAd
        vc = vw
        if !ironSourceKeyReady {
            clearPendingRewardedShow()
            if !tryShowAdMobRewardedFallback() {
                notifyRewardedAdNotAvailable()
            }
            return
        }
        // Ready → show now. Not ready → keep intent, load, poll until ready or timeout.
        if IronSource.hasRewardedVideo() {
            clearPendingRewardedShow()
            DispatchQueue.main.async {
                PlaybackAdHold.pause()
                IronSource.showRewardedVideo(with: vw)
            }
        } else {
            pendingRewardedShow = true
            pendingRewardedAttempts = 0
            // Ready → show ASAP via poll; if still empty after ~5s → AdMob fallback.
            pendingRewardedMaxAttempts = 10
            showAdWaitToastIfNeeded()
            IronSource_Reward_AdLoad()
            startPendingRewardedPoll()
        }
    }
    
    private func tryShowPendingRewardedIfPossible() {
        guard pendingRewardedShow, let host = vc else { return }
        guard IronSource.hasRewardedVideo() else { return }
        clearPendingRewardedShow()
        DispatchQueue.main.async {
            PlaybackAdHold.pause()
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
            // Give up after ~5s → AdMob fallback, then notify callers if that also misses.
            if self.pendingRewardedAttempts >= self.pendingRewardedMaxAttempts {
                self.clearPendingRewardedShow()
                DispatchQueue.main.async {
                    if !self.tryShowAdMobRewardedFallback() {
                        self.notifyRewardedAdNotAvailable()
                    }
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
    
    private func showAdWaitToastIfNeeded() {
        switch RewardAd {
        case "Tryagain", "FreeCoins", "MainFreeCoins", "WatchAd", "Scratch", "ImageWatermark", "OpenCard", "SubscrbViewController", "PaywallTrigger":
            let host = vc
            DispatchQueue.main.async {
                // Prefer the screen that requested the ad so the toast appears immediately.
                (host?.view ?? self.visibleToastView())?.makeToast("Please wait for few secs..", duration: 2.0, position: .top)
            }
        default:
            break
        }
    }

    private func showAdUnavailableToastIfNeeded() {
        switch RewardAd {
        case "Tryagain", "FreeCoins", "MainFreeCoins", "WatchAd", "Scratch", "ImageWatermark", "OpenCard", "SubscrbViewController", "PaywallTrigger":
            let host = vc
            DispatchQueue.main.async {
                (host?.view ?? self.visibleToastView())?.makeToast("Ad is not available", duration: 2.0, position: .top)
            }
        default:
            break
        }
    }

    private func visibleToastView() -> UIView? {
        var controller = vc ?? UIApplication.shared.keyWindow?.rootViewController
        while let presented = controller?.presentedViewController, presented.isBeingDismissed == false {
            controller = presented
        }
        if let tab = controller as? UITabBarController {
            controller = tab.selectedViewController ?? tab
        }
        if let nav = controller as? UINavigationController {
            controller = nav.visibleViewController ?? nav
        }
        return controller?.view
    }

    private func notifyRewardedAdNotAvailable() {
        showAdUnavailableToastIfNeeded()
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
        } else if RewardAd == "PaywallTrigger" {
            PaywallTriggerReward.onReward = nil
        }
        // Re-warm for the next tap (do not leave the pool empty after a miss).
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.IronSource_Reward_AdLoad()
        }
    }
    
        
    
   
        
}













