//
//  Image+Share.swift
//  Smart Bible
//
//  Created by ajayprasanth on 24/10/23.
//

import UIKit
import Photos


class Image_Share: NSObject {
    
    var status: PHAuthorizationStatus?
    static let shared = Image_Share()
    var fileURL: URL!
    var SourceVu: UIViewController!
    
    var WarningLbl:String = ""
    
    func ImageSave(verseName:String,ImageView:UIView) -> URL {
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        self.fileURL = url.appendingPathComponent("\(verseName).png")
        try! self.makeImageFrom(ImageView).pngData()?.write(to: self.fileURL)
        
        return self.fileURL
    }
        
    
    func getAllImageUrl(FolderNAme: String) -> Array<URL> {
        var objCBool: ObjCBool = true
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(FolderNAme)")
        
        
        let isExist = FileManager.default.fileExists(atPath: documentsUrl!.path, isDirectory: &objCBool)
        if isExist {
            let directoryContents = try! FileManager.default.contentsOfDirectory(at: documentsUrl!, includingPropertiesForKeys: nil)
            return directoryContents
        } else {
            return []
        }
    }
    
    
    
    
    
    
    func saveImageInDocsDir(ImageNAme:String, image: UIImage) -> Bool {
        var objCBool: ObjCBool = true
        let mainPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let folderPath = mainPath + "/\(UserDefaults.standard.string(forKey: "folderName")!)/"

        let isExist = FileManager.default.fileExists(atPath: folderPath, isDirectory: &objCBool)
        if !isExist {
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageUrl = documentDirectory.appendingPathComponent("\(UserDefaults.standard.string(forKey: "folderName")!)/\(ImageNAme)")
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: imageUrl)
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    
    
//    func saveImageToDocumentDirectory(ImageNAme:String, image: UIImage) {
//        var objCBool: ObjCBool = true
//        let mainPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
//        let folderPath = mainPath + "/Screenshots/"
//
//        let isExist = FileManager.default.fileExists(atPath: folderPath, isDirectory: &objCBool)
//        if !isExist {
//            do {
//                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
//            } catch {
//                print(error)
//            }
//        }
//
//        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let imageName = "\(ImageNAme).png"
//        let imageUrl = documentDirectory.appendingPathComponent("Screenshots/\(imageName)")
//        if let data = image.jpegData(compressionQuality: 1.0){
//            do {
//                try data.write(to: imageUrl)
//            } catch {
//                print("error saving", error)
//            }
//        }
//    }
    
    
    
    
    
    
//    func saveImageInDocsDir(ImageNAme:String, image: UIImage) {
//
//            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//            let documentsDirectory = paths[0] // Get documents folder
//            let dataPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(UserDefaults.standard.string(forKey: "folderName")!).absoluteString
//            print(dataPath)
//            //Check is folder available or not, if not create
//            if !FileManager.default.fileExists(atPath: dataPath) {
//                try? FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil) //Create folder if not
//            }
//
//            // create the destination file url to save your image
//            let fileURL = URL(fileURLWithPath:dataPath).appendingPathComponent("imageName.jpg")//Your image name
//            print(fileURL)
//            // get your UIImage jpeg data representation
//            let data = image.jpegData(compressionQuality: 1.0)//Set image quality here
//            do {
//                // writes the image data to disk
//                try data?.write(to: fileURL, options: .atomic)
//            } catch {
//                print("error:", error)
//            }
//    }
    
    
    
    
    
    func makeImageFrom(_ desiredView: UIView) -> UIImage {
        
        let format = UIGraphicsImageRendererFormat()
        let size = CGSize(width: (desiredView.frame.width*3) / format.scale, height: (desiredView.frame.height*3) / format.scale)

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { (ctx) in
        desiredView.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        }
        return image
    }
    

    
    func sharedImage(sharedUrl:[URL]) {
                
        
        let activityViewController = UIActivityViewController(activityItems: sharedUrl, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = SourceVu.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        activityViewController.popoverPresentationController?.sourceRect = SourceVu.view.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: SourceVu.view.bounds.midX, y: SourceVu.view.bounds.maxY, width: 0, height: 0)
        
        SourceVu.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            self.SourceVu.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    
    
    func SaveIMage(ImageVu:UIImage) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            
            if #available(iOS 14, *) {
                self.status = PHPhotoLibrary.authorizationStatus(for: PHAccessLevel(rawValue: PHAccessLevel.RawValue(GETALL))!)
            } else {
                self.status = PHPhotoLibrary.authorizationStatus()
            }
            
            DispatchQueue.main.async {
                switch self.status {
                    case .notDetermined:
                        PHPhotoLibrary.requestAuthorization({ (status) in
                            switch status {
                            case .authorized:
                                DispatchQueue.main.async {
                                  self.WarningLbl = "Loading... Please wait"
                                    self.ConvertIntoImage(saveImage: ImageVu)
                                }
                                break
                            case .denied:
                                DispatchQueue.main.async {
                                   self.WarningLbl = "No permission to access Gallery \n Please go to app settings to allow permission"
                                   self.AlertVc()
                                }
                            default:
                              break
                            }
                        })
                    case .restricted:
                        self.WarningLbl = "No permission to access Gallery \n Please go to app settings to allow permission"
                        self.AlertVc()
                    case .denied:
                        self.WarningLbl = "No permission to access Gallery \n Please go to app settings to allow permission"
                        self.AlertVc()
                        break
                    case .authorized:
                        self.ConvertIntoImage(saveImage: ImageVu)
                        break
                    case .limited:
                        self.WarningLbl = "No permission to access Gallery \n Please go to app settings to allow permission"
                        self.AlertVc()
                        break
                        
                    default:
                      break
                    
                    }
                }
        }
    }
    
    
    func ConvertIntoImage(saveImage:UIImage) {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized) {
            DispatchQueue.main.async {
                CustomPhotoAlbum.sharedInstance.saveImage(image: saveImage)
//                self.SourceVu.view.makeToast("Image Saved Succesfully!", duration: 2.0, position: .bottom)
            }

        } else {
//            self.SourceVu.view.makeToast("Save Image now", duration: 2.0, position: .bottom)
        }
    }
    
    
    
    func AlertVc() {
        SettingAlert.GallaryPermission(SorceVc: self.SourceVu)
    }
    
    
    
    
    
}
