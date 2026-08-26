//
//  WallpaperView.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 10/02/21.
//

import UIKit
import SDWebImage
import Photos


@available(iOS 13.0, *)
class WallpaperView: UIView, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    
    
    @IBOutlet var WallPaperCollection: UICollectionView!
    @IBOutlet weak var MainviewBottom: NSLayoutConstraint!
    @IBOutlet weak var CollectionMainView: NSLayoutConstraint!
    
    @IBOutlet weak var MainCollectionView: UIView!
    @IBOutlet weak var AdBanner: UIView!
    
    
    @IBOutlet weak var Save: UIView!
    @IBOutlet weak var Close: UIView!
    @IBOutlet weak var share: UIView!
    @IBOutlet weak var Edit: UIView!
    
    
    @IBOutlet weak var SaveImg: UIImageView!
    @IBOutlet weak var CloseImg: UIImageView!
    @IBOutlet weak var shareImg: UIImageView!
    @IBOutlet weak var EditImg: UIImageView!
    
    
    
    
    
    var WallpaperCell: WallpaperCollectionViewCell?
    var SourceView: UIViewController!
     
    var BGImage:[Int] = []
    var BGImageCount:Int = 0
    
    

    
    var imageurlArray:Array<Dictionary<String,AnyObject>> = []
    var ShuffledimageArray:Array<String> = []
    var VerseArray:Array<String> = []
    var BookArrayTitle:String = ""
    var VerseStr:String?
    var Bookname:String?
    var BooknameTxt:String?
    var SelectedPath:Int = 0
    var saveImage:UIImage?
    var status: PHAuthorizationStatus?
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    private let pageControl = UIPageControl()
    
    
    override func draw(_ rect: CGRect) {
        self.WallPaperCollection.delegate = self
        self.WallPaperCollection.dataSource = self
 
        ImageAppProtocol.ImageTxtEditDelegate?.CheckPay()
        self.CollectionMainView.constant = Imagesize+58
        
        

//        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
//            self.CollectionMainView.constant =
//                self.MainCollectionView.frame.width-(self.MainCollectionView.frame.width*0.23)
//        } else {
//            self.CollectionMainView.constant =
//                self.MainCollectionView.frame.width+(self.MainCollectionView.frame.width*0.23)
//        }
        
        
        for i in 0 ..< self.VerseArray.count {
            if BGImageCount >= 11 {
                BGImageCount = 0
            }
            BGImageCount = BGImageCount+1
            BGImage.append(BGImageCount)
        }
        
        
        self.WallframeFrameConstrain()
        var BookArray = Bookname!.components(separatedBy: [":", " ","-"])
                
        if let index = BookArray.firstIndex(of: "") {
            BookArray.remove(at: index)
        }
        
        
        self.WallPaperCollection.register(UINib(nibName: "WallpaperCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WallpaperCell")
         
        self.SelectedPath = Int(BookArray[BookArray.count-1])!-1
        
        
        var indexPath = IndexPath(row: Int(BookArray[BookArray.count-1])!-1, section: 0)
        BookArrayTitle =  String(format: "%@ %@", BookArray[0],BookArray[1])
        
//        if BookArray.count > 3 {
//            indexPath = IndexPath(row: Int(BookArray[3])!-1, section: 0)
//            BookArrayTitle =  String(format: "%@ %@ %@", BookArray[0],BookArray[1],BookArray[2])
//        }
        
        setupPageControl()
        
        DispatchQueue.main.async {
            self.WallPaperCollection.isPagingEnabled = false
            self.WallPaperCollection.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            self.WallPaperCollection.isPagingEnabled = true
            self.updatePageControl()
          }
        
        
        CollectionViewAnimate()
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.SaveImg, colorVu: self.Themecolor)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.CloseImg, colorVu: self.Themecolor)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.shareImg, colorVu: self.Themecolor)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.EditImg, colorVu: self.Themecolor)
        
        self.Save.ViewBorder(color: self.Themecolor)
        self.Close.ViewBorder(color: self.Themecolor)
        self.share.ViewBorder(color: self.Themecolor)
        self.Edit.ViewBorder(color: self.Themecolor)
        
        
        if PaymentHistory.sharedInstance.paymentInfo() {
            for view in self.AdBanner.subviews {
                view.removeFromSuperview()
            }
            
//            GoogleBannerAD.shared.SourceVC = SourceView
//            self.AdBanner.addSubview(GoogleBannerAD.shared.InitBanner(width: ScreenWidth, height: 74))
//            GoogleBannerAD.shared.loadAd()
            self.AdBanner.backgroundColor = .clear
        }
        
        
    }
    

    
    
