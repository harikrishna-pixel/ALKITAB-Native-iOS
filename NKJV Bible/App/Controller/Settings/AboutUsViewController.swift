//
//  AboutUsViewController.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 13/02/21.
//

import UIKit
import StoreKit
import MessageUI


@available(iOS 11.0, *)
class AboutUsViewController: UIViewController, Setting {
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var AppLogo: UIImageView!
    
    @IBOutlet weak var FeedBack: UIView!
    @IBOutlet weak var Share_The_App: UIView!
    @IBOutlet weak var Rate_The_App: UIView!
    @IBOutlet weak var AppTitle: UILabel!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
                           
        App_Protocol.SettingDelegate = self
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.AppLogo!, colorVu: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
        
        self.AppTitle.textColor = Themecolor
        self.AppTitle.text = "\(APPNAME) \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.0")"
        
        self.FeedBack.AbotyUsBorderVu()
        self.Share_The_App.AbotyUsBorderVu()
        self.Rate_The_App.AbotyUsBorderVu()
        
//
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Button Action
    
    
    @IBAction func FeedBack(_ sender: Any) {
//        App_Protocol.delegateReader?.FeedbackNavigate()
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
        
    }
    
    
    @IBAction func ShareApp(_ sender: Any) {
        self.shared(Link: APP_LINK)
        
    }
    
    func shared(Link:String) {
        let text = "Hi, I found an amazing Reading Bible application with challenging Bible Trivia to improvise biblical knowledge. \n\nTry it now! : : \(Link)"
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func RateApp(_ sender: Any) {
//        SKStoreReviewController.requestReviewInCurrentScene()
        self.RateVc()
    }
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    
    func CallRate(Rate:String) {
        if Rate == "Feedback" {
            App_Protocol.delegateReader?.FeedbackNavigate()
        } else {
            SKStoreReviewController.requestReviewInCurrentScene()
        }
    }
    
    
    
    func RateVc() {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "RateUsViewController") as! RateUsViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    
}
