//
//  AppDelegate.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 08/12/22.
//

import UIKit
import CoreData
import CoreSpotlight
import UserNotifications
import Flurry_iOS_SDK
import IQKeyboardManager
import AppTrackingTransparency
import Firebase
import GoogleSignIn


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var navController : UINavigationController?
    var window: UIWindow?
    var DeviceNotificationToken: String = ""
    let notificationCenter = UNUserNotificationCenter.current()
    let gcmMessageIDKey = "gcm.message_id"
    var NotificationDayCount:Int = 0
    
    
    var AlertTitle:Array<String> = []
    var AlertContent:Array<String> = []
    
    var shiftLoad1:Bool = true
    var shiftLoad2:Bool = true
    var shiftLoad3:Bool = true
    
//    Text_List.sharedInstance.AlertList()
    
    
    var gViewController: UIViewController?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        
        if FIREBASE_ENABLE {
            FirebaseApp.configure()
        }
        
        if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
            UserDefaults.standard.set(1, forKey: "Verses")
        }
        
        if UserDefaults.standard.integer(forKey: "NotifiVerses") >= 563 {
            UserDefaults.standard.set(1, forKey: "NotifiVerses")
        }
        
        
        IQKeyboardManager.shared().isEnabled = true
           window?.overrideUserInterfaceStyle = .light
         
        
        if UserDefaults.standard.string(forKey: "LastOpenedDate") == nil {
            UserDefaults.standard.setValue(Date().string(format: "dd-MM-yyyy"), forKey: "LastOpenedDate")
        }
        
        
        if UserDefaults.standard.integer(forKey: "Verses")+6 >= UserDefaults.standard.integer(forKey: "NotifiVerses") {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Verses"), forKey: "NotifiVerses")
            let skipLaunchPrompt = (UserDefaults.standard.string(forKey: "AppOpenFirst") ?? "0") == "0"
                || OnboardingProgress.shouldShow
            if !skipLaunchPrompt {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) {
                    AppDelegate().onRegisterPushNotification()
                }
            }
        }

        let isFirstOpen = UserDefaults.standard.string(forKey: "AppOpenFirst") ?? "0" == "0"
        let deferNotificationPrompt = isFirstOpen || OnboardingProgress.shouldShow

        if deferNotificationPrompt {
            DispatchQueue.main.async {
                if isFirstOpen {
                    UserDefaults.standard.setValue(Date().OneDay.string(format: "dd-MM-yyyy"), forKey: "RateDate")
                    UserDefaults.standard.set("1", forKey: "NotifiStatue")
                    UserDefaults.standard.setValue(4, forKey: "PerDay")
                    UserDefaults.standard.setValue(true, forKey: "Shift1ON")
                    UserDefaults.standard.setValue(true, forKey: "Shift2ON")
                    UserDefaults.standard.setValue(true, forKey: "Shift3ON")
                    UserDefaults.standard.setValue(true, forKey: "Shift4ON")
                    if UserDefaults.standard.string(forKey: "Shift 1") == nil {
                        UserDefaults.standard.set("08:00", forKey: "Shift 1")
                    }
                    if UserDefaults.standard.string(forKey: "Shift 2") == nil {
                        UserDefaults.standard.set("16:00", forKey: "Shift 2")
                    }
                    if UserDefaults.standard.string(forKey: "Shift 3") == nil {
                        UserDefaults.standard.set("20:00", forKey: "Shift 3")
                    }
                    if UserDefaults.standard.string(forKey: "Shift 4") == nil {
                        UserDefaults.standard.set("14:00", forKey: "Shift 4")
                    }

                    if UserDefaults.standard.bool(forKey: "LoadData") == false {
                        App_Protocol.DelegateSplash?.LoadData()
                        UserDefaults.standard.setValue(true, forKey: "LoadData")
                    }

                    self.app_INfo()
                }
            }
        } else {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                
                if let error = error {
                    print("error : \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                        if UserDefaults.standard.string(forKey: "AppOpenFirst") ?? "0" == "0" {
                            UserDefaults.standard.setValue(Date().OneDay.string(format: "dd-MM-yyyy"), forKey: "RateDate")
                            
                            UserDefaults.standard.set("1", forKey: "NotifiStatue")
                            UserDefaults.standard.setValue(4, forKey: "PerDay")
                            
                            UserDefaults.standard.setValue(true, forKey: "Shift1ON")
                            UserDefaults.standard.setValue(true, forKey: "Shift2ON")
                            UserDefaults.standard.setValue(true, forKey: "Shift3ON")
                            UserDefaults.standard.setValue(true, forKey: "Shift4ON")
                            if UserDefaults.standard.string(forKey: "Shift 1") == nil {
                                UserDefaults.standard.set("08:00", forKey: "Shift 1")
                            }
                            if UserDefaults.standard.string(forKey: "Shift 2") == nil {
                                UserDefaults.standard.set("16:00", forKey: "Shift 2")
                            }
                            if UserDefaults.standard.string(forKey: "Shift 3") == nil {
                                UserDefaults.standard.set("20:00", forKey: "Shift 3")
                            }
                            if UserDefaults.standard.string(forKey: "Shift 4") == nil {
                                UserDefaults.standard.set("14:00", forKey: "Shift 4")
                            }
                            
                            AppDelegate().onRegisterPushNotification()
                            
                                if UserDefaults.standard.bool(forKey: "LoadData") == false {
                                    App_Protocol.DelegateSplash?.LoadData()
                                    UserDefaults.standard.setValue(true, forKey: "LoadData")
                                }
                            
                            self.app_INfo()
                            
                        }
                    }
                }
            }
        }
        
        if UserDefaults.standard.string(forKey: "AppOpenFirst") ?? "0" == "1" {
            DispatchQueue.main.async {
                self.app_INfo()
            }
        }

        
    
        
        
        notificationCenter.delegate = self // Local notification config
