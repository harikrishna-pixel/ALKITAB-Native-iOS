//
//  ImageGalleryViewController.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 11/03/21.
//

import UIKit
import Photos


class ImageGalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate,IMageReload {
 
    
    
    static let sharedInstance = ImageGalleryViewController()
    @IBOutlet var ImageGalleryCollectionView: UICollectionView!
//    @IBOutlet var No_Image: UIImageView!
   
//    @IBOutlet weak var ImageHeight: NSLayoutConstraint!
//    @IBOutlet weak var ImageWidth: NSLayoutConstraint!
    @IBOutlet weak var WarningLbl: UILabel!
    @IBOutlet weak var WarningBtn: UIButton!
    
    var ImageGalleryCell: ImageGalleryCollectionViewCell?
    var ChangeView:Bool = false
    var Galleryimages:Array<UIImage> = []
    var status: PHAuthorizationStatus?
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    
    var ImageSliderView: ImageSlideVu?
    var myView:UIView?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.status = PHPhotoLibrary.authorizationStatus()
        
        if self.status == nil || self.status?.rawValue == 0 {
            self.WarningLbl.isHidden = false
            self.WarningBtn.isHidden = false
            self.ImageGalleryCell?.isHidden = true
        }
        else {
            self.WarningLbl.isHidden = true
            self.WarningBtn.isHidden = true
            self.ImageGalleryCell?.isHidden = false
        }
        
        if self.status?.rawValue != 3 && self.status?.rawValue != 0 {
            self.WarningLbl.isHidden = false
            self.WarningLbl.text = "No permission to access Gallery \n Please go to app settings to allow permission"
        }
                
        self.ImageGalleryCollectionView.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        self.view.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        
        self.setupLongGestureRecognizerOnCollection()
        App_Protocol.IMageReloaddelegate = self
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 5)
      }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

      if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
          return CGSize(width: (self.view.bounds.width/3)-10, height: (self.view.bounds.width/4.5)-10)
      } else {
          return CGSize(width: (self.view.bounds.width/2)-10, height: (self.view.bounds.width/1.7)-10)
      }
    }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if self.Galleryimages.count > 0 {
                return CustomPhotoAlbum.sharedInstance.images.count
            } else {
                return 0
            }
        }
    
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = (self.ImageGalleryCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageGalleryCell", for: indexPath) as! ImageGalleryCollectionViewCell)
            
            if self.Galleryimages.count > 0  {
                if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
                    cell.ImageFrameHeight.constant = (self.view.bounds.width/4.5)-10
                    cell.ImageFramewidth.constant = (self.view.bounds.width/3)-20
                } else {
                    cell.ImageFrameHeight.constant = (self.view.bounds.width/1.7)-10
                    cell.ImageFramewidth.constant = (self.view.bounds.width/2)-20
                }
                cell.ImageFrame.layer.masksToBounds = true
                cell.ImageVu!.image = CustomPhotoAlbum.sharedInstance.images[indexPath.row]
                cell.ImageFrame!.addSubview(cell.ImageVu!)
            }
            
            
            return cell
        }
    
    
    
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            if self.ChangeView == true {
                self.ChangeView = false
                self.ReloadCollectionVu()
            } else {
                let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ImageSliderVC") as! ImageSliderVC
                vc.SelectedCell = indexPath.row
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
    

    
    func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 1.0
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        self.ImageGalleryCollectionView?.addGestureRecognizer(longPressedGesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        self.ChangeView = true
        self.ReloadCollectionVu()
    }

    
    @IBAction func BookmarkAction(_ sender: Any) {
        self.ReloadCollectionView ()
    }
    
    
    
    @objc func DeleteImageFromAlbum(sender: UIButton!) {
        let index = sender.tag
        self.AlertVc(Index:index)
    }
    
    
     func AlertVc(Index:Int) {
        
        let alert = UIAlertController(title: nil, message: "Do you want to delete this image?" , preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
                
            }))

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ (UIAlertAction)in
                CustomPhotoAlbum.sharedInstance.deleteSelectedPhotoFromGallery(ImageIndex: Index)
                CustomPhotoAlbum.sharedInstance.images.removeAll()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    self.LoadImage()
                }
                self.view.makeToast("Image Removed from App Album", duration: 2.0, position: .bottom)
            }))

        alert.popoverPresentationController?.sourceView = self.view
            self.present(alert, animated: true, completion: {
            })
        
    }
    
    
     
    
    func ReloadCollectionView () {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
            self.ImageGalleryCollectionView.reloadData()
            
            if self.Galleryimages.count == 0 {
                
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
                                  self.WarningLbl.text = "Loading... Please wait"
                                  self.LoadImage()
                                }
                                break
                            case .denied:
                                DispatchQueue.main.async {
                                   self.WarningLbl.text = "No permission to access Gallery \n Please go to app settings to allow permission"
                                   self.AlertVc()
                                }
                            default:
                              break
                            }
                        })
                    case .restricted:
                        self.WarningLbl.text = "No permission to access Gallery \n Please go to app settings to allow permission"
                        self.AlertVc()
                    case .denied:
                        self.WarningLbl.text = "No permission to access Gallery \n Please go to app settings to allow permission"
                        self.AlertVc()
                        break
                    case .authorized:
                          self.LoadImage()
                        break
                    case .limited:
                        self.WarningLbl.text = "No permission to access Gallery \n Please go to app settings to allow permission"
                        self.AlertVc()
                        break
                        
                    default:
                      break
                    
                    }
                }
            }
        }
    }
    
 
    
    func AlertVc() {
        SettingAlert.GallaryPermission(SorceVc: self)
    }
    
    func ReloadCollectionVu() {
    DispatchQueue.main.async {
        self.ImageGalleryCollectionView.reloadData()
        }
    }

    
    func LoadImage() {
        // BUG FIX 3 (DUPLICATE IMAGES): OLD CODE - Fetched images immediately without waiting for pending saves
        /*
        CustomPhotoAlbum.sharedInstance.images.removeAll()
        CustomPhotoAlbum.sharedInstance.fetchCustomAlbumPhotos()
        (rest of code immediately)
        */
        // Problem: If user just saved an image and navigates to My Library, saveImage() is ASYNC
        // so fetch happens BEFORE save completes, showing old photos. Second time it works because
        // save already completed. This creates the "first time shows many, second time shows correct" bug
        
        // BUG FIX 3 (DUPLICATE IMAGES): NEW CODE - Show loading state, then delay fetch
        self.ImageGalleryCell?.isHidden = true
        self.WarningBtn.isHidden = true
        self.ImageGalleryCollectionView.isHidden = true
        self.WarningLbl.text = "Loading..."
        self.WarningLbl.isHidden = false
        
        CustomPhotoAlbum.sharedInstance.images.removeAll()
        
        // Add delay to ensure any pending save operations complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            CustomPhotoAlbum.sharedInstance.fetchCustomAlbumPhotos()
             
            if CustomPhotoAlbum.sharedInstance.images.count <= 0 {
                self.ImageGalleryCollectionView.isHidden = true
                self.WarningLbl.text = "No Image found"
                self.WarningLbl.isHidden = false
            } else {
                self.Galleryimages = CustomPhotoAlbum.sharedInstance.images
                self.ImageGalleryCollectionView.isHidden = false
                self.WarningLbl.isHidden = true
                self.ReloadCollectionVu()
            }
        }
    }
    
}
