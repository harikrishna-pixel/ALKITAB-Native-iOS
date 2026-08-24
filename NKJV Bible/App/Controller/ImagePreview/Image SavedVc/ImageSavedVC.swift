//
//  ImageSavedVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 05/01/23.
//

import UIKit

class ImageSavedVC: UIViewController {

//    @IBOutlet weak var AdBannerView: UIView!
    @IBOutlet weak var PreviewImageWidth: NSLayoutConstraint!
    @IBOutlet weak var Done: UIButton!
    @IBOutlet weak var PreviewImg: UIImageView!
    
    var SavedImage: UIImage!
    var FrameHeight: CGFloat!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.PreviewImageWidth.constant = ScreenWidth
        
//        if PaymentHistory.sharedInstance.paymentInfo() {
//            adBannerView.load(GADRequest())
//            AdBannerView.addSubview(self.adBannerView)
//        }
        
        
        let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        self.Done.backgroundColor = Themecolor
        self.Done.layer.cornerRadius = self.Done.frame.height/2
        
        self.PreviewImg.image = SavedImage
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ShareImage(_ sender: Any) {
        self.sharedImage(shared: PreviewImg.image!)
    }
    
    
    func sharedImage(shared:UIImage) {

        let url = URL(fileURLWithPath: NSTemporaryDirectory())
                let fileURL = url.appendingPathComponent("Bible verse.png")
               try! shared.pngData()?.write(to: fileURL)
                            
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            self.dismiss(animated: true, completion: nil)
            FileManager.default.clearTmpDirectory()
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