//        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
//        notificationCenter.requestAuthorization(options: options) {
//            (didAllow, error) in
//            if !didAllow {
//                
//            }
//        }
//        
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3.5) {
//            print("UNITY_KEY :",UNITY_KEY)
//
//            UnityAds.initialize(UNITY_KEY, testMode: UNITY_TEST_MODE)
//            if PaymentHistory.sharedInstance.paymentInfo() {
//                    AdmobManager.shared.requestAds()
//                    AdmobManager.shared.IronSource_Interstitial_AdLoad()
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.5) {
//                    AdmobManager.shared.requestRewardAds()
//                    AdmobManager.shared.IronSource_Reward_AdLoad()
//                }
//            }
//        }
       
            
        return true
        
    }
    

    
    
    
    func registerForPushNotifications(application: UIApplication) {

      if #available(iOS 10.0, *){
          UNUserNotificationCenter.current().delegate = self
          UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
              if (granted)
              {
                  DispatchQueue.main.async {
                      UIApplication.shared.registerForRemoteNotifications()
                  }
              }
              else {
                  
              }
          })
      }
      else { //If user is not on iOS 10 use the old methods we've been using
          let notificationSettings = UIUserNotificationSettings(
              types: [.badge, .sound, .alert], categories: nil)
          application.registerUserNotificationSettings(notificationSettings)

      }

  }
    
    
    
