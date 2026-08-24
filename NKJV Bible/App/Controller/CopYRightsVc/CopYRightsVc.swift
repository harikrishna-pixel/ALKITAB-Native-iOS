//
//  CopYRightsVc.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 19/11/21.
//

import UIKit
import WebKit

class CopYRightsVc: UIViewController, WKUIDelegate {

    private lazy var webView = WKWebView()
    var LoaderView: String = ""
    var LoaderView1: LoaderVc?
    var activityIndicator: UIActivityIndicatorView?
    private var observation: NSKeyValueObservation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.LoaderView1 = (kStoryboardMainIphone.instantiateViewController(withIdentifier: "LoaderVc") as! LoaderVc)
        self.LoaderView1!.modalPresentationStyle = .overCurrentContext
        self.LoaderView1!.modalTransitionStyle = .crossDissolve
        present(self.LoaderView1!, animated: true, completion: nil)
        
        
        self.webView = WKWebView(frame: CGRect(x: 0, y: 80, width: self.view.frame.size.width, height: self.view.frame.size.height-80))
            self.webView.scrollView.bounces = false
            self.webView.backgroundColor = .clear
            self.view.addSubview(self.webView)
        
            self.webView.load(NSURLRequest(url: URL(string: LoaderView)!) as URLRequest)
        self.observation = self.webView.observe(\WKWebView.estimatedProgress, options: .new) { _, change in
            
            
            if change.newValue == 1.0 {
                self.LoaderView1!.dismiss(animated: true, completion: nil)
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
