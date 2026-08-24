//
//  ImagePreviewVc.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 09/08/21.
//

import UIKit
import Photos
import AVFoundation

class ImagePreviewVc: UIViewController {

    @IBOutlet var MainVu: UIView!
    @IBOutlet var ImageVu: UIImageView!
    @IBOutlet weak var Verse:UILabel!
    @IBOutlet weak var VerseTitle:UILabel!
    @IBOutlet weak var SaveBtn:UIButton!
    @IBOutlet weak var MainVuHeight: NSLayoutConstraint!
    @IBOutlet weak var ButtomBottomConst: NSLayoutConstraint!
    
    var imageRectsize: CGRect = CGRect(x: 0, y: 0, width: 0, height: 200)
    var Img:String = ""
    var ImgVerse:String = ""
    var ImgVerseTitle:String = ""
    var saveImage:UIImage?
    var status: PHAuthorizationStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.Verse.text = ImgVerse
        self.VerseTitle.text = ImgVerseTitle
        self.MainVuHeight.constant = self.view.bounds.width+(self.view.bounds.width*0.23)-60
        self.SaveBtn.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor")
        self.ButtomBottomConst.constant = StatusbarHeight-20
        self.ImageVu.image = UIImage(named: "holy cross.jpg")
    }
    

    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func Save(_ sender: Any) {
        
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: PHAccessLevel(rawValue: PHAccessLevel.RawValue(GETALL))!)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
    
            switch self.status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    switch status {
                    case .authorized:
                          self.ConvertIntoImage()
                        break
                    case .denied:
                        self.AlertVc()
                    default:
                      break
                    }
                })
            case .restricted:
                    self.AlertVc()
            case .denied:
                    self.AlertVc()
                break
            case .authorized:
                  self.ConvertIntoImage()
//                self.AdVu()
                self.view.makeToast("Image Saved Successfully!", duration: 2.0, position: .bottom)
                                
                let imageRectsize = AVMakeRect(aspectRatio: self.saveImage!.size, insideRect: UIScreen.main.bounds)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                    self.dismiss(animated: true, completion: nil)
                    App_Protocol.delegateReader?.OpenPreview(SavedImage:self.saveImage!, FrameHeight: imageRectsize.height)
                }
                
                break
                
            case .limited:
                    self.AlertVc()
                break
                
            default:
              break
            
            }
    }
//    func AdVu() {
//        AppInterstitialAdManager().AdLoad()
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
//            let ShowAdd =  AppInterstitialAdManager.shared.ShowApframe(viewController: self)
//            if ShowAdd {
//                
//            } else {
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//    }
    
    
    func ConvertIntoImage() {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized) {
            DispatchQueue.main.async {
                self.saveImage = self.MainVu.asImage()
                CustomPhotoAlbum.sharedInstance.saveImage(image: self.saveImage!)
                self.view.makeToast("Image Saved Successfully!", duration: 2.0, position: .bottom)
            }
        } else {
            self.view.makeToast("Save Image now", duration: 2.0, position: .bottom)
        }
    }
    
    
    
    @objc func  AlertVc() {
        SettingAlert.GallaryPermission(SorceVc: self)
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: "Alert", message: "Please enable permission to access gallery \n Select 'All photo' " , preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
//                }))
//                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler:{ (UIAlertAction)in
//                    SettingNavigate.sharedInstance.settingsNavigate()
//                }))
//
//
//                // for iPad Support
//            alert.popoverPresentationController?.sourceView = self.view
//                self.present(alert, animated: true, completion: {
//                })
//        }
    }
    
}
