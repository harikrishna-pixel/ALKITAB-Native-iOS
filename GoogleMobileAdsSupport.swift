//
//  GoogleMobileAdsSupport.swift
//  NKJV Bible
//
//  IronSource-first AdMob fallback helpers + SDK bootstrap.
//

import Foundation
import GoogleMobileAds
import UIKit

final class GoogleMobileAdsSupport: NSObject {
    static let shared = GoogleMobileAdsSupport()

    private var interstitial: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?
    private var started = false
    private var loadingInterstitial = false
    private var loadingRewarded = false

    private override init() {
        super.init()
    }

    func startIfNeeded() {
        guard !ADS_DISABLED_FOR_TESTING else { return }
        guard !started else { return }
        started = true
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        if !GOOGLE_ADS_DEVICE_ID.isEmpty {
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [GOOGLE_ADS_DEVICE_ID]
        }
        loadInterstitial()
        loadRewarded()
    }

    var hasUsableAdMobIds: Bool {
        let interstitialId = GOOGLE_ADS_INTERSTITIAL_ID.trimmingCharacters(in: .whitespacesAndNewlines)
        let rewardedId = GOOGLE_ADS_REWARDED.trimmingCharacters(in: .whitespacesAndNewlines)
        return !interstitialId.isEmpty || !rewardedId.isEmpty
    }

    func loadInterstitial() {
        let unitId = GOOGLE_ADS_INTERSTITIAL_ID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !unitId.isEmpty, !loadingInterstitial else { return }
        loadingInterstitial = true
        GADInterstitialAd.load(withAdUnitID: unitId, request: GADRequest()) { [weak self] ad, error in
            self?.loadingInterstitial = false
            if let error = error {
                print("AdMob interstitial load failed: \(error.localizedDescription)")
                self?.interstitial = nil
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
        }
    }

    func loadRewarded() {
        let unitId = GOOGLE_ADS_REWARDED.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !unitId.isEmpty, !loadingRewarded else { return }
        loadingRewarded = true
        GADRewardedAd.load(withAdUnitID: unitId, request: GADRequest()) { [weak self] ad, error in
            self?.loadingRewarded = false
            if let error = error {
                print("AdMob rewarded load failed: \(error.localizedDescription)")
                self?.rewardedAd = nil
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    func showInterstitial(from vc: UIViewController) -> Bool {
        startIfNeeded()
        guard let ad = interstitial else {
            loadInterstitial()
            return false
        }
        interstitial = nil
        ad.present(fromRootViewController: vc)
        return true
    }

    /// Presents rewarded AdMob if ready. Returns false if unavailable (and kicks a reload).
    @discardableResult
    func showRewarded(from vc: UIViewController, onReward: @escaping () -> Void) -> Bool {
        startIfNeeded()
        guard let ad = rewardedAd else {
            loadRewarded()
            return false
        }
        rewardedAd = nil
        ad.present(fromRootViewController: vc) {
            onReward()
        }
        return true
    }
}

extension GoogleMobileAdsSupport: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if ad is GADInterstitialAd {
            loadInterstitial()
        } else if ad is GADRewardedAd {
            loadRewarded()
        }
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("AdMob present failed: \(error.localizedDescription)")
        if ad is GADInterstitialAd {
            loadInterstitial()
        } else if ad is GADRewardedAd {
            loadRewarded()
        }
    }
}
