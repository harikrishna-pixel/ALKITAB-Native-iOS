//
//  CreateImageViewController.swift
//  Smart Bible
//
//  Created by ajayprasanth on 02/09/23.
//

import UIKit
import SDWebImage

class CreateImageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var ImageCellView: UICollectionView!
    @IBOutlet weak var Loader: UIView!
    @IBOutlet weak var SlideTitle: UILabel!
    
    @IBOutlet weak var frameBottom: NSLayoutConstraint?
    @IBOutlet weak var Banner: UIView?
    @IBOutlet weak var BannerHeight: NSLayoutConstraint?
    
    
//    var originalApi:[String] = []
    var mediumApi:[String] = []
    var ImageApi:[String] = []
//    var FolderImageApi:[URL] = []
    var MainTitle:String = ""
    var OFFAdd:Bool = false
    var SelectedImage:String = ""
    
    var imageRectsize: CGRect = CGRect(x: 0, y: 0, width: 0, height: 200)
    
    var ADView: UIView!
     
    
    
    
    var Img:String = ""
    var ImgVerse:[String] = []
    var ImgVerseTitle:[String] = []
    var saveImage:UIImage?
    var ImgPosition:[Int] = []
    var ShareImg:[URL] = []
    
    var Imgcount = 0
    var SelectedPath: Int = 0
    var ImgHeight = ScreenHeight-(160+StatusbarHeight)
    var ImageCell:ImageOpenCollectionViewCell?
    var fileURL: URL!
    var ImageIndex: Int = 0
    
    var FolderImage: Bool = false
    var PageTitle: String = "Image"
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    let loopMultiplier = 1000
    var loopedImages: [String] = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ADView =  UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width-10, height: ImgHeight))
        
//        self.frameBottom.constant = 0
        Banner?.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        for _ in 0 ..< ImgVerseTitle.count {
            ImgPosition.append(Int.random(in: 1..<10))
        }
                 
        
        if PaymentHistory.sharedInstance.paymentInfo() && GOOGLE_NATIVE_AD_ID != "" {
            for i in 0 ..< mediumApi.count {
                if (i != 0) && (i % 8 == 0) {
                    self.ImageApi.append("ADS")
                 }
                self.ImageApi.append(self.mediumApi[i])
            }
        } else {
            self.ImageApi = self.mediumApi
        }
        
        
        if !SelectedImage.isEmpty {
            ImageIndex = self.ImageApi.firstIndex(of: SelectedImage) ?? 0
        }
        
        
        // Safely set banner height if outlet is connected
        BannerHeight?.constant = LiveBannerHeight(for: view)
        
        
        self.SlideTitle.text = self.PageTitle
        self.SelectedPath = ImageIndex
         
        
        let indexPath = IndexPath(row: ImageIndex, section: 0)
        
        DispatchQueue.main.async {
            self.ImageCellView.isPagingEnabled = false
            self.ImageCellView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
            self.ImageCellView.isPagingEnabled = true
          }
        
        
        
        let cellSize = CGSize(width:ScreenWidth, height:ScreenHeight-160 )
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.ImageCellView.setCollectionViewLayout(layout, animated: true)
        
        
        
        for _ in 0..<loopMultiplier {
                   loopedImages += self.ImageApi
               }
        
        
        
        self.ImageCellView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        if PaymentHistory.sharedInstance.paymentInfoVerify() {
//            self.AdBannerView.isHidden = false
//            DispatchQueue.main.async {
//                GoogleBannerAD.shared.SourceVC = self
//                self.AdBannerView.addSubview(GoogleBannerAD.shared.InitBanner(width: self.view.frame.width, height: self.AdBannerView.frame.height, BannerId: GOOGLE_BANNER_ADS_ID3))
//                GoogleBannerAD.shared.loadAd()
//            }
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) {
            self.ImageCellView.reloadData()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    
    
    @IBAction func Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func Save(_ sender: Any) {
        
//        self.Loader.isHidden = false
//        DispatchQueue.main.async {
//            ImageLoader.image(for: URL(string: self.originalApi[self.SelectedPath])!) { image in
//                SaveImage.sharedInstance.Save(Mainview:self, saveImage: image!)
//                self.Loader.isHidden = true
//            }
//        }
        
        
        if PaymentHistory.sharedInstance.paymentInfo()  {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.6) {
                AdmobManager.shared.IronSource_Interstitial_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!)
            }
        }
        
        self.downloadImage(for: URL(string: self.ImageApi[self.SelectedPath])!, completionHandler: { image in
            SaveImage.sharedInstance.Save(Mainview:self, saveImage: image!)
        })
        
        
    }
    
    
        
    
    func downloadImage(for url: URL, completionHandler: @escaping(_ image: UIImage?) -> ()) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            completionHandler(UIImage(data: data))
        }
    }
    
    
    
    
    
    
    
     
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    
    @IBAction func Like_Action(_ sender: Any) {
        
    }
    
    
    
    
    
    func ImageCreate() {
        if Imgcount < ImgVerseTitle.count {
            self.ImageSave(Imgcount:Imgcount)
            Imgcount = Imgcount+1
        } else {
            self.sharedImage(sharedUrl: self.ShareImg)
        }
    }
    
    
    
    
    
    func ImageSave(Imgcount:Int) {
        
        let indexPath = IndexPath(row: Imgcount, section: 0)
        
        self.ImageCellView.isPagingEnabled = false
        self.ImageCellView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        self.ImageCellView.isPagingEnabled = true
         
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
            self.ImageCell = self.ImageCellView.cellForItem(at: indexPath as IndexPath)  as? ImageOpenCollectionViewCell
            
            let url = URL(fileURLWithPath: NSTemporaryDirectory())
            self.fileURL = url.appendingPathComponent("\(self.ImgVerse[indexPath.row]).png")
            try! self.ImageCell!.ImgFrame.asImage().pngData()?.write(to: self.fileURL)
            
            self.ShareImg.append(self.fileURL)
            self.ImageCreate()
        }
        
    }
    
    
    
    
    func sharedImage(sharedUrl:[URL]) {
        
        let activityViewController = UIActivityViewController(activityItems: sharedUrl, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            self.dismiss(animated: true, completion: nil)
//            FileManager.default.clearTmpDirectory()
        }
    }
    
    
}