//    func applicationDidBecomeActive(_ application: UIApplication) {
//
//        let rootViewController = application.windows.first(
//          where: { $0.isKeyWindow })?.rootViewController
//        if let rootViewController = rootViewController {
//          if UserDefaults.standard.string(forKey: "AppOpenFirst") ?? "0" == "1" {
//              AppOpenAdManager.shared.showAdIfAvailable(viewController: rootViewController)
//          }
//        }
//    }
//
//
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let rootViewController = application.windows.first(
            where: { $0.isKeyWindow })?.rootViewController
        if let rootViewController = rootViewController {
        }

    }

    
    
    //  MARK: Notification
    
         func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
             self.DeviceNotificationToken = self.extractTokenFromData(deviceToken: deviceToken)
        }
    
        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Failed to register for notifications: \(error.localizedDescription)")
        }
    

        func extractTokenFromData(deviceToken:Data) -> String {
            let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
            return token.uppercased();
        }
    
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//
//      let dataDict:[String: String] = ["token": fcmToken ?? ""]
//
//        print("dataDict :",dataDict)
//
//    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      
      if let messageID = userInfo[gcmMessageIDKey] {
        
      }
      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    

    
    func VersCall() -> String {
        if let path = Bundle.main.path(forResource: "dailyVerse", ofType: "json") {
            do {
                
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  let jsonOutput = jsonResult as! Array<AnyObject>
                                          
                
                if UserDefaults.standard.integer(forKey: "NotifiVerses") >= 563 {
                    UserDefaults.standard.setValue(1, forKey: "NotifiVerses")
                }
                
                
                var VersePosition = (UserDefaults.standard.integer(forKey: "Verses") == 0 ? UserDefaults.standard.integer(forKey: "Verses") :UserDefaults.standard.integer(forKey: "NotifiVerses"))
                
                  let VerseInfo = jsonOutput[UserDefaults.standard.integer(forKey: "NotifiVerses")]
                  var MessageTitleAndMsg = ""
                  var VerseDate = ""

                
                
                  let chapterList =  BibleContent.sharedInstance.AudioBibleListJson(selecterBookName: VerseInfo["Book"] as! String, selectedId: VerseInfo["Chapter"] as! Int-1, bookNameID: VerseInfo["Book_Id"] as! Int)
                
                  var verse = VerseInfo["Verse"] as! String
                  let BookId = VerseInfo["Book_Id"] as! Int
                  let BookName = BibleContent.sharedInstance.BookToPosition()[BookId-1].components(separatedBy: "-")
                  let bookChapterId = "\(BookName[0]) \(VerseInfo["Chapter"] as! Int):\(verse)"
                 
                
                if VerseDate == "" {
                    VerseDate = Date().string(format: "MMM d, yyyy")
                }
                
                if verse.contains("--") {
                    var verseArray = verse.components(separatedBy: "--")
                    
                    if Int(verseArray[0])! > chapterList.count {
                        verseArray[0] = String(chapterList.count-1)
                    }
                    if Int(verseArray[1])! > chapterList.count {
                        verseArray[1] = String(chapterList.count-1)
                    }
                    let verseText = String(format: "%@\n%@",chapterList[Int(verseArray[0])!-1],chapterList[Int(verseArray[1])!-1])
                    MessageTitleAndMsg = "\(verseText)_\(bookChapterId)"

                } else {
                    
                    if Int(verse)! > chapterList.count {
                        verse = String(chapterList.count-1)
                    }
                    
                    MessageTitleAndMsg =  "\(chapterList[Int(verse)!-1])_\(bookChapterId)"
                }
                
                
                if UserDefaults.standard.integer(forKey: "NotifiVerses") >= 563 {
                    VersePosition = 0
                }
                UserDefaults.standard.set(VersePosition+1, forKey: "NotifiVerses")
                UserDefaults.standard.set("1", forKey: "NotifiCellStatus")
                NotificationCenter.default.post(name: Notification.Name("ReloadTable"), object: nil)
                
                return MessageTitleAndMsg
                
              } catch {
                   // handle error
            }
        } else {
            return ""
        }
        return ""
    }
    
    
    
    func createNotifications(userInfo: AnyObject) {
//        let navVC = self.window?.rootViewController as! UINavigationController
        if #available(iOS 13.4, *) {

            var readdata = userInfo as! String

            if readdata.contains("_") {
                readdata = userInfo.components(separatedBy: "_")[1]
            }

            UserDefaults.standard.set(readdata, forKey: "readdata")
            App_Protocol.delegateReaderSource?.navigateToSelectedVerse()
            
            print("readdata :",readdata)
            
//        let addUserVC = kStoryboardMainIphone.instantiateViewController(withIdentifier: "BiblePageSwipeViewController") as! BiblePageSwipeViewController
//        navVC.pushViewController(addUserVC, animated: true)

        }
    }
    
    
    
    
    
    // MARK: API
    
    func UpdateNotifications() {
        
          let dic:Dictionary<String, AnyObject> = ["dev_app_id": push_appid as AnyObject,
                                                  "dev_id_type":"2" as AnyObject,
                                                  "appDeviceToken": self.DeviceNotificationToken  as AnyObject,
                                                  "appDeviceId":Udid as AnyObject,
                                                  "userid":Udid as AnyObject,
                                                  "country_code": Country_code as AnyObject,
                                                  "language": language as AnyObject,
                                                  "appDevice": platform as AnyObject,
                                                  "deviceVersion": deviceVersion as AnyObject,
                                                  "appVersion":appVersion  as AnyObject,
                                                  "appName":APPNAME as AnyObject,
                                                  "appmode": APPMODE as AnyObject,
                                                  "devicename": devicename as AnyObject,
                                                  "package_name" : bundleID as AnyObject]
                
                        
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            NetworkManager.sharedInstance.requestPOSTTestData(urlString: UPDATE_DEVICE_ID,params:dic) { (resultDictionary, error) -> () in
                    if resultDictionary != nil {
                         print("resultDictionary :",resultDictionary)
                    } else {
                        print("error :",error?.localizedDescription)
                    }
                }
           }
    }
    

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
//    func UpdateMoreApp() {
//
//
//        let dic:Dictionary<String, AnyObject> = ["package_name": APPLE_ID as AnyObject]
//
//        if NetworkManager.sharedInstance.isConnectedToInternet() {
//            NetworkManager.sharedInstance.requestPOSTGETData(urlString: GETMOREAPPLIST,params:dic,  completion:
//                { (resultDictionary, error) -> () in
//                    if resultDictionary != nil {
//                        GetAppInfo.shared.SaveMoreinfo(resultDictionary: resultDictionary!)
//                    }
//                })
//        }
//
//    }
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    func app_INfo() {
        
     let dic:Dictionary<String, AnyObject> = ["ios_bundle_id": bundleID as AnyObject,
                                              "ios_apple_id": APPLE_ID as AnyObject,
                                              "response_type": RESPONSE_TYPE as AnyObject]

    if NetworkManager.sharedInstance.isConnectedToInternet() {
        NetworkManager.sharedInstance.requestPOSTGETData(urlString: GET_APP_INFO,params:dic,  completion:
            { (resultDictionary, error) -> () in
                if resultDictionary != nil {


                    if API_Switch == "1" {
                        if NetworkManager.sharedInstance.isConnectedToInternet() {
                            GetAppInfo.shared.SaveAppinfo(resultDictionary: resultDictionary!)
                            GetAppInfo.shared.CallParams()
                            self.UpdateNotifications()
//                            self.UpdateMoreApp()
                        }

                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3.5) {
                                    UnityAdClass.sharedInstance.initializeIfNeeded()
                                    AdmobManager.shared.IronSource_Interstitial_AdLoad()
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.5) {
                                    AdmobManager.shared.IronSource_Reward_AdLoad()
                                }
                        }



                    }
                } else {
                    // API call failed or returned nil - use fallback
                    print("⚠️ [AppDelegate] API call failed or returned nil")
                    print("   → Error: \(error?.localizedDescription ?? "Unknown error")")
                    print("   → Loading fallback or cached data...")
                    if API_Switch == "1" {
                        GetAppInfo.shared.loadFallbackOrCachedData()
                        UnityAdClass.sharedInstance.initializeIfNeeded()
                    }
                }
            })
    } else {
        // No internet connection - use fallback or cached data
        print("⚠️ [AppDelegate] No internet connection")
        print("   → Loading fallback or cached data...")
        if API_Switch == "1" {
            GetAppInfo.shared.loadFallbackOrCachedData()
            UnityAdClass.sharedInstance.initializeIfNeeded()
        }
    }
}
    
    
    

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "NKJV_Bible")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}





