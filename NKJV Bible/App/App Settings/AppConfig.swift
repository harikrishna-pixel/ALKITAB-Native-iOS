//
//  AppConfig.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 08/12/22.
//

import UIKit

class AppConfig: NSObject {

}


// MARK: - API Enable / Disable
//let API_Switch = "0"  // API OFF
let API_Switch = "1"  // API ON


// MARK: - APP Config

var APPNAME_SPLASH = "Alkitab Bible"
let APPLE_ID = "1666813160"
var FEEDBACKMAIL = "support@bibleoffice.com"




// MARK: - Duel Language Config


var primaryLanguage  = UserDefaults.standard.string(forKey: "text_to_speech_language_code_ios") ?? "id-ID"
let SecondaryLanguage  = "en-GB"



//let RESPONSE_TYPE = "1"
let RESPONSE_TYPE = "0"



// MARK: - TEXT TO SPEECH Config

var TSDefaultlanguage = UserDefaults.standard.string(forKey: "text_to_speech_identifier_ios") ?? "com.apple.ttsbundle.Samantha-compact/United States [Samantha]"




// MARK: - App type

let APP_TYPE = "1"     // BIBLE WITH SINGLE BOOK
//let APP_TYPE = "2"       // BIBLE WITH DUEL BOOK
//let APP_TYPE = "3"     // BIBLE WITH MULTI BOOK



// MARK: - FALLBACK CONSTANTS (Used when API fails to load)
// ⚠️ DISTRIBUTION TEAM: Update these values according to each app before building

// MARK: - FALLBACK IAP CONSTANTS
struct FallbackIAPConstants {
    // IAP Enable/Disable - 1 = enabled, 0 = disabled
    static let iapEnabled = 1
    
    // Subscription Product Identifiers
    static let lifetimeProductID = "com.bmrbibles.alkitabbibleinindonesian.lifetimeadfree"
    static let oneYearProductID = "com.bmrbibles.alkitabbibleinindonesian.oneyearadfree"
    static let sixMonthProductID = ""  // Six month subscription (if available)
    static let oneMonthProductID = ""  // One month subscription (if available)
    static let threeMonthProductID = ""  // Three month subscription (if available)
    
    // Subscription Values (Discount percentages)
    static let lifetimeValue = "80"  // Lifetime discount percentage
    static let oneYearValue = "50"  // One year discount percentage
    static let sixMonthValue = ""  // Six month discount percentage
    static let oneMonthValue = ""  // One month discount percentage
    static let threeMonthValue = ""  // Three month discount percentage
    
    // Exit Offer Configuration
    static let exitOfferProductID = "com.bmrbibles.alkitabbibleinindonesian.lifetime.exitoffer"
    static let exitOfferItem1 = "Lifetime"  // Plan name
    static let exitOfferItem2 = ""  // Additional exit offer item
    static let exitOfferValue = "30"  // Discount percentage
    
    // Shared Secret for receipt validation
    static let sharedSecret = "b29b9c2ae173439da0c728ec644f952f"
    
    // Coin Pack Product Identifiers (from API sub_fields array)
    static let coinPack1ProductID = "com.bmrbibles.alkitabbibleinindonesian.iapcoinspack1"
    static let coinPack2ProductID = "com.bmrbibles.alkitabbibleinindonesian.iapcoinspack2"
    static let coinPack3ProductID = "com.bmrbibles.alkitabbibleinindonesian.iapcoinspack3"
    
    // Coin Pack Values (Number of coins)
    static let coinPack1Coins = 100  // Coins in pack 1
    static let coinPack2Coins = 300  // Coins in pack 2
    static let coinPack3Coins = 600  // Coins in pack 3
    
    // Coin Pack Discount Values (if applicable)
    static let coinPack1Value = "20"  // Discount percentage for pack 1
    static let coinPack2Value = "20"  // Discount percentage for pack 2
    static let coinPack3Value = "20"  // Discount percentage for pack 3
    
    // Quiz Action Coin Costs (how many coins each action costs)
    static let coin50_50 = 20  // Cost for 50/50 hint
    static let coinHint = 20  // Cost for regular hint
    static let coinShare = 20  // Cost for sharing
    static let coinTimeWait = 20  // Cost for time wait
    static let coinTryAgain = 20  // Cost for try again
    static let coinViewAnswer = 20  // Cost for viewing answer
    
