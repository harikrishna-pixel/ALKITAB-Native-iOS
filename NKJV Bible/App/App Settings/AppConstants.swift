//
//  AppConstants.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 11/01/23.
//

import UIKit



#if DEBUG

//  let API_VERIFY_RECEIPT = "https://buy.itunes.apple.com/verifyReceipt"
    let API_VERIFY_RECEIPT = "https://sandbox.itunes.apple.com/verifyReceipt"
    let developerMode = "0"

//
//   MARK: DEVELOPEMENT

var BASEPATH_TYPE = UserDefaults.standard.string(forKey: "BASEPATH_TYPE") ?? "3"
let APP_LINK = "https://itunes.apple.com/app/id\(APPLE_ID)"
var COPIRIGHTS_URL = "https://bibleoffice.com"
let GET_APP_INFO =  "https://bibleoffice.com/BibleReplications/dev/v1/API/getAppInfo.php"                     // get app
let SUBSCRIPTION_API = "https://bibleoffice.com/BibleReplications/dev/v1/API/v2/Subscription/insert"
let APPMODE = "0"



#else

    let API_VERIFY_RECEIPT = "https://buy.itunes.apple.com/verifyReceipt"
//    let API_VERIFY_RECEIPT = "https://sandbox.itunes.apple.com/verifyReceipt"
    let developerMode = "1"


// MARK: PRODUCTION

var BASEPATH_TYPE = UserDefaults.standard.string(forKey: "BASEPATH_TYPE") ?? "3"
let APP_LINK = "https://itunes.apple.com/app/id\(APPLE_ID)"
var COPIRIGHTS_URL = "https://bibleoffice.com"
let SUBSCRIPTION_API = "https://bibleoffice.com/BibleReplications/dev/v1/API/v2/Subscription/insert"
let GET_APP_INFO =  "https://bibleoffice.com/BibleReplications/dev/v1/API/getAppInfo.php"                     // get app
let APPMODE = "1"



#endif




// MARK: - Audio text to speech Enable Disable

var AUDIO_ENABLE = "1"   // AUDIO MP3 ENABLE
var SPEECH_ENABLE = "1"   // TEXT TO SPEECH ENABLE



// MARK: - Advertisement Enable - Disable

//var AD_ENABLE = false


var ADS_TYPE = 1
var IS_SUBSCRIPTION_ENABLE = 1
var MARK_US_READ = true


// MARK: - APP CONFIGS

var APPNAME = "AMP Bible"


// MARK: - Ads Config
//var GOOGLE_ADS_APP_OPEN = UserDefaults.standard.string(forKey: "ads_google_openApp_id_ios") ?? ""
//var GOOGLE_BANNER_ADS = UserDefaults.standard.string(forKey: "ads_google_banner_id_ios") ?? ""
//var GOOGLE_ADS_INTERSTITIAL_ID  = UserDefaults.standard.string(forKey: "ads_google_interstitial_id_ios") ?? ""
//var GOOGLE_ADS_REWARDED = UserDefaults.standard.string(forKey: "ads_google_reward_id_ios") ?? ""
//var GOOGLE_ADS_DEVICE_ID = ""
//var GOOGLE_ADS_TYPE = "1"



var GOOGLE_ADS_DEVICE_ID = ""
var GOOGLE_ADS_TYPE = "1"
var ADS_DURATION = 3
var GOOGLE_ADS_APP_OPEN = ""
var GOOGLE_BANNER_ADS = ""
var GOOGLE_BANNER_ADS_ID2 = ""
var GOOGLE_BANNER_ADS_ID3 = ""
var GOOGLE_ADS_INTERSTITIAL_ID = ""
var GOOGLE_ADS_REWARDED = ""
var GOOGLE_ADS_REWARDED_INTERSTITIAL_ID = ""
var GOOGLE_NATIVE_AD_ID  = ""


var sub_identifier_oneyear_value = ""
var sub_identifier_lifetime_value = ""
var sub_identifier_six_month_value = ""
var sub_identifier_exit_offer_value = ""
var sub_identifier_exit_offer_item1 = ""
var sub_identifier_exit_offer_item2 = ""



// MARK: - IRON SOURC
var IRONSOURCE_KEY = ""
var FIREBASE_ENABLE = true


// MARK: - UNITY SOURC
var UNITY_KEY = "5268630"
let UNITY_TEST_MODE = true