@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
      
      DispatchQueue.global(qos: .background).async {
          DispatchQueue.main.async {
              
              
              switch UIApplication.shared.applicationState {
              case .active:
                  UserDefaults.standard.setValue(true, forKey: "Saved")
                  CoreDataModel.sharedInstance.coreDataInsertNotification(CDDailyVerses, book: notification.request.content.title, verseDate: Date().string(format: "MMM d, yyyy"), verse: notification.request.content.body)
                  break
              case .inactive:
                  DispatchQueue.background(delay: 0.2, completion:{
                      UserDefaults.standard.setValue(true, forKey: "Saved")
                      CoreDataModel.sharedInstance.coreDataInsertNotification(CDDailyVerses, book: notification.request.content.title, verseDate: Date().string(format: "MMM d, yyyy"), verse: notification.request.content.body)
                  })
                  break
              case .background:
                  DispatchQueue.background(delay: 0.2, completion:{
                      UserDefaults.standard.setValue(true, forKey: "Saved")
                      CoreDataModel.sharedInstance.coreDataInsertNotification(CDDailyVerses, book: notification.request.content.title, verseDate: Date().string(format: "MMM d, yyyy"), verse: notification.request.content.body)
                  })
                  break
              default:
                  break
              }
              
              
              let bookNdVerse = "\(notification.request.content.body)_\(notification.request.content.title)"
              
              
              
              NotificationCenter.default.post(name: Notification.Name.didReceiveNotification, object: nil)
              
              
              
              let VersePosition = UserDefaults.standard.integer(forKey: "Verses")
//              UserDefaults.standard.set(VersePosition+1, forKey: "Verses")
              
              App_Protocol.delegateDailyVerse?.reloadDailyVerse()
          }
      }
    
    completionHandler([[.alert, .sound]])
  }

    
    
    
   
    
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    var Versetitle = response.notification.request.content.title
    
        if Versetitle.contains("--") {
            let verseArray = Versetitle.components(separatedBy: "--")
            Versetitle = verseArray[0]
        }
        
      
      
      
      saveToSharedDefaults(value: response.notification.request.content.body)
      
      if Versetitle != "Verse Of The Day" {
          App_Protocol.delegateReader?.NavigateToQuiz()
      }
      
