//
//  ShareViewController.swift
//  ImageEditor
//
//  Created by ajayprasanth on 09/05/23.
//

import UIKit
import FBSDKShareKit
import Toast_Swift
//import TwitterKit
import Photos


//class ShareViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    class ShareViewController: UIViewController, SharingDelegate, UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    var documentController: UIDocumentInteractionController!
    
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var ConvertingVu: UIView!
    @IBOutlet weak var ADView: UIView!
    
    @IBOutlet weak var ADLine: UILabel!
        
    @IBOutlet var ImageVu: UIImageView!
    @IBOutlet var tick: UIImageView!
    @IBOutlet var ProgressVu: UIView!
    @IBOutlet var ProgressLabel: UILabel!
        
    var OutputImage:UIImage!
    
        
    var fileURL: URL!
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if PaymentHistory.sharedInstance.paymentInfo()  {
            AdmobManager.shared.IronSource_Interstitial_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!)
        }
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        
        self.progressBar()
        
        self.Image.image = OutputImage
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        

        
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
         fileURL = url.appendingPathComponent("Image.png")
        try! OutputImage.pngData()?.write(to: fileURL)
        
        
        self.ImageVu.rotate(RotateMode: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3.0) {
            self.ConvertingVu.isHidden = true
            self.ImageVu.rotate(RotateMode: false)
            self.tick.isHidden = false
            self.view.makeToast("Saved to Album", duration: 2.0, position: .center)
        }
        
        if PaymentHistory.sharedInstance.paymentInfo()  {
            self.ADLine.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+18.0) {
                self.ADLine.isHidden = false
                IronSourceBanner.sharedInstance.ViewControl = self
                IronSourceBanner.sharedInstance.IronSource_Banner_AdLoad(bannerWidth: Int(ScreenWidth), bannerHeight: 60)
                
            }
        } else {
            self.ADLine.isHidden = true
        }
          
        
    }
        
        
        func progressBar() {
            
            let progressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: self.ProgressVu.frame.width, height: self.ProgressVu.frame.height), lineWidth: 10, rounded: true)
            
            progressView.progressColor = .blue
            progressView.trackColor = .lightGray
            progressView.center = CGPoint(x: self.ProgressVu.frame.width/2, y: self.ProgressVu.frame.height/2)  //self.ProgressVu.center
            progressView.progress = 1.0
            self.ProgressVu.addSubview(progressView)
            
            self.incrementLabel(to: 100)
            
        }
        
        
        func incrementLabel(to endValue: Int) {
            let duration: Double = 2.7 //seconds
            DispatchQueue.global().async {
                for i in 0 ..< (endValue + 1) {
                    let sleepTime = UInt32(duration/Double(endValue) * 1000000.0)
                    usleep(sleepTime)
                    DispatchQueue.main.async {
                        self.ProgressLabel.text = "\(i)"
                    }
                }
            }
        }
        
        
    

    @IBAction func Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       }
        
        
        
        
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
        
        
   @IBAction func Save_Action(_ sender: Any) {
       self.view.makeToast("Saved to Album", duration: 2.0, position: .center)
   }
        
   @IBAction func Home_Action(_ sender: Any) {
       // Find ReaderViewController in the navigation stack before popping
       guard let navController = self.navigationController else {
           return
       }
       
       // Find ReaderViewController reference before we pop (save it)
       guard let readerVC = navController.viewControllers.last(where: { $0.isKind(of: ReaderViewController.self) }) as? ReaderViewController else {
           // If ReaderViewController not found, just pop to root
           navController.popToRootViewController(animated: true)
           return
       }
       
       // Store reference for later use
       let savedReaderVC = readerVC
       
       // Pop directly to ReaderViewController - this will dismiss ShareViewController and IMageEditingPageVc
       navController.popToViewController(readerVC, animated: true)
       
       // Use transition coordinator to detect when pop animation completes
       if let coordinator = self.transitionCoordinator {
           coordinator.animate(alongsideTransition: nil) { context in
               // Transition completed successfully
               if !context.isCancelled {
                   // Ensure view is removed and then navigate to Home
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                       savedReaderVC.CallHomeView()
                   }
               }
           }
       } else {
           // Fallback: use longer delay to ensure dismissal completes
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               savedReaderVC.CallHomeView()
           }
       }
    }
        
        
    
    @IBAction func FB_Action(_ sender: Any) {
        self.Facebook()
       }
    
    @IBAction func Insta_Action(_ sender: Any) {
        self.Insta()
       }
    
    @IBAction func WhatsApp_Action(_ sender: Any) {
        self.WhatsAppImageShare()
       }
    
    @IBAction func Twitter_Action(_ sender: Any) {

        
        
//        if (TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
//            // App must have at least one logged-in user to compose a Tweet
//            let composer = TWTRComposerViewController.emptyComposer()
//            present(composer, animated: true, completion: nil)
//        } else {
//            // Log in, and then check again
//            TWTRTwitter.sharedInstance().logIn { session, error in
//                if session != nil { // Log in succeeded
//                    let composer = TWTRComposerViewController.emptyComposer()
//                    self.present(composer, animated: true, completion: nil)
//                } else {
//                    let alert = UIAlertController(title: "No Twitter Accounts Available", message: "You must log in before presenting a composer.", preferredStyle: .alert)
//                    self.present(alert, animated: false, completion: nil)
//                }
//            }
//        }
                                                           
        
        
        
       }
    
    @IBAction func More_Action(_ sender: Any) {
        self.sharedImage(sharedUrl:fileURL)
       }
    
    
    
    
    func sharedImage(sharedUrl:URL) {
        
        let activityViewController = UIActivityViewController(activityItems: [sharedUrl], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    func WhatsAppImageShare() {

        let ShareImage = OutputImage


        let urlWhats = "whatsapp://?app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {


          if let whatsappURL = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(whatsappURL) {

                let image = ShareImage

                if let imageData = image!.jpegData(compressionQuality: 1.0) {
                  let tempFile = fileURL
                  do {
                    try imageData.write(to: tempFile!, options: .atomic)

                    self.documentController = UIDocumentInteractionController(url: tempFile!)
                    self.documentController!.uti = "net.whatsapp.image"
                    self.documentController!.delegate = self
                    self.documentController!.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                  }
                  catch {
                    self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .center)
                  }
                }

            } else {
                self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .center)
            }
          } else {
              self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .center)
          }
        } else {
            self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .center)
        }
    }
    
    
    
    
    func Insta() {

        DispatchQueue.main.async {

            //Share To Instagram:
            let instagramURL = URL(string: "instagram://app")
            if UIApplication.shared.canOpenURL(instagramURL!) {
                let tempFile = self.fileURL
                let viewController = UIApplication.shared.keyWindow?.rootViewController
                self.documentController = UIDocumentInteractionController(url: tempFile!)
                self.documentController.delegate = self
                self.documentController.uti = "com.instagram.exlusivegram"
                self.documentController?.presentOpenInMenu(from: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), in: viewController!.view, animated: true)

            } else {
                self.view.makeToast("Instagram app not installed in your mobile", duration: 4.0, position: .center)
            }
        }
    }
    
    
    
    func Facebook() {

        
        let photo = SharePhoto(image: OutputImage!, isUserGenerated: true)
               let content = SharePhotoContent()
               content.photos = [photo]
             let showDialog = ShareDialog(viewController: self, content: content, delegate: self)

               if (showDialog.canShow) {
                   showDialog.show()
               } else {
                   self.view.makeToast("It looks like you don't have the Facebook mobile app on your phone.", duration: 2.0, position:  .center)
               }
        

    }
    
    
    func sharer(_ sharer: FBSDKShareKit.Sharing, didCompleteWithResults results: [String : Any]) {

    }

    func sharer(_ sharer: FBSDKShareKit.Sharing, didFailWithError error: Error) {
        self.view.makeToast("Facebook sharing has been  Canceled", duration: 2.0, position: .center)
    }

    func sharerDidCancel(_ sharer: FBSDKShareKit.Sharing) {
        self.view.makeToast("Facebook sharing has been  Canceled", duration: 2.0, position: .center)
    }
    

}


extension UIView{
    func rotate(RotateMode:Bool = true) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = RotateMode
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}