// MARK: - Flurry Key
let flurryKey = ""



// MARK: - SUBSCRIPTION

var SUBSCRIPTIONID_LifeTime = ""
var SUBSCRIPTIONID_OneYear = ""
var SUBSCRIPTIONID_Six_month = ""
var SUBSCRIPTIONID_ExitOffer = ""
var AppGroup_ID = ""
var SHARED_SECRET = ""



// MARK: COMMON LINK


var API_MAIN = ""
let UPDATE_DEVICE_ID = "https://bibleoffice.com/BibleReplications/dev/v1/API/UpdateDeviceToIOS.php"
let POST_SUBSCRIPTION_RECEIPT_DATA = "https://bibleoffice.com/BibleReplications/dev/v1/API/v2/Subscription/insert"
let GET_SUBSCRIPTION_RECEPT_DATA = " https://bibleoffice.com/BibleReplications/dev/v1/API/v2/Subscription/getReceipt_data"
let VIEWED_PUSH_NOTIFICATION  = "https://bibleoffice.com/BibleReplications/dev/v1/API/ViewedPushNotifyToIOS.php"
let GETMOREAPPLIST = "https://bibleoffice.com/BibleReplications/dev/v1/API/getMoreAppList.php"



// MARK: - OTHER LINKS
let PrivacyURL = "https://bibleoffice.com/privacy_policy.html"
let TermsURL = "https://bibleoffice.com/terms_conditions.html"
let feedback_form = "https://bibleoffice.com/m_feedback/API/feedback_form/index.php"
let moreLink  = "https://apps.apple.com/in/developer/anandhaprabakaran-balasubramaniyan/id1660935968"
let FAQ = "https://bibleoffice.com/biblefaq.html"




class AppConstants: NSObject {

}


let SUBSCRIPTION_INSERT = "https://bibleoffice.com/BibleReplications/dev/v1/API/v2/Subscription/insert"
let SUBSCRIPTION_GETRECREPT = "https://bibleoffice.com/BibleReplications/dev/v1/API/v2/Subscription/getReceipt_data"



