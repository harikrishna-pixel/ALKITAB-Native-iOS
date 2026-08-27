//
//  SplashVc.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 08/12/22.
//

import UIKit
import Zip
import AppTrackingTransparency
import SwiftUI

class SplashVc: UIViewController, SplashDelegate {

    @IBOutlet weak var LogoImage: UIImageView!
    @IBOutlet weak var AppText: UILabel!
        
    
    var PopupView:UIView?
    var popupXIB:AppTrackIng_Popup?
    
    var UpdateTxt = ""
    var Version = ""
    var UpdateAppLink = ""
    
    
    var filePath = Bundle.main.url(forResource: "101", withExtension: "zip")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        App_Protocol.DelegateSplash = self
        
        // MARK: - Preload IAP Products Early
        // Load fallback or cached data first, then preload products
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            print("🌐 [SplashVc] Internet available - will fetch from API")
        } else {
            print("📦 [SplashVc] No internet - loading fallback/cached data")
            GetAppInfo.shared.loadFallbackOrCachedData()
        }
        
        // Preload IAP products in background
        if #available(iOS 15.0, *) {
            StoreManager.preloadProducts()
        }
        
        if UserDefaults.standard.string(forKey: "BookChapter") ?? "" == "" {
            UserDefaults.standard.set(1, forKey: "BookChapter")
            OnboardingProgress.markStarted()
            UserDefaults.standard.set((UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 21.0: 17.0), forKey: "FontSize")
            UserDefaults.standard.set(APPFONT, forKey: "FontName")
            UserDefaults.standard.set(APPFONT, forKey: "SubFontName")
            UserDefaults.standard.set(5.0, forKey: "LineGap")
            UserDefaults.standard.set(1, forKey: "AdCallCount")
            UserDefaults.standard.set(Date().string(format: "dd-MM-yyyy"), forKey: "TodayDate")
            UserDefaults.standard.set(PrimaryColor.withAlphaComponent(1.0), forKey: "AppThemeColor")
            UserDefaults.standard.setValue(Date().dayAfter.string(format: "dd-MM-yyyy"), forKey: "RateUS")
            self.defaultAppSelection()
            
        } else {
            BookApi.shared.GetBookCatagory()
            
            let notification_data = DailyVerseLanguageConversion.sharedInstance.DailyVerseLAst().components(separatedBy: "_")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                if OnboardingProgress.shouldShow {
                    self.presentOnboarding()
                } else {
                    self.OpenAd()
                }
            }
        }
        
        
        if UserDefaults.standard.string(forKey: "PriceTag1") == nil {
            UserDefaults.standard.setValue("", forKey: "PriceTag1")
        }
        if UserDefaults.standard.string(forKey: "PriceTag2") == nil {
            UserDefaults.standard.setValue("", forKey: "PriceTag2")
        }
        if UserDefaults.standard.string(forKey: "PriceTag3") == nil {
            UserDefaults.standard.setValue("", forKey: "PriceTag3")
        }
        if UserDefaults.standard.string(forKey: "RateAction") == nil {
            UserDefaults.standard.setValue("", forKey: "RateAction")
        }
        if UserDefaults.standard.string(forKey: "RateAction") == nil {
            UserDefaults.standard.setValue("", forKey: "RateAction")
        }
        if UserDefaults.standard.string(forKey: "Rate5") == nil {
            UserDefaults.standard.setValue("", forKey: "Rate5")
        }
        if UserDefaults.standard.string(forKey: "RateUS") == nil {
            UserDefaults.standard.setValue(Date().dayAfter.string(format: "dd-MM-yyyy"), forKey: "RateUS")
        }
        if UserDefaults.standard.string(forKey: "CurrentDate") == nil {
            UserDefaults.standard.setValue("", forKey: "CurrentDate")
        }
        
        if UserDefaults.standard.string(forKey: "PaymentId") == nil {
            UserDefaults.standard.setValue("", forKey: "PaymentId")
        }
        
        
    }
    
    
    
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()

        AppConstrains.shared.Constrains()
        
        AppText.textColor = UserDefaults.standard.color(forKey: "AppThemeColor")
        AppText.text = APPNAME_SPLASH
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.LogoImage!, colorVu: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
           
    }
    
    
    
    
    func OpenAd() {
        if OnboardingProgress.shouldShow {
            presentOnboarding()
            return
        }

        self.CheckFileUpdate()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ReaderViewController") as! ReaderViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    
    
    
    
    func updateScreen() {
        
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "UpdateScreenViewController") as! UpdateScreenViewController
        vc.UpdateAppLink = UpdateAppLink
        vc.UpdateVersion = Version
        vc.UpdateText = UpdateTxt
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            self.UpdateTxt = ""
            DispatchQueue.main.async {
                if result.keys.contains("releaseNotes") {
                    var list = (result["releaseNotes"]! as? String)!.components(separatedBy: "\n")
                    for item in list {
                        self.UpdateTxt.append("\(list.firstIndex(where: {$0 == item})!+1). \(item)\n\n")
                    }
                }
                self.UpdateAppLink = (result["trackViewUrl"]! as? String)!
                self.Version = "V \((result["version"]! as? String)!)"
            }
            let checkVersion:Float  = Float((result["version"]! as! String).replacingOccurrences(of: ".", with: ""))!
            let checkCurrent:Float  = Float(currentVersion.replacingOccurrences(of: ".", with: ""))!
            
            return checkVersion > checkCurrent
        }
        
        throw VersionError.invalidResponse
    }

    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    
    
    
    
    func LoadData() {
        // Skip custom "Thankful for Your Support" alert; go straight to welcome onboarding.
        // App Tracking is requested after the welcome screen (Start Reading).
        OnboardingProgress.markStarted()
        presentOnboarding()
    }
    
    
    func CheckFileUpdate() {
        DispatchQueue.global().async {
            do {
                let update = try self.isUpdateAvailable()
                DispatchQueue.main.async {
                    
                    if update && UserDefaults.standard.string(forKey: "CurrentDate") ?? ""  != Date().string(format: "MMM d, yyyy") {
                        self.updateScreen()
                    } else {
//
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    func PopupClose() {
        self.PopupView?.removeFromSuperview()
        // Tracking is requested after welcome; keep this path for any leftover popup callers.
        OnboardingProgress.markStarted()
        presentOnboarding()
    }

    private func presentOnboarding() {
        DispatchQueue.main.async {
            let onboardingView = Onboarding1()
            let hostingController = UIHostingController(rootView: onboardingView)
            self.navigationController?.pushViewController(hostingController, animated: true)
        }
    }
    
//    func PopupClose() {
//        self.PopupView?.removeFromSuperview()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                  ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//                      if status == .authorized {
//                       print("App approved")
//                      } else {
//                       print("App Removed")
//                      }
//                      DispatchQueue.main.async {
//                          let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SplashSliderViewController") as! SplashSliderViewController
//                          self.navigationController?.pushViewController(vc, animated: true)
//                      }
//              })
//        })
//    }
    
    
    
         func defaultAppSelection() {
                do {
                 let documentsDirectory = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
                 try Zip.unzipFile(filePath, destination: documentsDirectory, overwrite: true, password: "password", progress: { (progress) -> () in
                    
                    if progress == 1.0 {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                            
                            if APP_TYPE == "2" && UserDefaults.standard.string(forKey: "SecondLanguage") ?? "" == "" {
                                self.filePath = Bundle.main.url(forResource: "102", withExtension: "zip")!
                                UserDefaults.standard.set("102", forKey: "SecondLanguage")
                                self.defaultAppSelection()
                                self.showFileInPath(Language: "102")
                            } else {
                                UserDefaults.standard.set("101", forKey: "SelectedLanguage")
                                self.showFileInPath(Language: "101")
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                                    var AudioBibleName = BibleContent.sharedInstance.BookToPosition()[0]
                                    AudioBibleName = AudioBibleName.components(separatedBy: "-")[0]
                                    UserDefaults.standard.set(AudioBibleName, forKey: "BookName")
                                    VerseNotification.sharedInstance.DateLoop()
                                }
                            }
                        }
                    }
                 })
                }
                catch {
                }
            }
        
        
    

        
    func showFileInPath(Language:String) {

         let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
             let documentsDir = paths[0]
             let zipPath = (documentsDir as NSString).appendingPathComponent("\(Language)")

         do {
             let items = try FileManager.default.contentsOfDirectory(atPath: zipPath)
             for item in items {

                 if (item.hasSuffix(".mp3")) {
                     do {
                         
                         let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(Language)")
                         let originPath = documentDirectory!.appendingPathComponent("audio.mp3")
                         let destinationPath = documentDirectory!.appendingPathComponent("audio.plist")
                         try FileManager.default.moveItem(at: originPath, to: destinationPath)
                     } catch {
                         print(error)
                     }
                 }
             }
         } catch {
         }
     }
     
           
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