//     func CollectionViewAnimate() {
//            UIView.animate(withDuration: 1.0, animations: {
//                 self.MainviewBottom.constant = self.CollectionMainView.constant
//                 self.layoutIfNeeded()
//            }, completion: { finished in
//
//            })
//    }
    
    
    func CollectionViewAnimate() {
           UIView.animate(withDuration: 1.0, animations: {
               self.MainviewBottom.constant = self.CollectionMainView.constant+120
                self.layoutIfNeeded()
           }, completion: { finished in
               
           })
   }
    
    
    @IBAction func CloseView(_ sender: Any) {
        UIView.animate(withDuration: 1.0, animations: {
             self.WallframeFrameConstrain()
             self.layoutIfNeeded()
        }, completion: { finished in
            App_Protocol.delegateReader?.CloseView()
        })
    }
    
    
    @IBAction func Close_Action(_ sender: Any) {
        UIView.animate(withDuration: 1.0, animations: {
             self.WallframeFrameConstrain()
             self.layoutIfNeeded()
        }, completion: { finished in
            App_Protocol.delegateReader?.CloseView()
        })
    }
    
    
    
    func WallframeFrameConstrain() {
        
        if StatusbarHeight > 22 {
            self.MainviewBottom.constant = -80
        } else {
            self.MainviewBottom.constant = 0
        }
    }
    
    
    
    @IBAction func EditIMage_Action(_ sender: Any) {
                
        let indexPath = IndexPath(row: SelectedPath, section: 0)
        let cell = self.WallPaperCollection.cellForItem(at: indexPath as IndexPath)  as? WallpaperCollectionViewCell
        
        App_Protocol.delegateReader?.ImageEditor(Verse:cell!.Versetext.text!,Book:cell!.Booktext.text!,Image:cell!.Wallpaper.image!)
    }
    
    
    @IBAction func Share(_ sender: Any) {
         
        let indexPath = IndexPath(row: SelectedPath, section: 0)
        DispatchQueue.main.async {
            
            self.WallPaperCollection.isPagingEnabled = false
            self.WallPaperCollection.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            self.WallPaperCollection.isPagingEnabled = true
                        
            self.WallpaperCell = self.WallPaperCollection.cellForItem(at: indexPath as IndexPath)  as? WallpaperCollectionViewCell
            self.saveImage = self.WallpaperCell!.Walpaperframe.asImage()
            
            let url = URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL = url.appendingPathComponent("\((self.WallpaperCell?.Booktext.text)! as String).png")
            try! self.saveImage?.pngData()?.write(to: fileURL)
                
//            App_Protocol.delegateReader?.sharedImage(sharedUrl:fileURL)
            App_Protocol.delegateReader?.sharedImage(sharedUrl:fileURL,VerseStr:(self.WallpaperCell?.Versetext.text)!, Bookname:(self.WallpaperCell?.Booktext.text)!)
        }
    }
    
        
    
    
    
    @IBAction func SaveImage(_ sender: Any) {
         
        let indexPath = IndexPath(row: SelectedPath, section: 0)
        self.WallpaperCell = self.WallPaperCollection.cellForItem(at: indexPath as IndexPath)  as? WallpaperCollectionViewCell
        
//        App_Protocol.delegateReader?.SliderCardPreview(Verese:(self.WallpaperCell?.Versetext.text)! , Book: (self.WallpaperCell?.Booktext.text)!)
        
                
        let saveImage = self.WallpaperCell!.Walpaperframe.asImage()
        App_Protocol.delegateReader?.SliderCardPreview(Vereseimage: saveImage)
        
        
        status = PHPhotoLibrary.authorizationStatus(for: PHAccessLevel(rawValue: PHAccessLevel.RawValue(GETALL))!)
        
        
        switch status {
        case .authorized:
            
            
            let imageRectsize = AVMakeRect(aspectRatio: saveImage.size, insideRect: UIScreen.main.bounds)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                App_Protocol.delegateReader?.OpenPreview(SavedImage: saveImage, FrameHeight: imageRectsize.height)
            }
            
            
            break


        default:
          break

        }
        
        
        
    }
    
    
    
    
    
    func ConvertIntoImage() {
            
        let indexPath = IndexPath(row: SelectedPath, section: 0)
        DispatchQueue.main.async {
            self.WallPaperCollection.isPagingEnabled = false
            self.WallPaperCollection.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            self.WallPaperCollection.isPagingEnabled = true
            self.WallpaperCell = self.WallPaperCollection.cellForItem(at: indexPath as IndexPath)  as? WallpaperCollectionViewCell
            self.saveImage = self.WallpaperCell!.Walpaperframe.asImage()
            let status = PHPhotoLibrary.authorizationStatus()
            
            if status == PHAuthorizationStatus.authorized {
                CustomPhotoAlbum.sharedInstance.saveImage(image: self.saveImage!)
                DispatchQueue.main.async {
                    self.makeToast("Image Saved Successfully!", duration: 2.0, position: .bottom)
                }
            } else {
                DispatchQueue.main.async {
                    self.makeToast("Save Image now", duration: 2.0, position: .bottom)
                }
            }
        }
    }
    
    
    
     
       @objc func image(_ image: UIImage,
           didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
           if let error = error {
               print("ERROR: \(error)")
           } else {
             self.makeToast("Image Saved Successfully!", duration: 2.0, position: .bottom)
           }
       }
        
    
    
    // MARK:- Collection view Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                  
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            return CGSize(width: self.bounds.width-10, height: Imagesize-10)
        } else {
            return CGSize(width: self.bounds.width-10, height: Imagesize-10)
        }
      }
    
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.VerseArray.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            self.WallpaperCell = (self.WallPaperCollection.dequeueReusableCell(withReuseIdentifier: "WallpaperCell", for: indexPath) as! WallpaperCollectionViewCell)
            
