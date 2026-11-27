//
//  GoogleBannerAD.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 31/05/23.
//

import UIKit
import GoogleMobileAds
import UserMessagingPlatform

class GoogleBannerAD: NSObject, GADFullScreenContentDelegate,  GADBannerViewDelegate {
    
    static let shared = GoogleBannerAD()
    var SourceVC:UIViewController?
    var adBannerView: GADBannerView!
    
    private var isMobileAdsStartCalled = false
    
    
//
//    func loadAd () {
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["0e5c1ba36c64dea4188739559813375a"]
//        self.adBannerView.load(GADRequest())
//    }
//
    func InitBanner(width:CGFloat ,height:CGFloat, BannerId:String ) -> GADBannerView {
        self.adBannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: width, height: height)))
        self.adBannerView.adUnitID = BannerId
        self.adBannerView.backgroundColor = .clear
        self.adBannerView.sizeToFit()
//        Google_User_Messaging.Shared.Config(SourceVu: SourceVC!)
        return self.adBannerView
    }
//
    
    func InitAD() {
        self.adBannerView.delegate = self
        self.adBannerView.rootViewController = SourceVC
    }
   
    
   
    func loadAd () {
       
        self.InitAD()
        
       let parameters = UMPRequestParameters()
       parameters.tagForUnderAgeOfConsent = false
        
       
       UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) {
           [weak self] requestConsentError in
           guard let self else { return }
           
           if let consentError = requestConsentError {
               return print("Error: \(consentError.localizedDescription)")
           }
           UMPConsentForm.loadAndPresentIfRequired(from: SourceVC!) {
               [weak self] loadAndPresentError in
               guard let self else { return }
               
               if let consentError = loadAndPresentError {
                   // Consent gathering failed.
                   return print("Error: \(consentError.localizedDescription)")
               }
               
               // Consent has been gathered.
                    if UMPConsentInformation.sharedInstance.canRequestAds {
                      self.startGoogleMobileAdsSDK()
                    }
                  }
                }
                
                // Check if you can initialize the Google Mobile Ads SDK in parallel
                // while checking for new consent information. Consent obtained in
                // the previous session can be used to request ads.
                if UMPConsentInformation.sharedInstance.canRequestAds {
                  startGoogleMobileAdsSDK()
                }
       
              }
              
              private func startGoogleMobileAdsSDK() {
                DispatchQueue.main.async {
                  guard !self.isMobileAdsStartCalled else { return }

                  self.isMobileAdsStartCalled = true
                  GADMobileAds.sharedInstance().start()
                  GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["0e5c1ba36c64dea4188739559813375a"]
                  self.adBannerView.load(GADRequest())
                    
                }
              }
   
   
   
   
    
    
    
    
    func bannerView(banner: GADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    
}
