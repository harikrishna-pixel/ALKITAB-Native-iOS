//
//  UnityAdClass.swift
//  NKJV Bible
//

import UIKit
import UnityAds

final class UnityAdClass: NSObject {
    static let sharedInstance = UnityAdClass()

    var LoadAdCatagory = ""
    weak var sourceVC: UIViewController?
    var rewardContext = ""

    private var isInitialized = false
    private var pendingAdKind: String?
    private var interstitialAd: UADSInterstitialAd?
    private var rewardedAd: UADSRewardedAd?
    private let interstitialShowDelegate = UnityInterstitialShowHandler()
    private let rewardedShowDelegate = UnityRewardedShowHandler()

    private var interstitialPlacementId: String {
        let api = ads_network_1_field_3_ios.trimmingCharacters(in: .whitespacesAndNewlines)
        return api.isEmpty ? "Interstitial_iOS" : api
    }

    private var rewardedPlacementId: String {
        let api = ads_network_1_field_4_ios.trimmingCharacters(in: .whitespacesAndNewlines)
        return api.isEmpty ? "Rewarded_iOS" : api
    }

    override init() {
        super.init()
        interstitialShowDelegate.owner = self
        rewardedShowDelegate.owner = self
    }

    func initializeIfNeeded() {
        guard UNITY_ENABLE, !UNITY_KEY.isEmpty else { return }
        guard !isInitialized else { return }

        let config = UADSInitializationConfigurationBuilder(gameId: UNITY_KEY)
            .with(testMode: UNITY_TEST_MODE)
            .build()

        UnityAds.initialize(config) { [weak self] error in
            guard let self else { return }
            if let error {
                print("Unity Ads init failed: \(error.message)")
                self.notifyNoAd()
                return
            }
            self.isInitialized = true
            if let pending = self.pendingAdKind {
                self.pendingAdKind = nil
                self.requestAd(kind: pending)
            }
        }
    }

    func loadInterstitial_UnityAds() {
        guard UNITY_ENABLE else { return }
        LoadAdCatagory = "INTERSTITIAL"
        requestAd(kind: "INTERSTITIAL")
    }

    func loadRewarded_UnityAds(rewardContext: String, viewController: UIViewController) {
        guard UNITY_ENABLE else {
            notifyNoAd()
            return
        }
        LoadAdCatagory = "REWARDED"
        self.rewardContext = rewardContext
        sourceVC = viewController
        requestAd(kind: "REWARDED")
    }

    private func requestAd(kind: String) {
        initializeIfNeeded()
        guard isInitialized else {
            pendingAdKind = kind
            return
        }

        switch kind {
        case "INTERSTITIAL":
            loadInterstitial()
        case "REWARDED":
            loadRewarded()
        default:
            break
        }
    }

    private func loadInterstitial() {
        let loadConfig = UADSLoadConfigurationBuilder(placementId: interstitialPlacementId).build()
        UADSInterstitialAd.load(loadConfig) { [weak self] ad, error in
            guard let self else { return }
            if let error {
                print("Unity interstitial load failed: \(error.message)")
                self.notifyNoAd()
                return
            }
            guard let ad else {
                self.notifyNoAd()
                return
            }
            self.interstitialAd = ad
            self.showInterstitial(ad)
        }
    }

    private func loadRewarded() {
        let loadConfig = UADSLoadConfigurationBuilder(placementId: rewardedPlacementId).build()
        UADSRewardedAd.load(loadConfig) { [weak self] ad, error in
            guard let self else { return }
            if let error {
                print("Unity rewarded load failed: \(error.message)")
                self.notifyNoAd()
                return
            }
            guard let ad else {
                self.notifyNoAd()
                return
            }
            self.rewardedAd = ad
            self.showRewarded(ad)
        }
    }

    private func presenterViewController() -> UIViewController? {
        sourceVC ?? UIApplication.shared.keyWindow?.rootViewController
    }

    private func showInterstitial(_ ad: UADSInterstitialAd) {
        guard let presenter = presenterViewController() else {
            notifyNoAd()
            return
        }
        let showConfig = UADSShowConfigurationBuilder()
            .with(viewController: presenter)
            .build()
        ad.show(showConfig, delegate: interstitialShowDelegate)
    }

    private func showRewarded(_ ad: UADSRewardedAd) {
        guard let presenter = presenterViewController() else {
            notifyNoAd()
            return
        }
        let showConfig = UADSShowConfigurationBuilder()
            .with(viewController: presenter)
            .build()
        ad.show(showConfig, delegate: rewardedShowDelegate)
    }

    fileprivate func clearInterstitialAd() {
        interstitialAd = nil
    }

    fileprivate func clearRewardedAd() {
        rewardedAd = nil
    }

    fileprivate func notifyNoAd() {
        if !rewardContext.isEmpty {
            App_Protocol.UnituAdCallDelegate?.NoAdClosed()
        }
        rewardContext = ""
    }

    fileprivate func notifyRewardComplete() {
        App_Protocol.UnituAdCallDelegate?.AdDidClosed()
        rewardContext = ""
    }
}

private final class UnityInterstitialShowHandler: NSObject, UADSInterstitialShowDelegate {
    weak var owner: UnityAdClass?

    func showDidStart(_ unityAd: UADSInterstitialAd) {}

    func showDidClick(_ unityAd: UADSInterstitialAd) {}

    func showDidComplete(_ unityAd: UADSInterstitialAd, with finishState: UADSShowFinishState) {
        owner?.clearInterstitialAd()
    }

    func showDidFail(_ unityAd: UADSInterstitialAd, error: UnityAdsError) {
        print("Unity interstitial show failed: \(error.message)")
        owner?.clearInterstitialAd()
        owner?.notifyNoAd()
    }
}

private final class UnityRewardedShowHandler: NSObject, UADSRewardedShowDelegate {
    weak var owner: UnityAdClass?

    func showDidStart(_ unityAd: UADSRewardedAd) {}

    func showDidClick(_ unityAd: UADSRewardedAd) {}

    func showDidComplete(_ unityAd: UADSRewardedAd, with finishState: UADSShowFinishState) {
        owner?.clearRewardedAd()
    }

    func showDidFail(_ unityAd: UADSRewardedAd, error: UnityAdsError) {
        print("Unity rewarded show failed: \(error.message)")
        owner?.clearRewardedAd()
        owner?.notifyNoAd()
    }

    func showDidReceiveReward(_ unityAd: UADSRewardedAd) {
        owner?.clearRewardedAd()
        owner?.notifyRewardComplete()
    }
}
