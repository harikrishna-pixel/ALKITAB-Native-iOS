//
//  GetAppInfo.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 09/06/21.
//

import UIKit



class GetAppInfo: NSObject {
    
    public static let shared = GetAppInfo()
    
    var identifier:[String] = []
    var item_1:[Int] = []
    var value:[Int] = []
    
    // MARK: - Load Fallback or Cached Data
    func loadFallbackOrCachedData() {
        print("\n📦 [GetAppInfo] ========================================")
        print("📦 [GetAppInfo] Checking data source...")
        print("📦 [GetAppInfo] ========================================\n")
        
        // Check if we have cached API data
        let hasCachedData = UserDefaults.standard.bool(forKey: FallbackIAPConstants.cacheKeyAPIDataLoaded)
        
        if hasCachedData {
            let lastFetchDate = UserDefaults.standard.double(forKey: FallbackIAPConstants.cacheKeyLastAPIFetchDate)
            let date = Date(timeIntervalSince1970: lastFetchDate)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            print("   ✅ Using CACHED API DATA from previous successful fetch")
            print("   → Last API fetch: \(formatter.string(from: date))")
            print("   → All values will be marked as [API] source\n")
            // Cached data already in UserDefaults, just call CallParams
            CallParams()
        } else {
            print("   ⚠️ No cached API data found")
            print("   → API has never succeeded or cache was cleared")
            print("   → Loading FALLBACK constants from AppConfig.swift\n")
            // First time or no cached data - use fallback constants
            loadFallbackConstants()
        }
    }
    
