//
//  SharedViewController.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 01/03/21.
//

import UIKit
import ContactsUI
import MessageUI
import FBSDKShareKit
import StoreKit

class SharedViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SharingDelegate, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var Mainframe:UIView!
    @IBOutlet weak var SharedCollectionView:UICollectionView!
    @IBOutlet weak var MainviewBottom: NSLayoutConstraint!
    @IBOutlet weak var BannerView: UIView!
    
    var ImageArry = ["Whatsapp", "fb", "copy", "message", "mail","more"]
    var ItemName:Array<String> = ["WhatsApp", "Facebook", "Copy", "SMS", "Mail", "More"]
    var interaction: UIDocumentInteractionController?
    
    var ShareVerseImageURL: [URL]!
    var VerseStr:String?
    var VerseImgName:String?
    var VerseImgData:Data?
//    var VerseImg:UIImage?
    var Bookname:String?
    
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
         
        
        self.SharedCollectionView.delegate = self
        self.SharedCollectionView.dataSource = self
        
        self.SharedCollectionView.register(UINib(nibName: "SaveFrameCell", bundle: nil), forCellWithReuseIdentifier: "SaveFrameCell")
        
        self.SharedCollectionView.reloadData()
        self.Mainframe.layer.masksToBounds = true
        self.Mainframe.roundTopCorners()
        
        
        self.CollectionViewAnimateOpen()
        
        if PaymentHistory.sharedInstance.paymentInfo() {
            for view in self.BannerView.subviews {
                view.removeFromSuperview()
            }
            
            DispatchQueue.main.async {
                IronSourceBanner.sharedInstance.ViewControl = self
                IronSourceBanner.sharedInstance.IronSource_Banner_AdLoad(bannerWidth: Int(ScreenWidth), bannerHeight: 70)
                }
            
        } else {
            self.BannerView.isHidden = true
        }
        
    }
    
    
    
    // MARK:- Collection View
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 76)
      }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 30
        }
    
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.ImageArry.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = (self.SharedCollectionView.dequeueReusableCell(withReuseIdentifier: "SaveFrameCell", for: indexPath) as! SaveFrameCell)
            
            cell.ShareCellImage.image = UIImage(named: self.ImageArry[indexPath.row])
            cell.ShareCellImage.layer.cornerRadius = 5
            cell.ItemName.text =  self.ItemName[indexPath.row]
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
             
            switch (indexPath.row) {
            
            case 0:
                if NetworkManager.sharedInstance.isConnectedToInternet() {
                    if self.VerseImgName == nil || self.VerseImgName == "" {
                        self.WhatsappShare()
                    } else {
                        self.WhatsAppImageShare()
                    }
                    UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "RateUSoneTime")+1, forKey: "RateUSoneTime")
                } else {
                    self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                }
                break
            case 1:
                if NetworkManager.sharedInstance.isConnectedToInternet() {
                    if self.VerseImgName == nil || self.VerseImgName == "" {
                        self.Facebook()
                    } else {
                        self.facebookImag()
                    }
                    UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "RateUSoneTime")+1, forKey: "RateUSoneTime")
                } else {
                    self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                }
                
                break
            case 2:
                self.CopyAction()
                break
            case 3:
                self.sendVerse()
                break
            case 4:
                if NetworkManager.sharedInstance.isConnectedToInternet() {
                    self.sendEmailToUsers()
                } else {
                    self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                }
                UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "RateUSoneTime")+1, forKey: "RateUSoneTime")
                break
            case 5:
                
                if self.VerseImgName == nil || self.VerseImgName == "" {
                    self.shared()
                } else {
                    self.sharedImage()
                }
                UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "RateUSoneTime")+1, forKey: "RateUSoneTime")
                break
            default: break
            }
            
            
            self.SharedCollectionView.reloadData()
        }
    
        
   

    // MARK:- Click Action
    

    
    
    
    // MARK:- send email Delegate
    
    func sendEmailToUsers() {
        
        if MFMailComposeViewController.canSendMail()
         {
           let composeVC = MFMailComposeViewController()
           composeVC.mailComposeDelegate = self
           composeVC.setToRecipients([])
           composeVC.setSubject(Bookname!)
           composeVC.setMessageBody("\(VerseStr!)\n\n\(Bookname!)\n\nRead more at: \(APP_LINK)", isHTML: false)
            
            
            if self.VerseImgName != nil && self.VerseImgName! != "" {
//                let imageData: NSData = self.VerseImgData! as NSData
                composeVC.addAttachmentData(self.VerseImgData!, mimeType: "image/png", fileName: "\(self.VerseImgName!).png")
            }
           
            self.present(composeVC, animated: true, completion: nil)
        } else {
            self.view.makeToast(NSLocalizedString("Please Login your email id", comment: ""), duration: 1.0, position: .bottom)
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    
    // MARK:- Share Text in Whats app
    
    func WhatsappShare() {        
        
        let urlWhats = "whatsapp://send?text=\(VerseStr!)\n\n\(Bookname!)\n\nRead more at: \(APP_LINK)"
          if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
              if let whatsappURL = NSURL(string: urlString) {
                  if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                      if #available(iOS 10.0, *) {
                          UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: { success in
                              if !success {
                                  DispatchQueue.main.async {
                                      self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .bottom)
                                  }
                              }
                          })
                      } else {
                          UIApplication.shared.openURL(whatsappURL as URL)
                      }
                  } else {
                    self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .bottom)
                  }
              } else {
                  self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .bottom)
              }
          } else {
              self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .bottom)
          }
      }
    
    
    
    // MARK:- Share Image in Whats app
    func WhatsAppImageShare() {
        
        let ShareImage = AppClousers.sharedInstance.loadImageFromDiskWith(fileName: "\(self.VerseImgName!).jpg")
        
        
        let urlWhats = "whatsapp://?app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            
            
          if let whatsappURL = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(whatsappURL) {

                let image = ShareImage
                
//                if let imageData = image!.jpegData(compressionQuality: 1.0) {
                  let tempFile = NSURL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/\(self.VerseImgName!).jpg")
                  do {
                    try VerseImgData!.write(to: tempFile!, options: .atomic)

                    self.interaction = UIDocumentInteractionController(url: tempFile!)
                    self.interaction!.uti = "net.whatsapp.image"
                    self.interaction!.delegate = self
                    self.interaction!.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                  }
                  catch {
                    self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .bottom)
                  }
//                }

            } else {
                self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .bottom)
            }
          } else {
              self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .bottom)
          }
        } else {
            self.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .bottom)
        }
    }
    
    
    
    
    // MARK:- Send Message
    @objc func sendVerse() {
        
           if (MFMessageComposeViewController.canSendText()) {
               let controller = MFMessageComposeViewController()
               controller.body = "\(VerseStr!)\n\n\(Bookname!)\n\nRead more at: \(APP_LINK)"
               controller.recipients = [" "]
               controller.messageComposeDelegate = self
               self.present(controller, animated: true, completion: nil)
           } else {
              self.view.makeToast("Can't Open contacts", duration: 1.0, position: .bottom)
           }
       }
    
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
          controller.dismiss(animated: true, completion: nil)
       }
    
    
    
    // MARK:- Copy Text
    func CopyAction() {
        UIPasteboard.general.string = "\(VerseStr!)\n\n\(Bookname!)\n\nRead more at: \(APP_LINK)"
        self.view.makeToast("Copied successfully", duration: 2.0, position: .bottom)
        
    }
    
    
    
    // MARK:- Facebook share
    func Facebook() {
        
        let content = ShareLinkContent()
        content.quote = "\(VerseStr!)\n\n\(Bookname!)\n\nRead more at: \(APP_LINK)"
        content.contentURL = URL(string: APP_LINK)!
        
        let shareTxt = ShareDialog(viewController: self, content: content, delegate: self)
        shareTxt.delegate = self
        shareTxt.mode = .automatic
        let fbURL = URL(string: "fb://")

        
        if let fbURL = fbURL {
            if UIApplication.shared.canOpenURL(fbURL) {
                shareTxt.show()
            } else {
                self.view.makeToast("Install facebook app to share", duration: 2.0, position: .bottom)
            }
        }
        
    }
    
    
    
    
    func facebookImag() {
        let photo = SharePhoto(image: UIImage(data: VerseImgData!)!, isUserGenerated: true)
               let content = SharePhotoContent()
               content.photos = [photo]
             let showDialog = ShareDialog(viewController: self, content: content, delegate: self)

               if (showDialog.canShow) {
                   showDialog.show()
               } else {
                   self.view.makeToast("It looks like you don't have the Facebook mobile app on your phone.", duration: 2.0, position: .bottom)
               }
    }
    
    
    func sharer(_ sharer: FBSDKShareKit.Sharing, didCompleteWithResults results: [String : Any]) {

    }

    func sharer(_ sharer: FBSDKShareKit.Sharing, didFailWithError error: Error) {
        self.view.makeToast("Facebook sharing has been  Canceled", duration: 2.0, position: .bottom)
    }

    func sharerDidCancel(_ sharer: FBSDKShareKit.Sharing) {
        self.view.makeToast("Facebook sharing has been  Canceled", duration: 2.0, position: .bottom)
    }
    
     
    
    // MARK:- Common Share
    
    func shared() {
        
        let text = "\(VerseStr!)\n\n\(Bookname!)\n\nRead more at: \(APP_LINK)"
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare as [Any] , applicationActivities: nil)
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
    
    func sharedImage() {
        
        let activityViewController = UIActivityViewController(activityItems: ShareVerseImageURL, applicationActivities: nil)
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

    

    // MARK:- View Animation
    func CollectionViewAnimateOpen() {
           UIView.animate(withDuration: 0.5, animations: {
               self.MainviewBottom.constant = 0
            self.Mainframe.alpha =  CGFloat(1.0)
            self.view.layoutIfNeeded()
           }, completion: { finished in
              
           })
   }
    
    func CollectionViewAnimateClose() {
        UIView.animate(withDuration: 0.5, animations: {
            self.MainviewBottom.constant = -330
            self.Mainframe.alpha =  CGFloat(0.0)
            self.view.layoutIfNeeded()
        }, completion: { finished in
            self.dismiss(animated: true, completion: nil)
        })
   }
    
    
    
    @IBAction func CloseView(_ sender: Any) {
     self.CollectionViewAnimateClose()
    }
      


    
}
