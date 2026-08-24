//
//  FeedbackViewController.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 16/03/21.
//

import UIKit
import WebKit

class FeedbackViewController: UIViewController, WKUIDelegate {
 
    var LoaderView: LoaderVc?

    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    @IBOutlet weak var BannerVu: UIView!
    var activityIndicator: UIActivityIndicatorView?
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor

    private lazy var webView = WKWebView()
    private var observation: NSKeyValueObservation?

    
    deinit {
        self.observation = nil
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        self.LoaderView = (kStoryboardMainIphone.instantiateViewController(withIdentifier: "LoaderVc") as! LoaderVc)
        self.LoaderView!.modalPresentationStyle = .overCurrentContext
        self.LoaderView!.modalTransitionStyle = .crossDissolve
        present(self.LoaderView!, animated: true, completion: nil)
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
        self.webView = WKWebView(frame: CGRect(x: 0, y: (StatusbarHeight > 20 ? 90:70), width: self.view.frame.size.width, height: self.view.frame.size.height-(StatusbarHeight > 20 ? 90:70)))
            self.webView.scrollView.bounces = false
            self.webView.backgroundColor = .clear
            self.view.addSubview(self.webView)

            let Appcolor = UserDefaults.standard.color(forKey: "AppThemeColor")
            let editedText = Appcolor!.toHexString().replacingOccurrences(of: "#", with: "")
            
            let originalUrl =  String(format:"\(feedback_form)?device_id=\(Udid)&device_type=\(dev_id_type)&app_version=\(appVersion)&os_version=\(deviceVersion)&app_name=\(APPNAME_SPLASH)&package_name=\(bundleID)&app_type=iOS&language=\(language)&country_code=\(Country_code)&device_name=\(devicename)&device_model=\(platform)&theme_color=\(editedText)&width=\(self.webView.frame.width)&height=\(self.webView.frame.height)&theme_mode=\(NightModeStatus)&is_develop_or_prod=\(developerMode)")
            
            let urlString = originalUrl.replacingOccurrences(of: " ", with: "%20")
            
            self.webView.load(NSURLRequest(url: URL(string: urlString)!) as URLRequest)
            self.observation = self.webView.observe(\WKWebView.estimatedProgress, options: .new) { _, change in
                
                if change.newValue == 1.0 {
                    self.LoaderView!.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    

    
    

    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    
}