    // MARK: - Load Fallback Constants
    private func loadFallbackConstants() {
        print("\n⚠️ [GetAppInfo] ========================================")
        print("⚠️ [GetAppInfo] LOADING FALLBACK CONSTANTS (API FAILED)")
        print("⚠️ [GetAppInfo] ========================================\n")
        
        // MARK: - Set IAP Fallback Constants
        print("🔧 [GetAppInfo] Setting IAP fallback constants...")
        UserDefaults.standard.set(String(FallbackIAPConstants.iapEnabled), forKey: "is_subscription_enabled")
        UserDefaults.standard.set(FallbackIAPConstants.lifetimeProductID, forKey: "sub_identifier_lifetime")
        UserDefaults.standard.set(FallbackIAPConstants.oneYearProductID, forKey: "sub_identifier_oneyear")
        UserDefaults.standard.set(FallbackIAPConstants.sixMonthProductID, forKey: "sub_identifier_six_month")
        UserDefaults.standard.set(FallbackIAPConstants.exitOfferProductID, forKey: "sub_identifier_exit_offer")
        UserDefaults.standard.set(FallbackIAPConstants.exitOfferValue, forKey: "sub_identifier_exit_offer_value")
        UserDefaults.standard.set(FallbackIAPConstants.exitOfferItem1, forKey: "sub_identifier_exit_offer_item1")
        UserDefaults.standard.set(FallbackIAPConstants.exitOfferItem2, forKey: "sub_identifier_exit_offer_item2")
        UserDefaults.standard.set(FallbackIAPConstants.oneYearValue, forKey: "sub_identifier_oneyear_value")
        UserDefaults.standard.set(FallbackIAPConstants.lifetimeValue, forKey: "sub_identifier_lifetime_value")
        UserDefaults.standard.set(FallbackIAPConstants.sixMonthValue, forKey: "sub_identifier_six_month_value")
        UserDefaults.standard.set(FallbackIAPConstants.sharedSecret, forKey: "sub_sharedsecret")
        
        // MARK: - Set AD Fallback Constants
        print("🔧 [GetAppInfo] Setting AD fallback constants...")
        UserDefaults.standard.set(String(FallbackADConstants.adsEnabled), forKey: "ads_Type")
        UserDefaults.standard.set(FallbackADConstants.ironSourceKey, forKey: "ads_network_1_field_1_ios")
        UserDefaults.standard.set(FallbackADConstants.unityKey, forKey: "ads_network_1_field_2_ios")
        // Note: Google Ads are not used in this project - no fallback values set
        UserDefaults.standard.set(FallbackFacebookAdsConstants.facebookBannerID, forKey: "ads_facebook_banner_id_ios")
        UserDefaults.standard.set(FallbackFacebookAdsConstants.facebookInterstitialID, forKey: "ads_facebook_interstitial_id_ios")
        UserDefaults.standard.set(FallbackFacebookAdsConstants.facebookAppID, forKey: "ads_facebook_app_id_ios")
        UserDefaults.standard.set(FallbackAdDurationConstants.adsDuration, forKey: "ads_duration")
        
        // MARK: - Set Audio MP3 Bible Fallback Constants
        print("🔧 [GetAppInfo] Setting Audio MP3 Bible fallback constants...")
        UserDefaults.standard.set(FallbackAudioConstants.audioEnabled, forKey: "is_show_mp3_audio")
        UserDefaults.standard.set(FallbackAudioConstants.audioBasepath, forKey: "audio_basepath")
        UserDefaults.standard.set(FallbackAudioBasepathTypeConstants.audioBasepathType, forKey: "audio_basepath_type")
        
        // MARK: - Set Text to Speech Fallback Constants
        print("🔧 [GetAppInfo] Setting TTS fallback constants...")
        UserDefaults.standard.set(FallbackTTSConstants.ttsEnabled, forKey: "is_text_to_speech_available_ios")
        UserDefaults.standard.set(FallbackTTSConstants.ttsLanguageCode, forKey: "text_to_speech_language_code_ios")
        UserDefaults.standard.set(FallbackTTSConstants.ttsIdentifier, forKey: "text_to_speech_identifier_ios")
        
        // MARK: - Set Coins/Quiz Fallback Constants
        print("🔧 [GetAppInfo] Setting Coins/Quiz fallback constants...")
        UserDefaults.standard.set(FallbackIAPConstants.coin50_50, forKey: "50_50")
        UserDefaults.standard.set(FallbackIAPConstants.coinHint, forKey: "hint")
        UserDefaults.standard.set(FallbackIAPConstants.coinShare, forKey: "share")
        UserDefaults.standard.set(FallbackIAPConstants.coinTimeWait, forKey: "time_wait")
        UserDefaults.standard.set(FallbackIAPConstants.coinTryAgain, forKey: "try_again")
        UserDefaults.standard.set(FallbackIAPConstants.coinViewAnswer, forKey: "view_answer")
        
        // MARK: - Set Coin Pack Fallback Constants
        print("🔧 [GetAppInfo] Setting Coin Pack fallback constants...")
        // Set coin pack identifiers as arrays (matching API structure)
        let coinPackIdentifiers = [
            FallbackIAPConstants.coinPack1ProductID,
            FallbackIAPConstants.coinPack2ProductID,
            FallbackIAPConstants.coinPack3ProductID
        ]
        let coinPackCoins = [
            FallbackIAPConstants.coinPack1Coins,
            FallbackIAPConstants.coinPack2Coins,
            FallbackIAPConstants.coinPack3Coins
        ]
        let coinPackValues = [
            Int(FallbackIAPConstants.coinPack1Value) ?? 0,
            Int(FallbackIAPConstants.coinPack2Value) ?? 0,
            Int(FallbackIAPConstants.coinPack3Value) ?? 0
        ]
        UserDefaults.standard.set(coinPackIdentifiers, forKey: "identifier")
        UserDefaults.standard.set(coinPackCoins, forKey: "item_1")
        UserDefaults.standard.set(coinPackValues, forKey: "value")
        print("   ✅ Coin Pack 1: \(FallbackIAPConstants.coinPack1ProductID) - \(FallbackIAPConstants.coinPack1Coins) coins")
        print("   ✅ Coin Pack 2: \(FallbackIAPConstants.coinPack2ProductID) - \(FallbackIAPConstants.coinPack2Coins) coins")
        print("   ✅ Coin Pack 3: \(FallbackIAPConstants.coinPack3ProductID) - \(FallbackIAPConstants.coinPack3Coins) coins")
        
        // MARK: - Set Offer Fallback Constants
        print("🔧 [GetAppInfo] Setting Offer fallback constants...")
        UserDefaults.standard.set(FallbackOfferConstants.offerEnabled, forKey: "offer_enabled")
        UserDefaults.standard.set(FallbackOfferConstants.offerDays, forKey: "offer_days")
        UserDefaults.standard.set(FallbackOfferConstants.offerCount, forKey: "offer_count")
        
        // MARK: - Set App Config Fallback Constants
        print("🔧 [GetAppInfo] Setting App Config fallback constants...")
        UserDefaults.standard.set(FallbackAppConfigConstants.appName, forKey: "app_name")
        UserDefaults.standard.set(FallbackAppConfigConstants.appShareAppLink, forKey: "app_shareapp_link")
        UserDefaults.standard.set(FallbackAppConfigConstants.appThemeColor, forKey: "app_theme_color")
        UserDefaults.standard.set(FallbackAppConfigConstants.appTypeVersion, forKey: "app_type_version")
        UserDefaults.standard.set(FallbackAppConfigConstants.feedbackEmail, forKey: "feedback_email")
        UserDefaults.standard.set(FallbackAppConfigConstants.isImageAvailable, forKey: "is_image_available")
        UserDefaults.standard.set(FallbackAppConfigConstants.isMulticategoryAvailable, forKey: "is_multicategory_available")
        UserDefaults.standard.set(FallbackAppConfigConstants.isNotificationAvailable, forKey: "is_notification_available")
        UserDefaults.standard.set(FallbackAppConfigConstants.isQuoteAvailable, forKey: "is_quote_available")
        UserDefaults.standard.set(FallbackAppConfigConstants.isVideoAvailable, forKey: "is_video_available")
        UserDefaults.standard.set(FallbackAppConfigConstants.languageCode, forKey: "language_code")
        UserDefaults.standard.set(FallbackAppConfigConstants.languageName, forKey: "language_name")
        UserDefaults.standard.set(FallbackAppConfigConstants.shortLangCode, forKey: "short_lang_code")
        UserDefaults.standard.set(FallbackAppConfigConstants.imageAppId, forKey: "image_app_id")
        UserDefaults.standard.set(FallbackAppConfigConstants.pushAppId, forKey: "push_appid")
        UserDefaults.standard.set(FallbackAppConfigConstants.quizCatId, forKey: "quiz_cat_id")
        UserDefaults.standard.set(FallbackAppConfigConstants.quoteAppId, forKey: "quote_app_id")
        UserDefaults.standard.set(FallbackAppConfigConstants.verseEditorAppId, forKey: "verse_editor_app_id")
        UserDefaults.standard.set(FallbackAppConfigConstants.videoAppId, forKey: "video_app_id")
        UserDefaults.standard.set(FallbackAppConfigConstants.wallpaperCatId, forKey: "wallpaper_cat_id")
        UserDefaults.standard.set(FallbackAppConfigConstants.showInterstitialRow, forKey: "show_interstitial_row")
        UserDefaults.standard.set(FallbackAppConfigConstants.showNativeAdsRow, forKey: "show_native_ads_row")
        UserDefaults.standard.set(FallbackAppConfigConstants.bookAdsStatus, forKey: "book_ads_status")
        UserDefaults.standard.set(FallbackAppConfigConstants.bookAdsAppId, forKey: "book_ads_app_id")
        
        // MARK: - Set Copyright Fallback Constants
        print("🔧 [GetAppInfo] Setting Copyright fallback constants...")
        UserDefaults.standard.set(FallbackCopyrightConstants.copyrightURL, forKey: "copyright_url")
        
        print("\n✅ [GetAppInfo] All fallback constants SET in UserDefaults:")
        print("   → IAP, AD, Audio, TTS, Coins, Offers, App Config, Copyright")
        print("   → Total fallback values loaded: ~50+ configuration values\n")
        
        // Call CallParams to populate global variables (will log with FALLBACK source)
        CallParams()
    }
    
    
    func SaveAppinfo(resultDictionary: Dictionary<String, AnyObject>) {
        
        print("\n" + String(repeating: "=", count: 80))
        print("📡 [GetAppInfo] ========== FULL API RESPONSE START ==========")
        print(String(repeating: "=", count: 80))
        print("📦 [GetAppInfo] Complete API Response Dictionary:")
        print(resultDictionary)
        print(String(repeating: "=", count: 80) + "\n")
        
        let bibleApdata = resultDictionary["data"] as! Dictionary<String, AnyObject>
        print("📋 [GetAppInfo] ========== BIBLE AP DATA ==========")
        print("📋 [GetAppInfo] All keys in bibleApdata:")
        for key in bibleApdata.keys.sorted() {
            let value = bibleApdata[key]
            let valueString = value != nil ? String(describing: value!) : "nil"
            print("   → \(key): \(valueString)")
        }
        print(String(repeating: "-", count: 80) + "\n")
        
        let bible_audio_info = bibleApdata["bible_audio_info"]! as! Dictionary<String,AnyObject>
        print("🎵 [GetAppInfo] ========== BIBLE AUDIO INFO ==========")
        print("🎵 [GetAppInfo] All keys in bible_audio_info:")
        for key in bible_audio_info.keys.sorted() {
            let value = bible_audio_info[key]
            let valueString = value != nil ? String(describing: value!) : "nil"
            print("   → \(key): \(valueString)")
        }
        print(String(repeating: "-", count: 80) + "\n")
                
        
        let coins_data = bibleApdata["coins_data"]! as! Dictionary<String,AnyObject>
        print("🪙 [GetAppInfo] ========== COINS DATA ==========")
        print("🪙 [GetAppInfo] All keys in coins_data:")
        for key in coins_data.keys.sorted() {
            let value = coins_data[key]
            let valueString = value != nil ? String(describing: value!) : "nil"
            print("   → \(key): \(valueString)")
        }
        print(String(repeating: "-", count: 80) + "\n")
        
        let sub_fields = bibleApdata["sub_fields"]! as! Array<Dictionary<String,AnyObject>>
        print("📝 [GetAppInfo] ========== SUB FIELDS ==========")
        print("📝 [GetAppInfo] Total sub_fields count: \(sub_fields.count)")
        for (index, field) in sub_fields.enumerated() {
            print("   → sub_fields[\(index)]:")
            for key in field.keys.sorted() {
                let value = field[key]
                let valueString = value != nil ? String(describing: value!) : "nil"
                print("      - \(key): \(valueString)")
            }
        }
        print(String(repeating: "-", count: 80) + "\n")
        
        
        for i in 0..<sub_fields.count {
            let fieldNum = sub_fields[i].stringValueForKey("field_num")
            let item1Value = sub_fields[i].stringValueForKey("item_1")
            let item2Value = sub_fields[i].stringValueForKey("item_2")
            let valueStr = sub_fields[i].stringValueForKey("value")
            let identifier = sub_fields[i].stringValueForKey("identifier")
            
            // Check if this is the exit offer field (field_num == "9" or contains "Lifetime")
            if fieldNum == "9" || (item1Value.lowercased().contains("lifetime") && !identifier.isEmpty && identifier.hasSuffix(".offer")) {
                // This is the exit offer - save it separately, don't add to coin pack arrays
                print("🎯 [GetAppInfo] Exit offer found:")
                print("   → field_num: '\(fieldNum)'")
                print("   → identifier: '\(identifier)'")
                print("   → item_1: '\(item1Value)'")
                print("   → item_2: '\(item2Value)'")
                print("   → value: '\(valueStr)'")
                
                // FIXED: Force sync to ensure UserDefaults is written immediately
                UserDefaults.standard.set(identifier, forKey: "sub_identifier_exit_offer")
                UserDefaults.standard.set(valueStr, forKey: "sub_identifier_exit_offer_value")
                UserDefaults.standard.set(item1Value, forKey: "sub_identifier_exit_offer_item1")
                UserDefaults.standard.set(item2Value, forKey: "sub_identifier_exit_offer_item2")
                UserDefaults.standard.synchronize()  // Force immediate write
                
                print("   ✅ Exit offer data saved to UserDefaults")
                print("   → Verified: '\(UserDefaults.standard.string(forKey: "sub_identifier_exit_offer") ?? "nil")'")
            } else if Int(item1Value) ?? 0 > 0 && !identifier.isEmpty {
                // This is a coin pack - add to coin pack arrays (exclude exit offer)
                self.identifier.append(identifier)
                self.item_1.append(Int(item1Value) ?? 0)
                self.value.append(Int(valueStr) ?? 0)
                print("💰 [GetAppInfo] Coin pack added: identifier='\(identifier)', coins=\(item1Value), value=\(valueStr)")
            }
        }
        
        if item_1.count >= 3 {
            Pack1 = item_1[0]
            Pack2 = item_1[1]
            Pack3 = item_1[2]
            print("📦 [GetAppInfo] Coin packs set: Pack1=\(Pack1), Pack2=\(Pack2), Pack3=\(Pack3)")
        }
        
        UserDefaults.standard.set(identifier, forKey: "identifier")
        UserDefaults.standard.set(item_1, forKey: "item_1")
        UserDefaults.standard.set(value, forKey: "value")
        print("💰 [GetAppInfo] Coin pack arrays saved to UserDefaults:")
        print("   → identifier count: \(identifier.count)")
        print("   → item_1 count: \(item_1.count)")
        print("   → value count: \(value.count)")
        if identifier.count > 0 {
            for (index, id) in identifier.enumerated() {
                print("   → Pack \(index + 1): \(id) - \(item_1.count > index ? item_1[index] : 0) coins")
            }
        }
        
        
        UserDefaults.standard.set(Int(coins_data.stringValueForKey("50_50")), forKey: "50_50")
        UserDefaults.standard.set(Int(coins_data.stringValueForKey("hint")), forKey: "hint")
        UserDefaults.standard.set(Int(coins_data.stringValueForKey("share")), forKey: "share")
        UserDefaults.standard.set(Int(coins_data.stringValueForKey("time_wait")), forKey: "time_wait")
        UserDefaults.standard.set(Int(coins_data.stringValueForKey("try_again")), forKey: "try_again")
        UserDefaults.standard.set(Int(coins_data.stringValueForKey("view_answer")), forKey: "view_answer")
        
        
        
        UserDefaults.standard.set(bible_audio_info.stringValueForKey("audio_basepath"), forKey: "audio_basepath")
        UserDefaults.standard.set(bible_audio_info.stringValueForKey("audio_basepath_type"), forKey: "audio_basepath_type")
        UserDefaults.standard.set(bible_audio_info.stringValueForKey("is_show_mp3_audio"), forKey: "is_show_mp3_audio")
        UserDefaults.standard.set(bible_audio_info.stringValueForKey("text_to_speech_identifier_ios"), forKey: "text_to_speech_identifier_ios")
        UserDefaults.standard.set(bible_audio_info.stringValueForKey("text_to_speech_language_code_ios"), forKey: "text_to_speech_language_code_ios")
        UserDefaults.standard.set(bible_audio_info.stringValueForKey("is_text_to_speech_available_ios"), forKey: "is_text_to_speech_available_ios")
        
        
        UserDefaults.standard.set(bibleApdata.stringValueForKey("offer_enabled"), forKey: "offer_enabled")
        UserDefaults.standard.set(bibleApdata.stringValueForKey("offer_days"), forKey: "offer_days")
        UserDefaults.standard.set(bibleApdata.stringValueForKey("offer_count"), forKey: "offer_count")
        
    
        
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_Type"), forKey: "ads_Type")
        
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_facebook_banner_id_ios"), forKey: "ads_facebook_banner_id_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_facebook_interstitial_id_ios"), forKey: "ads_facebook_interstitial_id_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_facebook_app_id_ios"), forKey: "ads_facebook_app_id_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_google_banner_id_ios"), forKey: "ads_google_banner_id_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_google_banner_id_2_ios"), forKey: "ads_google_banner_id_2_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_google_banner_id_3_ios"), forKey: "ads_google_banner_id_3_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_google_interstitial_id_ios"), forKey: "ads_google_interstitial_id_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_google_native_id_ios"), forKey: "ads_google_native_id_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_google_openApp_id_ios"), forKey: "ads_google_openApp_id_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_google_reward_id_ios"), forKey: "ads_google_reward_id_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_google_reward_interstitial_id_ios"), forKey: "ads_google_reward_interstitial_id_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_duration"), forKey: "ads_duration")
        
        
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_network_1_field_1_ios"), forKey: "ads_network_1_field_1_ios")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("ads_network_1_field_2_ios"), forKey: "ads_network_1_field_2_ios")
        
        
        
        
        
        
        
        
        
         UserDefaults.standard.set(bibleApdata.stringValueForKey("app_name"), forKey: "app_name")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("app_shareapp_link"), forKey: "app_shareapp_link")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("app_theme_color"), forKey: "app_theme_color")
         
        UserDefaults.standard.set(bibleApdata.stringValueForKey("book_ads_status"), forKey: "book_ads_status")
        UserDefaults.standard.set(bibleApdata.stringValueForKey("book_ads_app_id"), forKey: "book_ads_app_id")
        
        
        
         UserDefaults.standard.set(bibleApdata.stringValueForKey("feedback_email"), forKey: "feedback_email")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("image_app_id"), forKey: "image_app_id")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("is_image_available"), forKey: "is_image_available")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("is_multicategory_available"), forKey: "is_multicategory_available")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("is_notification_available"), forKey: "is_notification_available")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("is_quote_available"), forKey: "is_quote_available")
         
         UserDefaults.standard.set(bibleApdata.stringValueForKey("is_subscription_enabled"), forKey: "is_subscription_enabled")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("is_video_available"), forKey: "is_video_available")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("language_code"), forKey: "language_code")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("language_name"), forKey: "language_name")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("push_appid"), forKey: "push_appid")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("quiz_cat_id"), forKey: "quiz_cat_id")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("quote_app_id"), forKey: "quote_app_id")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("short_lang_code"), forKey: "short_lang_code")
        
        
         UserDefaults.standard.set(bibleApdata.stringValueForKey("show_interstitial_row"), forKey: "show_interstitial_row")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("show_native_ads_row"), forKey: "show_native_ads_row")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("sub_identifier_lifetime"), forKey: "sub_identifier_lifetime")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("sub_identifier_oneyear"), forKey: "sub_identifier_oneyear")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("sub_identifier_six_month"), forKey: "sub_identifier_six_month")
         
         // FIXED: Exit offer is saved from sub_fields extraction (line 244), don't overwrite with empty value from bibleApdata
         // Only set if bibleApdata actually has a value (most APIs don't have exit offer at top level)
         let exitOfferFromBibleApdata = bibleApdata.stringValueForKey("sub_identifier_exit_offer")
         if !exitOfferFromBibleApdata.isEmpty {
             UserDefaults.standard.set(exitOfferFromBibleApdata, forKey: "sub_identifier_exit_offer")
             print("   ✅ Exit offer from bibleApdata: '\(exitOfferFromBibleApdata)'")
         } else {
             print("   ℹ️ Exit offer not in bibleApdata (will use sub_fields value)")
         }
         
         // Try to get values directly from bibleApdata first
         let oneYearValueFromBibleApdata = bibleApdata.stringValueForKey("sub_identifier_oneyear_value")
         UserDefaults.standard.set(oneYearValueFromBibleApdata, forKey: "sub_identifier_oneyear_value")
         print("🔍 [GetAppInfo] Yearly offer value from bibleApdata: '\(oneYearValueFromBibleApdata)'")
         
         UserDefaults.standard.set(bibleApdata.stringValueForKey("sub_identifier_lifetime_value"), forKey: "sub_identifier_lifetime_value")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("sub_identifier_six_month_value"), forKey: "sub_identifier_six_month_value")
         
         // FIXED: Exit offer values are saved from sub_fields extraction, only overwrite if bibleApdata has values
         let exitOfferValueFromBibleApdata = bibleApdata.stringValueForKey("sub_identifier_exit_offer_value")
         let exitOfferItem1FromBibleApdata = bibleApdata.stringValueForKey("sub_identifier_exit_offer_item1")
         let exitOfferItem2FromBibleApdata = bibleApdata.stringValueForKey("sub_identifier_exit_offer_item2")
         
         if !exitOfferValueFromBibleApdata.isEmpty {
             UserDefaults.standard.set(exitOfferValueFromBibleApdata, forKey: "sub_identifier_exit_offer_value")
         }
         if !exitOfferItem1FromBibleApdata.isEmpty {
             UserDefaults.standard.set(exitOfferItem1FromBibleApdata, forKey: "sub_identifier_exit_offer_item1")
         }
         if !exitOfferItem2FromBibleApdata.isEmpty {
             UserDefaults.standard.set(exitOfferItem2FromBibleApdata, forKey: "sub_identifier_exit_offer_item2")
         }
         
         // ✅ ADDED: Extract yearly and lifetime offer values from sub_fields array if not found in bibleApdata
         // Get subscription identifiers that were just saved
         let oneYearIdentifier = bibleApdata.stringValueForKey("sub_identifier_oneyear")
         let lifetimeIdentifier = bibleApdata.stringValueForKey("sub_identifier_lifetime")
         let sixMonthIdentifier = bibleApdata.stringValueForKey("sub_identifier_six_month")
         
         print("🔍 [GetAppInfo] Subscription identifiers:")
         print("   → oneYearIdentifier: '\(oneYearIdentifier)'")
         print("   → lifetimeIdentifier: '\(lifetimeIdentifier)'")
         print("   → sixMonthIdentifier: '\(sixMonthIdentifier)'")
         
         // Extract values from sub_fields by matching identifiers (if values are empty from bibleApdata)
         let currentOneYearValue = UserDefaults.standard.string(forKey: "sub_identifier_oneyear_value") ?? ""
         let currentLifetimeValue = UserDefaults.standard.string(forKey: "sub_identifier_lifetime_value") ?? ""
         let currentSixMonthValue = UserDefaults.standard.string(forKey: "sub_identifier_six_month_value") ?? ""
         
         print("🔍 [GetAppInfo] Current values before sub_fields extraction:")
         print("   → currentOneYearValue: '\(currentOneYearValue)'")
         print("   → currentLifetimeValue: '\(currentLifetimeValue)'")
         print("   → currentSixMonthValue: '\(currentSixMonthValue)'")
         print("   → sub_fields count: \(sub_fields.count)")
         
         for i in 0..<sub_fields.count {
             let fieldIdentifier = sub_fields[i].stringValueForKey("identifier")
             let fieldValue = sub_fields[i].stringValueForKey("value")
             
             print("   → sub_fields[\(i)]: identifier='\(fieldIdentifier)', value='\(fieldValue)'")
             
             // Match yearly subscription - extract value if not already set or if identifier matches
             if !oneYearIdentifier.isEmpty && fieldIdentifier == oneYearIdentifier && !fieldValue.isEmpty {
                 if currentOneYearValue.isEmpty || fieldValue != currentOneYearValue {
                     UserDefaults.standard.set(fieldValue, forKey: "sub_identifier_oneyear_value")
                     print("✅ [GetAppInfo] Yearly offer value extracted from sub_fields: \(fieldValue)%")
                 } else {
                     print("⚠️ [GetAppInfo] Yearly offer value already set or matches current value")
                 }
             }
             
             // Match lifetime subscription - extract value if not already set or if identifier matches
             if !lifetimeIdentifier.isEmpty && fieldIdentifier == lifetimeIdentifier && !fieldValue.isEmpty {
                 if currentLifetimeValue.isEmpty || fieldValue != currentLifetimeValue {
                     UserDefaults.standard.set(fieldValue, forKey: "sub_identifier_lifetime_value")
                     print("✅ [GetAppInfo] Lifetime offer value extracted from sub_fields: \(fieldValue)%")
                 }
             }
             
             // Match six month subscription - extract value if not already set or if identifier matches
             if !sixMonthIdentifier.isEmpty && fieldIdentifier == sixMonthIdentifier && !fieldValue.isEmpty {
                 if currentSixMonthValue.isEmpty || fieldValue != currentSixMonthValue {
                     UserDefaults.standard.set(fieldValue, forKey: "sub_identifier_six_month_value")
                     print("✅ [GetAppInfo] Six month offer value extracted from sub_fields: \(fieldValue)%")
                 }
             }
         }
         
         // Final summary of yearly offer value
         let finalOneYearValue = UserDefaults.standard.string(forKey: "sub_identifier_oneyear_value") ?? ""
         print("📋 [GetAppInfo] Final yearly offer value after extraction: '\(finalOneYearValue)'")
         if finalOneYearValue.isEmpty {
             print("   ⚠️ WARNING: sub_identifier_oneyear_value is EMPTY - badge will not show!")
         }
        
         UserDefaults.standard.set(bibleApdata.stringValueForKey("sub_sharedsecret"), forKey: "sub_sharedsecret")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("verse_editor_app_id"), forKey: "verse_editor_app_id")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("video_app_id"), forKey: "video_app_id")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("wallpaper_cat_id"), forKey: "wallpaper_cat_id")
         UserDefaults.standard.set(bibleApdata.stringValueForKey("app_type_version"), forKey: "app_type_version")
        
        
        let copyright_info = bibleApdata["copyright_info"]! as! Dictionary<String,AnyObject>
        print("©️ [GetAppInfo] ========== COPYRIGHT INFO ==========")
        print("©️ [GetAppInfo] All keys in copyright_info:")
        for key in copyright_info.keys.sorted() {
            let value = copyright_info[key]
            let valueString = value != nil ? String(describing: value!) : "nil"
            print("   → \(key): \(valueString)")
        }
        print(String(repeating: "-", count: 80) + "\n")
        
        COPIRIGHTS_URL = copyright_info.stringValueForKey("copyright_url")
        UserDefaults.standard.set(COPIRIGHTS_URL, forKey: "copyright_url")
        
        // Print specific important values
        print("🔑 [GetAppInfo] ========== KEY VALUES SUMMARY ==========")
        print("   → sub_sharedsecret: '\(bibleApdata.stringValueForKey("sub_sharedsecret"))'")
        print("   → is_subscription_enabled: '\(bibleApdata.stringValueForKey("is_subscription_enabled"))'")
        print("   → sub_identifier_lifetime: '\(bibleApdata.stringValueForKey("sub_identifier_lifetime"))'")
        print("   → sub_identifier_oneyear: '\(bibleApdata.stringValueForKey("sub_identifier_oneyear"))'")
        print("   → sub_identifier_six_month: '\(bibleApdata.stringValueForKey("sub_identifier_six_month"))'")
        print("   → sub_identifier_lifetime_value: '\(bibleApdata.stringValueForKey("sub_identifier_lifetime_value"))'")
        print("   → sub_identifier_oneyear_value: '\(bibleApdata.stringValueForKey("sub_identifier_oneyear_value"))'")
        print("   → sub_identifier_six_month_value: '\(bibleApdata.stringValueForKey("sub_identifier_six_month_value"))'")
        print("   → ads_Type: '\(bibleApdata.stringValueForKey("ads_Type"))'")
        print("   → ads_network_1_field_1_ios (IronSource): '\(bibleApdata.stringValueForKey("ads_network_1_field_1_ios"))'")
        print("   → ads_network_1_field_2_ios (Unity): '\(bibleApdata.stringValueForKey("ads_network_1_field_2_ios"))'")
        print("   → audio_basepath: '\(bible_audio_info.stringValueForKey("audio_basepath"))'")
        print("   → is_show_mp3_audio: '\(bible_audio_info.stringValueForKey("is_show_mp3_audio"))'")
        print("   → is_text_to_speech_available_ios: '\(bible_audio_info.stringValueForKey("is_text_to_speech_available_ios"))'")
        print("   → text_to_speech_language_code_ios: '\(bible_audio_info.stringValueForKey("text_to_speech_language_code_ios"))'")
        print("   → text_to_speech_identifier_ios: '\(bible_audio_info.stringValueForKey("text_to_speech_identifier_ios"))'")
        print("   → offer_enabled: '\(bibleApdata.stringValueForKey("offer_enabled"))'")
        print("   → offer_days: '\(bibleApdata.stringValueForKey("offer_days"))'")
        print("   → offer_count: '\(bibleApdata.stringValueForKey("offer_count"))'")
        print(String(repeating: "=", count: 80))
        print("📡 [GetAppInfo] ========== FULL API RESPONSE END ==========")
        print(String(repeating: "=", count: 80) + "\n")
        
        // MARK: - Cache Management
        // Mark that we have successfully loaded and cached API data
        UserDefaults.standard.set(true, forKey: FallbackIAPConstants.cacheKeyAPIDataLoaded)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: FallbackIAPConstants.cacheKeyLastAPIFetchDate)
        
        print("✅ [GetAppInfo] API data saved to cache successfully")
        print("   → Cached at: \(Date())")
        print("📡 [GetAppInfo] API VALUES SAVED - All values below are from API:")
        print("   → IAP Enabled: \(bibleApdata.stringValueForKey("is_subscription_enabled"))")
        print("   → Lifetime Product ID: \(bibleApdata.stringValueForKey("sub_identifier_lifetime"))")
        print("   → One Year Product ID: \(bibleApdata.stringValueForKey("sub_identifier_oneyear"))")
        print("   → AD Type: \(bibleApdata.stringValueForKey("ads_Type"))")
        print("   → IronSource Key: \(bibleApdata.stringValueForKey("ads_network_1_field_1_ios"))")
        print("   → Unity Key: \(bibleApdata.stringValueForKey("ads_network_1_field_2_ios"))")
        print("   → Audio Enabled: \(bible_audio_info.stringValueForKey("is_show_mp3_audio"))")
        print("   → Audio Basepath: \(bible_audio_info.stringValueForKey("audio_basepath"))")
        print("   → TTS Enabled: \(bible_audio_info.stringValueForKey("is_text_to_speech_available_ios"))")
        
    }
    
    
    
    
    func CallParams() {
        // Determine if we're using API data or fallback by checking cache flag
        let hasCachedAPIData = UserDefaults.standard.bool(forKey: FallbackIAPConstants.cacheKeyAPIDataLoaded)
        let dataSource = hasCachedAPIData ? "🌐 API/CACHE" : "⚠️ FALLBACK"
        print("\n📊 [GetAppInfo] CallParams() - Loading configuration values")
        print("   → Data Source: \(dataSource)")
        
        // Load coin pack values (Pack1, Pack2, Pack3) from UserDefaults
        if let item1Array = UserDefaults.standard.array(forKey: "item_1") as? [Int], item1Array.count >= 3 {
            Pack1 = item1Array[0]
            Pack2 = item1Array[1]
            Pack3 = item1Array[2]
            print("📦 [GetAppInfo] Coin packs loaded: Pack1=\(Pack1), Pack2=\(Pack2), Pack3=\(Pack3)")
        } else {
            // Fallback to constants if not in UserDefaults
            Pack1 = FallbackIAPConstants.coinPack1Coins
            Pack2 = FallbackIAPConstants.coinPack2Coins
            Pack3 = FallbackIAPConstants.coinPack3Coins
            print("📦 [GetAppInfo] Coin packs using fallback: Pack1=\(Pack1), Pack2=\(Pack2), Pack3=\(Pack3)")
        }
        
        ADS_TYPE = UserDefaults.standard.integer(forKey: "ads_Type")
        if ADS_TYPE == 0 && !hasCachedAPIData {
            ADS_TYPE = FallbackADConstants.adsEnabled
        }

        
        ADS_DURATION = UserDefaults.standard.integer(forKey: "ads_duration")
        if ADS_DURATION == 0 && !hasCachedAPIData {
            ADS_DURATION = FallbackAdDurationConstants.adsDuration
        }


        HintCoins  = UserDefaults.standard.integer(forKey: "hint")
        HalfCoin = UserDefaults.standard.integer(forKey: "50_50")
        ShowAnswerCoins = UserDefaults.standard.integer(forKey: "view_answer")
        tryAgainCoins = UserDefaults.standard.integer(forKey: "try_again")
        rewardCoins = UserDefaults.standard.integer(forKey: "share")
        freeCoins = UserDefaults.standard.integer(forKey: "time_wait")
        
        if freeCoins == 0 {
            // Use fallback values if available, otherwise use defaults
            if !hasCachedAPIData {
                HintCoins = FallbackIAPConstants.coinHint > 0 ? FallbackIAPConstants.coinHint : 20
                HalfCoin = FallbackIAPConstants.coin50_50 > 0 ? FallbackIAPConstants.coin50_50 : 20
                ShowAnswerCoins = FallbackIAPConstants.coinViewAnswer > 0 ? FallbackIAPConstants.coinViewAnswer : 20
                tryAgainCoins = FallbackIAPConstants.coinTryAgain > 0 ? FallbackIAPConstants.coinTryAgain : 20
                rewardCoins = FallbackIAPConstants.coinShare > 0 ? FallbackIAPConstants.coinShare : 20
                freeCoins = FallbackIAPConstants.coinTimeWait > 0 ? FallbackIAPConstants.coinTimeWait : 20
            } else {
            HintCoins  = 20
            HalfCoin = 20
            ShowAnswerCoins = 20
            tryAgainCoins = 20
            rewardCoins = 20
            freeCoins = 20
            }
        }
        
        
        offer_enabled = UserDefaults.standard.string(forKey: "offer_enabled") ?? ""
        offer_days = UserDefaults.standard.string(forKey: "offer_days") ?? "9"
        offer_count = UserDefaults.standard.string(forKey: "offer_count") ?? "100"
        book_ads_status = UserDefaults.standard.integer(forKey: "book_ads_status")
        book_ads_app_id = UserDefaults.standard.integer(forKey: "book_ads_app_id")
        
        if offer_enabled == "1" {
            
            if offer_days == "" {
                offer_days = "9"
            }
            
            if offer_count == "" {
                offer_count = "200"
            }
        }
        
        
         // Google Ads - Not used in this project, but still load from API/UserDefaults if available
        GOOGLE_BANNER_ADS = UserDefaults.standard.string(forKey: "ads_google_banner_id_ios") ?? ""
        GOOGLE_ADS_INTERSTITIAL_ID = UserDefaults.standard.string(forKey: "ads_google_interstitial_id_ios") ?? ""
        GOOGLE_ADS_APP_OPEN = UserDefaults.standard.string(forKey: "ads_google_openApp_id_ios") ?? ""
        GOOGLE_ADS_REWARDED = UserDefaults.standard.string(forKey: "ads_google_reward_id_ios") ?? ""
        GOOGLE_BANNER_ADS_ID2 = UserDefaults.standard.string(forKey: "ads_google_banner_id_2_ios") ?? ""
        GOOGLE_BANNER_ADS_ID3 = UserDefaults.standard.string(forKey: "ads_google_banner_id_3_ios") ?? ""
        GOOGLE_ADS_REWARDED_INTERSTITIAL_ID = UserDefaults.standard.string(forKey: "ads_google_reward_interstitial_id_ios") ?? ""
        GOOGLE_NATIVE_AD_ID = UserDefaults.standard.string(forKey: "ads_google_native_id_ios") ?? ""



        // FaceBook
        ads_facebook_interstitial_id_ios = UserDefaults.standard.string(forKey: "ads_facebook_interstitial_id_ios") ?? ""
        if ads_facebook_interstitial_id_ios.isEmpty && !hasCachedAPIData {
            ads_facebook_interstitial_id_ios = FallbackFacebookAdsConstants.facebookInterstitialID
        }
        ads_facebook_banner_id_ios = UserDefaults.standard.string(forKey: "ads_facebook_banner_id_ios") ?? ""
        if ads_facebook_banner_id_ios.isEmpty && !hasCachedAPIData {
            ads_facebook_banner_id_ios = FallbackFacebookAdsConstants.facebookBannerID
        }
        ads_facebook_app_id_ios = UserDefaults.standard.string(forKey: "ads_facebook_app_id_ios") ?? ""
        if ads_facebook_app_id_ios.isEmpty && !hasCachedAPIData {
            ads_facebook_app_id_ios = FallbackFacebookAdsConstants.facebookAppID
        }


        IRONSOURCE_KEY = UserDefaults.standard.string(forKey: "ads_network_1_field_1_ios") ?? ""
        if IRONSOURCE_KEY.isEmpty && !hasCachedAPIData {
            IRONSOURCE_KEY = FallbackADConstants.ironSourceKey
        }
        UNITY_KEY = UserDefaults.standard.string(forKey: "ads_network_1_field_2_ios") ?? ""
        if UNITY_KEY.isEmpty && !hasCachedAPIData {
            UNITY_KEY = FallbackADConstants.unityKey
        }
        
        
        ads_network_1_field_2_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_2_ios") ?? ""
        ads_network_1_field_3_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_3_ios") ?? ""
        ads_network_1_field_4_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_4_ios") ?? ""
        ads_network_1_field_5_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_5_ios") ?? ""
        ads_network_1_field_6_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_6_ios") ?? ""
        ads_network_2_field_1_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_1_ios") ?? ""
        ads_network_2_field_2_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_2_ios") ?? ""
        ads_network_2_field_3_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_3_ios") ?? ""
        ads_network_2_field_4_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_4_ios") ?? ""
        ads_network_2_field_5_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_5_ios") ?? ""
        ads_network_2_field_6_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_6_ios") ?? ""

        
        
                

        // MARK: APP CONFIGS

        
        app_shareapp_link = UserDefaults.standard.string(forKey: "app_shareapp_link") ?? ""
        app_theme_color = UserDefaults.standard.string(forKey: "app_theme_color") ?? ""
        app_type_version = UserDefaults.standard.string(forKey: "app_type_version") ?? ""
        FEEDBACKMAIL = UserDefaults.standard.string(forKey: "feedback_email") ?? ""
        image_app_id = UserDefaults.standard.string(forKey: "image_app_id") ?? ""
        is_image_available = UserDefaults.standard.string(forKey: "is_image_available") ?? ""
        is_multicategory_available = UserDefaults.standard.string(forKey: "is_multicategory_available") ?? ""
        is_notification_available = UserDefaults.standard.string(forKey: "is_notification_available") ?? ""
        is_quote_available = UserDefaults.standard.string(forKey: "is_quote_available") ?? ""
        is_subscription_enabled = UserDefaults.standard.string(forKey: "is_subscription_enabled") ?? ""
        is_video_available = UserDefaults.standard.string(forKey: "is_video_available") ?? ""
        language_code = UserDefaults.standard.string(forKey: "language_code") ?? ""
        language_name = UserDefaults.standard.string(forKey: "language_name") ?? ""
        push_appid = UserDefaults.standard.string(forKey: "push_appid") ?? ""
        quiz_cat_id = UserDefaults.standard.string(forKey: "quiz_cat_id") ?? ""
        quote_app_id = UserDefaults.standard.string(forKey: "quote_app_id") ?? ""
        short_lang_code = UserDefaults.standard.string(forKey: "short_lang_code") ?? ""
        show_interstitial_row = UserDefaults.standard.string(forKey: "show_interstitial_row") ?? ""
        show_native_ads_row = UserDefaults.standard.string(forKey: "show_native_ads_row") ?? ""
        sub_identifier_lifetime = UserDefaults.standard.string(forKey: "sub_identifier_lifetime") ?? ""
        sub_identifier_oneyear = UserDefaults.standard.string(forKey: "sub_identifier_oneyear") ?? ""
        sub_sharedsecret = UserDefaults.standard.string(forKey: "sub_sharedsecret") ?? ""
        verse_editor_app_id = UserDefaults.standard.string(forKey: "verse_editor_app_id") ?? ""
        video_app_id = UserDefaults.standard.string(forKey: "video_app_id") ?? ""
        wallpaper_cat_id = UserDefaults.standard.string(forKey: "wallpaper_cat_id") ?? ""
        
              
        APPNAME = UserDefaults.standard.string(forKey: "app_name") ?? APPNAME
        
        // Load subscription IDs with fallback to constants if empty
        SUBSCRIPTIONID_LifeTime = UserDefaults.standard.string(forKey: "sub_identifier_lifetime") ?? ""
        if SUBSCRIPTIONID_LifeTime.isEmpty && !hasCachedAPIData {
            SUBSCRIPTIONID_LifeTime = FallbackIAPConstants.lifetimeProductID
        }
        
        SUBSCRIPTIONID_OneYear = UserDefaults.standard.string(forKey: "sub_identifier_oneyear") ?? ""
        if SUBSCRIPTIONID_OneYear.isEmpty && !hasCachedAPIData {
            SUBSCRIPTIONID_OneYear = FallbackIAPConstants.oneYearProductID
        }
        
        SUBSCRIPTIONID_Six_month = UserDefaults.standard.string(forKey: "sub_identifier_six_month") ?? ""
        if SUBSCRIPTIONID_Six_month.isEmpty && !hasCachedAPIData {
            SUBSCRIPTIONID_Six_month = FallbackIAPConstants.sixMonthProductID
        }
        
        SUBSCRIPTIONID_ExitOffer = UserDefaults.standard.string(forKey: "sub_identifier_exit_offer") ?? ""
        if SUBSCRIPTIONID_ExitOffer.isEmpty && !hasCachedAPIData {
            SUBSCRIPTIONID_ExitOffer = FallbackIAPConstants.exitOfferProductID
        }
        
        SHARED_SECRET = UserDefaults.standard.string(forKey: "sub_sharedsecret") ?? ""
        if SHARED_SECRET.isEmpty && !hasCachedAPIData {
            SHARED_SECRET = FallbackIAPConstants.sharedSecret
        }
        IS_SUBSCRIPTION_ENABLE = Int(UserDefaults.standard.string(forKey: "is_subscription_enabled") ?? "") ?? 0
        if IS_SUBSCRIPTION_ENABLE == 0 && !hasCachedAPIData {
            IS_SUBSCRIPTION_ENABLE = FallbackIAPConstants.iapEnabled
        }
        
        
//        UserDefaults.standard.integer(forKey: "is_subscription_enabled")
        
        
        API_MAIN = UserDefaults.standard.string(forKey: "audio_basepath") ?? ""
        if API_MAIN.isEmpty && !hasCachedAPIData {
            API_MAIN = FallbackAudioConstants.audioBasepath
        }
        
        primaryLanguage  = UserDefaults.standard.string(forKey: "text_to_speech_language_code_ios") ?? ""
        if primaryLanguage.isEmpty && !hasCachedAPIData {
            primaryLanguage = FallbackTTSConstants.ttsLanguageCode
        }
        SPEECH_ENABLE = UserDefaults.standard.string(forKey: "is_text_to_speech_available_ios") ?? ""
        if SPEECH_ENABLE.isEmpty && !hasCachedAPIData {
            SPEECH_ENABLE = FallbackTTSConstants.ttsEnabled
        }
        AUDIO_ENABLE = UserDefaults.standard.string(forKey: "is_show_mp3_audio") ?? ""
        if AUDIO_ENABLE.isEmpty && !hasCachedAPIData {
            AUDIO_ENABLE = FallbackAudioConstants.audioEnabled
        }
        
        TSDefaultlanguage = UserDefaults.standard.string(forKey: "text_to_speech_identifier_ios") ?? ""
        if TSDefaultlanguage.isEmpty && !hasCachedAPIData {
            TSDefaultlanguage = FallbackTTSConstants.ttsIdentifier
        }
        app_Audio_path = UserDefaults.standard.string(forKey: "audio_basepath") ?? ""
        if app_Audio_path.isEmpty && !hasCachedAPIData {
            app_Audio_path = FallbackAudioConstants.audioBasepath
        }
        Audio_path_Type = UserDefaults.standard.string(forKey: "audio_basepath_type") ?? ""
        if Audio_path_Type.isEmpty && !hasCachedAPIData {
            Audio_path_Type = FallbackAudioBasepathTypeConstants.audioBasepathType
        }
        COPIRIGHTS_URL = UserDefaults.standard.string(forKey: "copyright_url") ?? ""
        if COPIRIGHTS_URL.isEmpty && !hasCachedAPIData {
            COPIRIGHTS_URL = FallbackCopyrightConstants.copyrightURL
        }
        
        
        
        sub_identifier_oneyear_value = UserDefaults.standard.string(forKey: "sub_identifier_oneyear_value") ?? ""
        sub_identifier_lifetime_value = UserDefaults.standard.string(forKey: "sub_identifier_lifetime_value") ?? ""
        sub_identifier_six_month_value = UserDefaults.standard.string(forKey: "sub_identifier_six_month_value") ?? ""
        
        // Exit offer with fallback
        sub_identifier_exit_offer_value = UserDefaults.standard.string(forKey: "sub_identifier_exit_offer_value") ?? ""
        if sub_identifier_exit_offer_value.isEmpty && !hasCachedAPIData {
            sub_identifier_exit_offer_value = FallbackIAPConstants.exitOfferValue
        }
        
        sub_identifier_exit_offer_item1 = UserDefaults.standard.string(forKey: "sub_identifier_exit_offer_item1") ?? ""
        if sub_identifier_exit_offer_item1.isEmpty && !hasCachedAPIData {
            sub_identifier_exit_offer_item1 = FallbackIAPConstants.exitOfferItem1
        }
        
        sub_identifier_exit_offer_item2 = UserDefaults.standard.string(forKey: "sub_identifier_exit_offer_item2") ?? ""
        if sub_identifier_exit_offer_item2.isEmpty && !hasCachedAPIData {
            sub_identifier_exit_offer_item2 = FallbackIAPConstants.exitOfferItem2
        }
        
        // Log all values with source indication
        print("\n📋 [GetAppInfo] CONFIGURATION VALUES LOADED (\(dataSource)):")
        print("\n📱 IAP Configuration:")
        let iapEnabled = UserDefaults.standard.string(forKey: "is_subscription_enabled") ?? ""
        let iapSource = (hasCachedAPIData) ? "API" : "FALLBACK"
        print("   → IAP Enabled: \(iapEnabled) [\(iapSource)]")
        let lifetimeID = SUBSCRIPTIONID_LifeTime.isEmpty ? "EMPTY" : SUBSCRIPTIONID_LifeTime
        let lifetimeSource = (SUBSCRIPTIONID_LifeTime == FallbackIAPConstants.lifetimeProductID && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → Lifetime Product ID: \(lifetimeID) [\(lifetimeSource)]")
        let oneYearID = SUBSCRIPTIONID_OneYear.isEmpty ? "EMPTY" : SUBSCRIPTIONID_OneYear
        let oneYearSource = (SUBSCRIPTIONID_OneYear == FallbackIAPConstants.oneYearProductID && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → One Year Product ID: \(oneYearID) [\(oneYearSource)]")
        let exitOfferID = SUBSCRIPTIONID_ExitOffer.isEmpty ? "EMPTY" : SUBSCRIPTIONID_ExitOffer
        let exitOfferSource = (SUBSCRIPTIONID_ExitOffer == FallbackIAPConstants.exitOfferProductID && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → Exit Offer Product ID: \(exitOfferID) [\(exitOfferSource)]")
        
        print("\n📢 AD Configuration:")
        let adsType = ADS_TYPE
        let adsTypeSource = (String(adsType) == String(FallbackADConstants.adsEnabled) && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → AD Type (Enable): \(adsType) [\(adsTypeSource)]")
        let ironSourceValue = IRONSOURCE_KEY.isEmpty ? "EMPTY" : IRONSOURCE_KEY
        let ironSourceSource = (IRONSOURCE_KEY == FallbackADConstants.ironSourceKey && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → IronSource Key: \(ironSourceValue) [\(ironSourceSource)]")
        let unityValue = UNITY_KEY.isEmpty ? "EMPTY" : UNITY_KEY
        let unitySource = (UNITY_KEY == FallbackADConstants.unityKey && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → Unity Key: \(unityValue) [\(unitySource)]")
        // Note: Google Ads are not used in this project - logging removed
        
        print("\n🎵 Audio MP3 Bible Configuration:")
        let audioEnabledValue = AUDIO_ENABLE.isEmpty ? "EMPTY" : AUDIO_ENABLE
        let audioEnabledSource = (AUDIO_ENABLE == FallbackAudioConstants.audioEnabled && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → Audio Enabled: \(audioEnabledValue) [\(audioEnabledSource)]")
        let audioBasepathValue = API_MAIN.isEmpty ? "EMPTY" : API_MAIN
        let audioBasepathSource = (API_MAIN == FallbackAudioConstants.audioBasepath && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → Audio Basepath: \(audioBasepathValue) [\(audioBasepathSource)]")
        
        print("\n🗣️ Text to Speech Configuration:")
        let ttsEnabledValue = SPEECH_ENABLE.isEmpty ? "EMPTY" : SPEECH_ENABLE
        let ttsEnabledSource = (SPEECH_ENABLE == FallbackTTSConstants.ttsEnabled && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → TTS Enabled: \(ttsEnabledValue) [\(ttsEnabledSource)]")
        let ttsLanguageValue = primaryLanguage.isEmpty ? "EMPTY" : primaryLanguage
        let ttsLanguageSource = (primaryLanguage == FallbackTTSConstants.ttsLanguageCode && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → TTS Language Code: \(ttsLanguageValue) [\(ttsLanguageSource)]")
        let ttsIdentifierValue = TSDefaultlanguage.isEmpty ? "EMPTY" : TSDefaultlanguage
        let ttsIdentifierSource = (TSDefaultlanguage == FallbackTTSConstants.ttsIdentifier && !hasCachedAPIData) ? "FALLBACK" : (hasCachedAPIData ? "API" : "FALLBACK")
        print("   → TTS Identifier: \(ttsIdentifierValue) [\(ttsIdentifierSource)]")
        print("")
        
        print("📋 [GetAppInfo] CallParams() - Exit offer values loaded:")
        print("   → sub_identifier_exit_offer: '\(SUBSCRIPTIONID_ExitOffer)'")
        print("   → sub_identifier_exit_offer_value: '\(sub_identifier_exit_offer_value)'")
        print("   → sub_identifier_exit_offer_item1: '\(sub_identifier_exit_offer_item1)'")
        print("   → sub_identifier_exit_offer_item2: '\(sub_identifier_exit_offer_item2)'")
        
    }
    
}





//    func SaveMoreinfo(resultDictionary: Dictionary<String, AnyObject>) {
//
//        let dataArray = resultDictionary["data"]! as! Array<Dictionary<String,AnyObject>>
//
//        print("dataArray :",dataArray)
//
//        MORE_LINKS.removeAll()
//        MORE_IMAGE.removeAll()
//        MORE_IMAGES.removeAll()
//
//        for i in 0..<dataArray.count {
//            if dataArray[i].stringValueForKey("apptype") == "ios" {
//                MORE_LINKS.append(dataArray[i].stringValueForKey("appurl"))
//                MORE_IMAGE.append(dataArray[i].stringValueForKey("thumburl_2"))
//            }
//        }
//
//        self.callDOwnload(IMAGEPOsition: 0)
//
//
//
//    }


//    func callDOwnload(IMAGEPOsition:Int) {
//        if IMAGEPOsition < MORE_IMAGE.count {
//            DispatchQueue.main.async {
//                self.downloadIMg(IMAGEPOsition: IMAGEPOsition)
//            }
//        }
//    }
//
//
//    func downloadIMg(IMAGEPOsition:Int) {
//        URLSession.shared.dataTask(with: URL(string: MORE_IMAGE[IMAGEPOsition])!) { (data, response, error) in
//            MORE_IMAGES.append(UIImage(data: data!)!)
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) {
//                self.callDOwnload(IMAGEPOsition:IMAGEPOsition+1)
//            }
//        }.resume()
//    }
//
