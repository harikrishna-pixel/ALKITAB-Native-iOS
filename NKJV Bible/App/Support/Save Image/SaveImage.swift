//
//  SaveImage.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 21/01/23.
//

import UIKit
import Photos
import AVFoundation


class SaveImage: NSObject {
    
    static let sharedInstance = SaveImage()
    
    var status: PHAuthorizationStatus?

    /// One-shot callback run only after the next successful save (after the toast); cleared on any non-saving path.
    var onNextSaveSuccess: (() -> Void)?
      
    
    func Save(Mainview:UIViewController, saveImage:UIImage) {
        
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
                        DispatchQueue.main.async {
                            self.ConvertIntoImage(Mainview:Mainview, saveImage: saveImage)
//                              Mainview.view.makeToast("Image Saved Successfully!", duration: 2.0, position: .bottom)
                        }
                        break
                    case .denied:
                        self.onNextSaveSuccess = nil
                        self.AlertVc(Mainview:Mainview)
                    default:
                        self.onNextSaveSuccess = nil
                      break
                    }
                })
            case .restricted:
                   self.onNextSaveSuccess = nil
                   self.AlertVc(Mainview:Mainview)
            case .denied:
                   self.onNextSaveSuccess = nil
                   self.AlertVc(Mainview:Mainview)
                break
            case .authorized:
                DispatchQueue.main.async {
                    self.ConvertIntoImage(Mainview:Mainview, saveImage: saveImage)
//                      Mainview.view.makeToast("Image Saved Successfully!", duration: 2.0, position: .bottom)
                    if PaymentHistory.sharedInstance.paymentInfo() {
                         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
//                             if WallpaperAd {
//                                 AdmobManager.shared.IronSource_Interstitial_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!)
//                                 WallpaperAd = false
//                             }
                             
                            }
                    }
                }
                break
                
            case .limited:
                self.onNextSaveSuccess = nil
                self.AlertVc(Mainview:Mainview)
                break
                
            default:
                self.onNextSaveSuccess = nil
              break
            
            }
    }
    
    
    
    func ConvertIntoImage(Mainview:UIViewController, saveImage:UIImage) {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized) {
            DispatchQueue.main.async {
                CustomPhotoAlbum.sharedInstance.saveImage(image: saveImage)
//                Mainview.view.makeToast("Image Saved Successfully!", duration: 2.0, position: .bottom)
                (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Image saved successfully in Album!", duration: 2.0, position: .top)
                Mainview.view.makeToast("Image saved successfully in Album!", duration: 2.0, position: .top)
//                App_Protocol.delegateReader?.AlertFrame(AlertNote: "Image saved successfully in Album!",Vers:"",Title:"")
                let onSaved = self.onNextSaveSuccess
                self.onNextSaveSuccess = nil
                onSaved?()
            }

        } else {
            onNextSaveSuccess = nil
            Mainview.view.makeToast("Save Image now", duration: 2.0, position: .top)
        }
    }
    
    
    
    @objc func  AlertVc(Mainview:UIViewController) {
        SettingAlert.GallaryPermission(SorceVc: Mainview)
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: "Alert", message: "Please enable permission to access gallery \n Select 'All photo' " , preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
//                }))
//                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler:{ (UIAlertAction)in
//                    SettingNavigate.sharedInstance.settingsNavigate()
//
//                }))
//
//
//                // for iPad Support
//            alert.popoverPresentationController?.sourceView = Mainview.view
//              Mainview.present(alert, animated: true, completion: {
//                })
//        }
    }
    
    
    
}