//            self.WallpaperCell?.TabTxt.text = TabImg ? "Share the image":"Tap on Image"
        
            
            if PaymentHistory.sharedInstance.paymentInfoVerify() {
                self.WallpaperCell!.WaterMarkVu.isHidden = false
            } else {
                self.WallpaperCell!.WaterMarkVu.isHidden = true
            }
            
            
            if indexPath.row < self.VerseArray.count &&  self.ShuffledimageArray.count > 1 {
                
                self.WallpaperCell!.Booktext.text = "\(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName) \(UserDefaults.standard.integer(forKey: "BookChapter")):\(indexPath.row+1)"
                
                if UIScreen.main.bounds.height <= 670 {
                    self.WallpaperCell!.Versetext.text = self.VerseArray[indexPath.row]
                } else {
                    self.WallpaperCell!.Versetext.attributedText = attributedTextBold1(withString: self.VerseArray[indexPath.row], boldString: self.VerseArray[indexPath.row])
                }

            } else {

                
                self.WallpaperCell!.Booktext.text = "\(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName) \(UserDefaults.standard.integer(forKey: "BookChapter")):\(indexPath.row+1)"
                
                if UIScreen.main.bounds.height <= 670 {
                    self.WallpaperCell!.Versetext.text = self.VerseArray[indexPath.row]
                } else {
                    self.WallpaperCell!.Versetext.attributedText = attributedTextBold1(withString: self.VerseArray[indexPath.row], boldString: self.VerseArray[indexPath.row])
                }
                
            }
            
            
            if PaymentHistory.sharedInstance.paymentInfoVerify() {
                self.WallpaperCell!.WaterMark.isHidden = false
            }
                        
            self.WallpaperCell!.Wallpaper.image = UIImage(named: "S\(BGImage[indexPath.row]).jpg")
            self.WallpaperCell!.BibleName.text = APPNAME_SPLASH

            
//            self.WallpaperCell!.Booktext.font = UIFont(name: UserDefaults.standard.string(forKey: "FontName")!, size: 15)
            return self.WallpaperCell!
        }
    
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            self.WallpaperCell = self.WallPaperCollection.cellForItem(at: indexPath)  as? WallpaperCollectionViewCell

            if BGImageCount >= 10 {
                BGImageCount = 0
            }
            
            TabImg = true
//            self.WallpaperCell?.TabTxt.text = "Share the image"
            BGImageCount = BGImageCount+1
            self.WallpaperCell!.Wallpaper.image = UIImage(named: "S\(BGImageCount).jpg")

            
//            self.hexStringToUIColor(hex: BGColor.randomElement()!)
        }

    
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
        let pageWidth: Float = Float(self.bounds.width) // width + space

        let currentOffset = CGFloat(scrollView.contentOffset.x)
        let targetOffset = targetContentOffset.pointee.x
        var newTargetOffset: Float = 0
         
        if targetOffset > currentOffset-(ScreenWidth/3) {
            newTargetOffset = ceilf(Float(currentOffset) / pageWidth) * pageWidth
        } else {
            newTargetOffset = floorf(Float(currentOffset) / pageWidth) * pageWidth
        }
        
        if newTargetOffset < 0 {
            newTargetOffset = 0
        } else if CGFloat(newTargetOffset) > scrollView.contentSize.width {
            newTargetOffset = Float(scrollView.contentSize.width)
        }

        targetContentOffset.pointee.x = currentOffset
        scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: 0), animated: true)
                  
        self.SelectedPath = Int((newTargetOffset / pageWidth)+0.01)
        self.updatePageControl()
        
       }
    
    
    private func setupPageControl() {
        guard pageControl.superview == nil else {
            updatePageControl()
            return
        }
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = false
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPageIndicatorTintColor = Themecolor
        pageControl.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.55)
        MainCollectionView.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: MainCollectionView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: WallPaperCollection.bottomAnchor, constant: -4),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
        updatePageControl()
    }
    
    private func updatePageControl() {
        let count = max(VerseArray.count, 1)
        pageControl.numberOfPages = count
        pageControl.currentPage = min(max(SelectedPath, 0), count - 1)
        pageControl.isHidden = count <= 1
    }
    


    func attributedTextBold1(withString string: String, boldString: String) -> NSAttributedString {
        
//        let textfontSize = CGFloat(UserDefaults.standard.float(forKey: "FontSize"))
        let attributedString = NSMutableAttributedString(string: string)
//        let NumberBold: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: textfontSize)]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .center
        
        
        let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
                
//        attributedString.addAttributes(NumberBold, range: range)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
                    
      return attributedString
    }
    
    
    
}


