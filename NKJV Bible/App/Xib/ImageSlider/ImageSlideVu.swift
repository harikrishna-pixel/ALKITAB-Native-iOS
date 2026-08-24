//
//  ImageSlider.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 17/03/21.
//

import UIKit

class ImageSlideVu: UIView, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet var ImageSliderCollectionView: UICollectionView!
    @IBOutlet weak var MenuBottom: NSLayoutConstraint!
    @IBOutlet weak var DeleteView: UIImageView!
    @IBOutlet weak var DeleteIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ShareBtn: UIButton!
    
    var SelectedCell:Int?
    var ImageSliderCell: ImageSliderCollectionViewCell?
    var ImageVC:ImageSliderVC?
    
    
    
    override func draw(_ rect: CGRect) {
        
        self.ImageSliderCollectionView.delegate = self
        self.ImageSliderCollectionView.dataSource = self
        self.DeleteIndicator.isHidden = true
        self.DeleteView.isHidden = false
        self.MenuBottom.constant = StatusbarHeight - 20.0
        
        self.ImageSliderCollectionView.register(UINib(nibName: "ImageSliderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageSliderCollectionViewCell")
        
             self.ImageSliderCollectionView.isPagingEnabled = false
             self.ImageSliderCollectionView.scrollToItem(at: IndexPath(item: self.SelectedCell!, section: 0), at: .centeredHorizontally, animated: false)
             self.ImageSliderCollectionView.isPagingEnabled = true
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      }
    
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.bounds.width-10, height: self.bounds.height-10)
      }
    
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  CustomPhotoAlbum.sharedInstance.images.count
      }
        
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        self.ImageSliderCell = (self.ImageSliderCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageSliderCollectionViewCell", for: indexPath) as! ImageSliderCollectionViewCell)
        self.ImageSliderCell!.SlideImage.image =  CustomPhotoAlbum.sharedInstance.images[indexPath.row]
            
        return self.ImageSliderCell!
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
        self.SelectedCell = Int((newTargetOffset / pageWidth)+0.01)
        
       }
    
    
    @IBAction func ShareAlbum(_ sender: Any) {
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = url.appendingPathComponent("Verses.png")
        
        try! CustomPhotoAlbum.sharedInstance.images[self.SelectedCell!].pngData()!.write(to: fileURL)
        
        DispatchQueue.main.async {
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SharedViewController") as! SharedViewController
            vc.ShareVerseImageURL = [fileURL]
            vc.VerseStr = "Verses"
            vc.VerseImgName = "Verses"
            vc.Bookname = "Verses"
            vc.VerseImgData = CustomPhotoAlbum.sharedInstance.images[self.SelectedCell!].pngData()
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            self.ImageVC!.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func DeleteImageFromAlbum(_ sender: Any) {
        
        self.ImageSliderCollectionView.isScrollEnabled = false
        
        self.ShareBtn.isEnabled = false
        self.DeleteIndicator.isHidden = false
        self.DeleteView.isHidden = true
        self.DeleteIndicator.startAnimating()
        
        
        
        CustomPhotoAlbum.sharedInstance.deleteSelectedPhotoFromGallery(ImageIndex: self.SelectedCell!)
        CustomPhotoAlbum.sharedInstance.images.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
            CustomPhotoAlbum.sharedInstance.fetchCustomAlbumPhotos()
            
            self.ImageSliderCollectionView.reloadData()
            self.makeToast(NSLocalizedString("Image Removed from App Album", comment: ""), duration: 2.0, position: .bottom)
            self.DeleteIndicator.isHidden = true
            self.DeleteView.isHidden = false
            self.DeleteIndicator.stopAnimating()
        }
        
        
        if self.SelectedCell! >= CustomPhotoAlbum.sharedInstance.images.count && self.SelectedCell != 0 {
            self.SelectedCell = self.SelectedCell!-1
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
            if CustomPhotoAlbum.sharedInstance.images.count == 0 {
                App_Protocol.Imagesliderdelegate?.DismissVc()
            }
            self.ShareBtn.isEnabled = true
            self.ImageSliderCollectionView.isScrollEnabled = true
        }
        
        NotificationCenter.default.post(name: Notification.Name("ReloadImageCell"), object: nil)
    }
}