let PrimaryColor:UIColor = UIColor(red: 28.0 / 255.0, green: 70.0 / 255.0, blue: 178.0 / 255.0, alpha: 1.0)//#1c46b2
let BGNightMode:UIColor = UIColor(red: 52.0 / 255.0, green: 57.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)
let DefaultYellow:UIColor = UIColor(red: 255.0 / 255.0, green: 215.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
let DarkModeColor:UIColor = UIColor(red: 45.0 / 255.0, green: 45.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
let SpeechColor:UIColor = UIColor(red: 223.0 / 255.0, green: 255.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
let SettingTitleColor:UIColor = UIColor(red: 154.0 / 255.0, green: 154.0 / 255.0, blue: 154.0 / 255.0, alpha: 1.0) // 434343
let SettingTitleBG:UIColor = UIColor(red: 217.0 / 255.0, green: 217.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0) // D9D9D9
let LibraryTitleColor:UIColor = UIColor(red: 175.0 / 255.0, green: 175.0 / 255.0, blue: 175.0 / 255.0, alpha: 1.0) // D9D9D9

let ProgressBarGray:UIColor = UIColor(red: 222.0 / 255.0, green: 222.0 / 255.0, blue: 222.0 / 255.0, alpha: 1.0)





let GradienColor1:UIColor = UIColor(red: 14.0 / 255.0, green: 35.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
let GradienColor2:UIColor = UIColor(red: 28.0 / 255.0, green: 70.0 / 255.0, blue: 178.0 / 255.0, alpha: 1.0)



// MARK: Statusbar height and device Height - width

let StatusbarHeight = UIApplication.shared.statusBarFrame.size.height

let screenSize: CGSize = UIScreen.main.bounds.size
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height




let AdCatagory = ["INTERSTITIAL", "REWARDED", "NATIVE"]
var LastClickCount = UserDefaults.standard.integer(forKey: "LastClickCount")
var WallpaperAds = UserDefaults.standard.integer(forKey: "WallpaperAds")

var OpenAdLoaded = true

// Statusbar Size

//if #available(iOS 13.0, *) {
//    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//    statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//} else {
//    statusBarHeight = UIApplication.shared.statusBarFrame.height
//}





// MARK:  Storyboard and device
var kStoryboardMainIphone = UIStoryboard(name: "Main", bundle: nil)
var kStoryboardQuizIphone = UIStoryboard(name: "QuizStoryboard", bundle: nil)
var kStoryboardImageIphone = UIStoryboard(name: "ImageMain", bundle: nil)



let kIpad = UIDevice.current.userInterfaceIdiom == .pad
let kIphone = UIDevice.current.userInterfaceIdiom == .phone
let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
let CurrentIdiom = UIDevice.current.userInterfaceIdiom



// MARK:  Coredata Endities
let CDBookSavedInfo = "BookSavedInfo"
let CDDailyVerses = "DailyVerses"
let CDBookListAPI = "BookListAPI"
let CDPaymentdateAPI = "Paymentdate"
let CDGetAppInfos = "GetAppInfos"
let CDSpeechSetting = "SpeechSetting"
let CDMarkAsRead = "MarkAsRead"
let CDMoreBookApi = "MoreBookApi"
let CDMoreAppApi = "MoreAppApi"
let CDVerseExplanation = "VerseExplanation"
let ExplanationRecordDelimiter = "|||"



let DefaultBookName = BibleContent.sharedInstance.BookToPosition()[0].components(separatedBy: "-")[0]





// MARK: - FONT

let APPFONT = "Arial"


// MARK: - APP Colors

let HighlightColors = ["bddffa", "fffac3", "fabbd0", "c3e0c4", "fed6b2", "fe9798", "e7b9f8", "86dacb"]




// MARK: - Mobile info

let Country_code  = Locale.current.regionCode! as String
let language = Locale.current.languageCode! as String
let Udid  = UIDevice.current.identifierForVendor!.uuidString
let deviceVersion =  UIDevice.current.systemVersion
let appVersion  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
let devicename  = UIDevice.modelName
let platform  = UIDevice.current.systemName
let bundleID = Bundle.main.bundleIdentifier! as String
let dev_id_type = "iOS" as String
var Subscription_Status = "1"
var wallpaper_id = "177"
var NightModeStatus = "0"

// MARK: - IRON SOURC
var IRONSOURCE_ENABLE = true


// MARK: - UNITY ADS
var UNITY_ENABLE = true


var HomeVerseImage = "S\(Int.random(in: 1..<9)).jpg"

// MARK: - AD ID'S

var ads_duration = UserDefaults.standard.string(forKey: "ads_duration") ?? ""

 // Google Ads
var ads_google_banner_id_ios = UserDefaults.standard.string(forKey: "ads_google_banner_id_ios") ?? ""
var ads_google_interstitial_id_ios = UserDefaults.standard.string(forKey: "ads_google_interstitial_id_ios") ?? ""
var ads_google_native_id_ios = UserDefaults.standard.string(forKey: "ads_google_native_id_ios") ?? ""
var ads_google_openApp_id_ios = UserDefaults.standard.string(forKey: "ads_google_openApp_id_ios") ?? ""
var ads_google_reward_id_ios = UserDefaults.standard.string(forKey: "ads_google_reward_id_ios") ?? ""


// FaceBook
var ads_facebook_interstitial_id_ios = UserDefaults.standard.string(forKey: "ads_facebook_interstitial_id_ios") ?? ""
var ads_facebook_banner_id_ios = UserDefaults.standard.string(forKey: "ads_facebook_banner_id_ios") ?? ""
var ads_facebook_app_id_ios = UserDefaults.standard.string(forKey: "ads_facebook_app_id_ios") ?? ""


var ads_network_1_field_1_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_1_ios") ?? ""
var ads_network_1_field_2_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_2_ios") ?? ""
var ads_network_1_field_3_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_3_ios") ?? ""
var ads_network_1_field_4_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_4_ios") ?? ""
var ads_network_1_field_5_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_5_ios") ?? ""
var ads_network_1_field_6_ios = UserDefaults.standard.string(forKey: "ads_network_1_field_6_ios") ?? ""
var ads_network_2_field_1_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_1_ios") ?? ""
var ads_network_2_field_2_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_2_ios") ?? ""
var ads_network_2_field_3_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_3_ios") ?? ""
var ads_network_2_field_4_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_4_ios") ?? ""
var ads_network_2_field_5_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_5_ios") ?? ""
var ads_network_2_field_6_ios = UserDefaults.standard.string(forKey: "ads_network_2_field_6_ios") ?? ""


// MARK: APP CONFIGS


var offer_enabled = UserDefaults.standard.string(forKey: "offer_enabled") ?? ""
var offer_days = UserDefaults.standard.string(forKey: "offer_days") ?? "9"
var offer_count = UserDefaults.standard.string(forKey: "offer_count") ?? "100"
var book_ads_status = UserDefaults.standard.integer(forKey: "book_ads_status")
var book_ads_app_id = UserDefaults.standard.integer(forKey: "book_ads_app_id")


var app_shareapp_link = UserDefaults.standard.string(forKey: "app_shareapp_link") ?? ""
var app_theme_color = UserDefaults.standard.string(forKey: "app_theme_color") ?? ""
var app_type_version = UserDefaults.standard.string(forKey: "app_type_version") ?? ""

var image_app_id = UserDefaults.standard.string(forKey: "image_app_id") ?? ""
var is_image_available = UserDefaults.standard.string(forKey: "is_image_available") ?? ""
var is_multicategory_available = UserDefaults.standard.string(forKey: "is_multicategory_available") ?? ""
var is_notification_available = UserDefaults.standard.string(forKey: "is_notification_available") ?? ""
var is_quote_available = UserDefaults.standard.string(forKey: "is_quote_available") ?? ""
var is_subscription_enabled = UserDefaults.standard.string(forKey: "is_subscription_enabled") ?? ""
var is_video_available = UserDefaults.standard.string(forKey: "is_video_available") ?? ""
var language_code = UserDefaults.standard.string(forKey: "language_code") ?? ""
var language_name = UserDefaults.standard.string(forKey: "language_name") ?? ""
var push_appid = UserDefaults.standard.string(forKey: "push_appid") ?? ""
var quiz_cat_id = UserDefaults.standard.string(forKey: "quiz_cat_id") ?? ""
var quote_app_id = UserDefaults.standard.string(forKey: "quote_app_id") ?? ""
var short_lang_code = UserDefaults.standard.string(forKey: "short_lang_code") ?? ""
var show_interstitial_row = UserDefaults.standard.string(forKey: "show_interstitial_row") ?? ""
var show_native_ads_row = UserDefaults.standard.string(forKey: "show_native_ads_row") ?? ""
var sub_identifier_lifetime = UserDefaults.standard.string(forKey: "sub_identifier_lifetime") ?? ""
var sub_identifier_oneyear = UserDefaults.standard.string(forKey: "sub_identifier_oneyear") ?? ""
var sub_sharedsecret = UserDefaults.standard.string(forKey: "sub_sharedsecret") ?? ""
var verse_editor_app_id = UserDefaults.standard.string(forKey: "verse_editor_app_id") ?? ""
var video_app_id = UserDefaults.standard.string(forKey: "video_app_id") ?? ""
var wallpaper_cat_id = UserDefaults.standard.string(forKey: "wallpaper_cat_id") ?? ""



var PriceTag1 = UserDefaults.standard.string(forKey: "PriceTag1") ?? ""
var PriceTag2 = UserDefaults.standard.string(forKey: "PriceTag2") ?? ""
var PriceTag3 = UserDefaults.standard.string(forKey: "PriceTag3") ?? ""


var iapProduct1 = UserDefaults.standard.array(forKey: "iapProduct1") ?? []
var iapProduct2 = UserDefaults.standard.array(forKey: "iapProduct2") ?? []
var iapProduct3 = UserDefaults.standard.array(forKey: "iapProduct3") ?? []



// Audio info
var app_Audio_path = UserDefaults.standard.string(forKey: "audio_basepath") ?? ""
var Audio_path_Type = UserDefaults.standard.string(forKey: "audio_basepath_type") ?? ""



let Imagesize = UIScreen.main.bounds.height-288



var ADeviceId = ["03F47EAC-B32F-4290-8B4C-F13A72E682EE", "F6839327-BDD9-49E3-8F37-3A8C1F588033"]



var MORE_LINKS:[String] = ["https://apps.apple.com/app/id6449416368", "https://apps.apple.com/app/id6448658446", "https://apps.apple.com/app/id1666870636"]
var MORE_IMAGE:[String] = []
var MORE_IMAGES:[UIImage] = []


var TabImg = false