    // Cache keys for storing API data
    static let cacheKeyAPIDataLoaded = "CachedAPIDataLoaded"
    static let cacheKeyLastAPIFetchDate = "LastAPIFetchDate"
}

// MARK: - FALLBACK AD CONSTANTS
struct FallbackADConstants {
    // AD Enable/Disable - 1 = enabled, 0 = disabled
    static let adsEnabled = 1
    
    // Ad Network Keys
    static let ironSourceKey = "19dd3f9fd"
    static let unityKey = "5268630"
    
    // Note: Google Ads are not used in this project - removed from fallback constants
}

// MARK: - FALLBACK AUDIO MP3 BIBLE CONSTANTS
struct FallbackAudioConstants {
    // Audio MP3 Bible Enable/Disable - "1" = enabled, "0" = disabled
    static let audioEnabled = "1"
    
    // Audio Basepath - Set your fallback audio basepath URL here
    static let audioBasepath = "https://bibleoffice.com/BibleReplications/dev/v1/uploads/bible_audio/Indonesian/"
}

// MARK: - FALLBACK TEXT TO SPEECH CONSTANTS
struct FallbackTTSConstants {
    // Text to Speech Enable/Disable - "1" = enabled, "0" = disabled
    static let ttsEnabled = "1"
    
    // TTS Language Code - Set your fallback language code here (e.g., "en-US", "fr-FR")
    static let ttsLanguageCode = "id-ID"
    
    // TTS Identifier - Set your fallback TTS identifier here
    static let ttsIdentifier = "com.apple.ttsbundle.Damayanti-compact"
}

// MARK: - FALLBACK OFFER CONSTANTS
struct FallbackOfferConstants {
    // Offer Enable/Disable - "1" = enabled, "0" = disabled
    static let offerEnabled = "1"  // From API: offer_enabled
    static let offerDays = "10"  // From API: offer_days
    static let offerCount = "100"  // From API: offer_count
}

// MARK: - FALLBACK APP CONFIG CONSTANTS
struct FallbackAppConfigConstants {
    // App Info
    static let appName = "Alkitab Bible"
    static let appShareAppLink = "https://bibleoffice.com/04be135"
    static let appThemeColor = "#31419E"
    static let appTypeVersion = "Smart"
    
    // Feedback
    static let feedbackEmail = "feedback@bibleoffice.com"
    
    // Features Enable/Disable - "1" = enabled, "0" = disabled
    static let isImageAvailable = "1"
    static let isMulticategoryAvailable = "1"
    static let isNotificationAvailable = "1"
    static let isQuoteAvailable = "1"
    static let isVideoAvailable = "0"
    
    // Language
    static let languageCode = "Indonesian"
    static let languageName = ""  // Empty in API response
    static let shortLangCode = ""  // Empty in API response
    
    // Content IDs
    static let imageAppId = "41"
    static let pushAppId = "2"
    static let quizCatId = "174"
    static let quoteAppId = "8"
    static let verseEditorAppId = "317"
    static let videoAppId = "104"
    static let wallpaperCatId = "177"
    
    // Ad Display Settings
    static let showInterstitialRow = "10"
    static let showNativeAdsRow = "20"
    
    // Book Ads
    static let bookAdsStatus = 1  // 0 = disabled, 1 = enabled
    static let bookAdsAppId = 6
}

// MARK: - FALLBACK FACEBOOK ADS CONSTANTS
struct FallbackFacebookAdsConstants {
    static let facebookBannerID = "1004986500697876_1005085504021309"
    static let facebookInterstitialID = "1004986500697876_1005085667354626"
    static let facebookAppID = "1004986500697876"
}

// MARK: - FALLBACK AD DURATION CONSTANTS
struct FallbackAdDurationConstants {
    static let adsDuration = 3  // Ad duration in seconds
}

// MARK: - FALLBACK AUDIO BASEPATH TYPE CONSTANTS
struct FallbackAudioBasepathTypeConstants {
    static let audioBasepathType = "3"  // Default basepath type (from AppConstants.swift default)
}

// MARK: - FALLBACK COPYRIGHT CONSTANTS
struct FallbackCopyrightConstants {
    static let copyrightURL = "https://bibleoffice.com/"
}