//      else {
//          createNotifications(userInfo: Versetitle as AnyObject)
//      }
    
    
    
    completionHandler()
  }
    
    
    func saveToSharedDefaults(value: String) {
           if let defaults = UserDefaults(suiteName: "group.com.bmrbibles.biblenewlivingtranslation") {
               defaults.set(value, forKey: "VerseString")
           }
       }
    
    
}


extension AppDelegate {
    
    
    func onRegisterPushNotification() {
                 
        Text_List.sharedInstance.AlertList()
        self.AlertTitle  = Text_List.sharedInstance.AlertTitle
        self.AlertContent = Text_List.sharedInstance.AlertContent
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                
                //----------------- Testing Purpose ---------------------------------
                UserDefaults.standard.set(0.0, forKey: "LastNotificationTime")

                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                //-------------------------------------------------------
                self.onSetLocalNotification()
           
                print(success)
              
                
            } else {
                UserDefaults.standard.setValue(false, forKey: "Shift1ON")
                UserDefaults.standard.setValue(false, forKey: "Shift2ON")
                UserDefaults.standard.setValue(false, forKey: "Shift3ON")
                UserDefaults.standard.setValue(false, forKey: "Shift4ON")
            }
            
             if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func onSetLocalNotification()
    {
        
        let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests(completionHandler: { requests in
                
                if(requests.count == 0)
                {
                    self.onLoadNotificationContent()
                        
                }
                else if (requests.count >= 40)
                {
                    return;
                }
                else
                {
                    self.onLoadNotificationContent()
                }
            })
    }
    