extension CreateImageViewController {
    
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return  self.loopedImages.count
      }
        
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        self.ImageCell = (self.ImageCellView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageOpenCollectionViewCell)

         
         if self.loopedImages[indexPath.row] == "ADS" {

             self.ImageCell!.ADView.isHidden = false
             self.ImageCell!.ADView.addSubview(ADView)
             self.ImageCell!.Img.isHidden = true
             self.ImageCell!.BottomMenu.isHidden = true
         } else {
             self.ImageCell!.ADView.isHidden = true
             self.ImageCell!.Img.isHidden = false
             self.ImageCell!.BottomMenu.isHidden = false
             
             // Set content mode BEFORE loading image
             if MainTitle == "Wallpaper" {
                 self.ImageCell!.Img.contentMode = .scaleAspectFill
             } else {
                 self.ImageCell!.Img.contentMode = .scaleAspectFit
             }
             
             // Load image based on source type
             if FolderImage {
                 if let image = UIImage(contentsOfFile: self.loopedImages[indexPath.row]) {
                     self.ImageCell!.Img.image = image
                 } else {
                     // If image fails to load, show placeholder
                     self.ImageCell!.Img.image = UIImage(named: "appPlaceholder")
                 }
             } else {
                 // Load from URL with error handling and caching
                 if let url = URL(string: loopedImages[indexPath.row]) {
                     // Check if image is already cached
                     if let cachedImage = SDImageCache.shared.imageFromCache(forKey: url.absoluteString) {
                         self.ImageCell!.Img.image = cachedImage
                     } else {
                         // Set placeholder first, then load from URL
                         self.ImageCell!.Img.image = UIImage(named: "appPlaceholder")
                         // Load with high priority for visible cells
                         self.ImageCell!.Img.sd_setImage(with: url, placeholderImage: UIImage(named: "appPlaceholder"), options: [.highPriority, .progressiveLoad])
                     }
                 } else {
                     self.ImageCell!.Img.image = UIImage(named: "appPlaceholder")
                 }
             }
             
             self.ImageCell!.DownloadImg.addTarget(self, action: #selector(ShareIMgs), for: .touchUpInside)
         }
    
         
        return self.ImageCell!
     }
    
    
    
    
    @objc func downloadAll() {
        self.Loader.isHidden = false
        DispatchQueue.main.async {
            ImageLoader.image(for: URL(string: self.ImageApi[self.SelectedPath])!) { image in
                SaveImage.sharedInstance.Save(Mainview:self, saveImage: image!)
                self.Loader.isHidden = true
            }
        }
    }
    
    
    @objc func ShareIMgs() {
        
        self.Loader.isHidden = false
 
        let Path = self.ImageApi[self.SelectedPath].components(separatedBy: "/")
        
        DispatchQueue.main.async {
            
            let url = URL(fileURLWithPath: NSTemporaryDirectory())
            self.fileURL = url.appendingPathComponent(Path[Path.count-1])
            
            if self.FolderImage {
                try! UIImage(contentsOfFile: self.ImageApi[self.SelectedPath])!.pngData()?.write(to: self.fileURL)
                self.sharedImage(sharedUrl: [self.fileURL])
                self.Loader.isHidden = true
            } else {
                ImageLoader.image(for: URL(string: self.ImageApi[self.SelectedPath])!) { image in
                    try! image!.pngData()?.write(to: self.fileURL)
                    self.sharedImage(sharedUrl: [self.fileURL])
                    self.Loader.isHidden = true
                }
            }
        }
    }
    
    

    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth: Float = Float(self.view.bounds.width) // width + space

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
                
        
//        self.AdBannerView.isHidden = false
        
        // FIXED: Update SelectedPath when index is WITHIN bounds (was inverted logic)
        let newIndex = Int((newTargetOffset / pageWidth))
        if newIndex >= 0 && newIndex < self.loopedImages.count {
            self.SelectedPath = newIndex
            self.SlideTitle.text = (self.loopedImages[self.SelectedPath] == "ADS" ? "Advertisement":self.PageTitle)
        }
        
        
    }
    
    // Track current visible image when scrolling ends
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedPath(for: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateSelectedPath(for: scrollView)
    }
    
    private func updateSelectedPath(for scrollView: UIScrollView) {
        let pageWidth = self.view.bounds.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        
        if currentPage >= 0 && currentPage < self.loopedImages.count {
            self.SelectedPath = currentPage
            self.SlideTitle.text = (self.loopedImages[self.SelectedPath] == "ADS" ? "Advertisement" : self.PageTitle)
        }
    }
    
    
    
    
}







//extension CreateImageViewController {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//          return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//      }
//
//      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//            return CGSize(width: 129, height: 115)
//      }
//
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            return 2
//        }
//
//
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//            let cell = (self.ImageCellView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell)
//
//            cell.ImgHeight.constant = 107
//            cell.ImgWidth.constant = 121
//
//            return cell
//        }
//
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//    }
//
//
//
//}


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFill) {
        contentMode = mode
        self.image = UIImage(named: "placeholder")
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


extension UIView {
    func addInnerShadow(shadowOpacity:Float, shadowRadius:CGFloat) {
        let innerShadow = CALayer()
//        innerShadow.frame = bounds
        
        innerShadow.frame = bounds
        
        
        // Shadow path (1pt ring around bounds)
        let radius = self.layer.cornerRadius
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: 2, dy:2), cornerRadius:radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius:radius).reversing()
        
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        
        // Shadow properties
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 0)
        innerShadow.shadowOpacity = shadowOpacity
        innerShadow.shadowRadius = shadowRadius
        innerShadow.cornerRadius = self.layer.cornerRadius
        layer.addSublayer(innerShadow)
    }
}