    func onLoadNotificationContent() {
        DispatchQueue.main.async {
            // Schedule each enabled shift sequentially so LastNotificationTimeN advances
            // day-by-day (parallel delay races caused only one slot per shift to stick).
            self.scheduleShiftIfEnabled(
                enabledKey: "Shift1ON",
                timeKey: "Shift 1",
                defaultTime: "08:00",
                lastTimeKey: "LastNotificationTime1",
                quizTime: false
            )
            self.scheduleShiftIfEnabled(
                enabledKey: "Shift2ON",
                timeKey: "Shift 2",
                defaultTime: "16:00",
                lastTimeKey: "LastNotificationTime2",
                quizTime: false
            )
            self.scheduleShiftIfEnabled(
                enabledKey: "Shift3ON",
                timeKey: "Shift 3",
                defaultTime: "20:00",
                lastTimeKey: "LastNotificationTime3",
                quizTime: false
            )
            self.scheduleShiftIfEnabled(
                enabledKey: "Shift4ON",
                timeKey: "Shift 4",
                defaultTime: "14:00",
                lastTimeKey: "LastNotificationTime4",
                quizTime: true
            )
            
          
            
            
            
            
//            if UserDefaults.standard.bool(forKey: "Shift1ON") {
//                UserDefaults.standard.set(0.0, forKey: "LastNotificationTime")
//                ShiftTime = UserDefaults.standard.string(forKey: "Shift 1") ?? "08:00"
//                for _ in 0 ..< 5 {
//                    self.NotificationCall(ShiftTm: ShiftTime)
//                }
//            }
            
//            if UserDefaults.standard.bool(forKey: "Shift2ON") {
//                UserDefaults.standard.set(0.0, forKey: "LastNotificationTime")
//                ShiftTime = UserDefaults.standard.string(forKey: "Shift 2") ?? "16:00"
//                for _ in 0 ..< 5 {
//                    self.NotificationCall(ShiftTm: ShiftTime)
//                }
//            }
            
//            if UserDefaults.standard.bool(forKey: "Shift3ON") {
//                UserDefaults.standard.set(0.0, forKey: "LastNotificationTime")
//                ShiftTime = UserDefaults.standard.string(forKey: "Shift 3") ?? "20:00"
//                for _ in 0 ..< 5 {
//                    self.NotificationCall(ShiftTm: ShiftTime)
//                }
//            }
            
//            if UserDefaults.standard.bool(forKey: "Shift4ON") {
//                UserDefaults.standard.set(0.0, forKey: "LastNotificationTime")
//                ShiftTime = UserDefaults.standard.string(forKey: "Shift 4") ?? "14:00"
//                for _ in 0 ..< 5 {
//                    self.NotificationCall(ShiftTm: ShiftTime, QuizTime:true)
//                }
//            }
        }
        
        
        
        
        
        
            
//        if ShiftTime.count != 5 {
//            ShiftTime = DateConfig.shared.dateTimeChangeFormat(str: ShiftTime, inDateFormat:  "hh:mm a", outDateFormat: "HH:mm")
//        }
//
//
//
//        let hour : Int? = Int(ShiftTime.components(separatedBy: ":")[0])
//        let min : Int? = Int(ShiftTime.components(separatedBy: ":")[1])
//
//        var lastNotificationTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "LastNotificationTime"))
//
//        if (UserDefaults.standard.double(forKey: "LastNotificationTime") == 0) {
//
//            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
//            let now = NSDate()
//            var components = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: now as Date)
//            components.hour = hour
//            components.minute = min
//            components.second = 0
//            let date = gregorian.date(from: components)!
//            lastNotificationTime = date
//        }
//        else
//        {
//            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
//            let now = lastNotificationTime
//            var components = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: now as Date)
//
//            // Change the time to 9:30:00 in your locale
//            components.hour = hour
//            components.minute = min
//            components.second = 0
//
//            let date = gregorian.date(from: components)!
//            lastNotificationTime = date
//        }
//
//        DispatchQueue.main.async {
//
//            let Verse = self.VersCall().components(separatedBy: "_")
//            let content = UNMutableNotificationContent()
//            content.title = Verse[1]
//            content.body = Verse[0]
//            content.sound = UNNotificationSound.default
//            let nextDate = Calendar.current.date(byAdding: .day, value: (self.NotificationDayCount >= 3 ? 1:0), to: lastNotificationTime)!
//            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
//            let components = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: nextDate as Date)
//            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
//            let request = UNNotificationRequest(identifier: "DailyNotification\(lastNotificationTime)", content: content, trigger: trigger)
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
//                if error != nil {
//                    print("SOMETHING WENT WRONG")
//                }
//                else
//                {
//
//                    print("\n=====================================")
////
//                    if self.NotificationDayCount == 3 {
//                        self.NotificationDayCount = 0
//                    }
//
//                    print("content.title :",Verse[1])
//                    print("nextDate :",nextDate)
//
//                    UserDefaults.standard.set(nextDate.timeIntervalSince1970, forKey: "LastNotificationTime")
//                    self.onSetLocalNotification()
//                    }
//            })
//        }
    }
    
    
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
    
    
    

    private func scheduleShiftIfEnabled(
        enabledKey: String,
        timeKey: String,
        defaultTime: String,
        lastTimeKey: String,
        quizTime: Bool
    ) {
        guard UserDefaults.standard.bool(forKey: enabledKey) else { return }
        if UserDefaults.standard.string(forKey: timeKey) == nil {
            UserDefaults.standard.set(defaultTime, forKey: timeKey)
        }
        UserDefaults.standard.set(0.0, forKey: lastTimeKey)
        let shiftTime = UserDefaults.standard.string(forKey: timeKey) ?? defaultTime
        for _ in 0..<5 {
            NotificationCall(ShiftTm: shiftTime, QuizTime: quizTime, lastTimeKey: lastTimeKey)
        }
    }

    func NotificationCall(ShiftTm:String, QuizTime:Bool = false, lastTimeKey: String = "LastNotificationTime") {
        var ShiftTime = ShiftTm
        
        if ShiftTime.count != 5 {
            ShiftTime = DateConfig.shared.dateTimeChangeFormat(str: ShiftTime, inDateFormat:  "hh:mm a", outDateFormat: "HH:mm")
        }
        
        
        let hour : Int? = Int(ShiftTime.components(separatedBy: ":")[0])
        let min : Int? = Int(ShiftTime.components(separatedBy: ":")[1])
        
        var lastNotificationTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: lastTimeKey))



        
        
        if (UserDefaults.standard.double(forKey: lastTimeKey) == 0) {
            
            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let now = NSDate()
            var components = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: now as Date)
            components.hour = hour
            components.minute = min
            components.second = 0
            let date = gregorian.date(from: components)!
            lastNotificationTime = date
        }
        else
        {
            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let now = lastNotificationTime
            var components = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: now as Date)

            // Change the time to 9:30:00 in your locale
            components.hour = hour
            components.minute = min
            components.second = 0

            let date = gregorian.date(from: components)!
            lastNotificationTime = date
        }
            
            let Verse = self.VersCall().components(separatedBy: "_")
            let content = UNMutableNotificationContent()
            if QuizTime {
                let RandNum = Int.random(in: 0..<10)
                content.title = self.AlertTitle[RandNum]
                content.body = self.AlertContent[RandNum]
                content.sound = UNNotificationSound(named:UNNotificationSoundName(rawValue: "puzzal Notification.mp3"))
            } else {
                content.title = "Verse Of The Day"
                content.body = "\(Verse[1]) \(Verse[0])"
                content.sound = UNNotificationSound(named:UNNotificationSoundName(rawValue: "Halulayyo.mp3"))
            }
            
//            content.sound = UNNotificationSound.default
        
            
            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: lastNotificationTime)!
            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let components = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: nextDate as Date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(lastTimeKey)_\(nextDate.timeIntervalSince1970)", content: content, trigger: trigger)
            // Advance synchronously so the next day-slot in this shift does not race/overwrite.
            UserDefaults.standard.set(nextDate.timeIntervalSince1970, forKey: lastTimeKey)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print("SOMETHING WENT WRONG")
                }
                else
                {
                    print("\(content.title) \(content.body)")
                    
                                                     
                    
                    print("nextDate :",nextDate)
                    
//                    print("PerDay :",UserDefaults.standard.integer(forKey: "PerDay"))
                    
//                    if self.NotificationDayCount == UserDefaults.standard.integer(forKey: "PerDay") {
//                        self.NotificationDayCount = 0
//                        self.onSetLocalNotification()
//
//
//                        let center = UNUserNotificationCenter.current()
//                            center.getPendingNotificationRequests(completionHandler: { requests in
//                            })
//
//
//                    }
                    
                    }
            })
    }
    
    
    
    
}

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}



extension Notification.Name {
    static let didReceiveNotification = Notification.Name(rawValue: "com.RichNotification.DidReceiveNotification")
}

