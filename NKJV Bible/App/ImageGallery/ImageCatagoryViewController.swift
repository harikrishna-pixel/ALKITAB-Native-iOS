//
//  ImageCatagoryViewController.swift
//  Smart Bible
//
//  Created by ajayprasanth on 23/11/23.
//

import UIKit
import SDWebImage

class ImageCatagoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var ImageList:UICollectionView!
    @IBOutlet weak var Banner: UIView!
    @IBOutlet weak var BannerTitle: UILabel!
    @IBOutlet weak var LoaderVu: UIView!
    
    
    var category:String = ""
    var TitleTxt:String = ""
    
    var Gallerytitle:[String] = []
    var category_id:[String] = []
    var Gallary_Api:[String] = []
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.BannerTitle.text = TitleTxt
        
        
        
        let cellSize = CGSize(width:(ScreenWidth/2)-9, height:(ScreenWidth/2)-9)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        layout.minimumLineSpacing = 6.0
        layout.minimumInteritemSpacing = 0.0
        self.ImageList.setCollectionViewLayout(layout, animated: true)
        
        
        Banner.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        let parameters:Dictionary<String, AnyObject> = ["app_id": category as AnyObject,
                                                         "device_type": dev_id_type as AnyObject,
                                                         "package_name": bundleID as AnyObject,
                                                        "app_version": appVersion as AnyObject]


        ImageGalleryViewModel.sharedInstance.ImageFromGallery(urlString: IMAGECATEGORY, params: parameters, completion: {(resultDictionary, error) -> () in

            if resultDictionary != nil {
                
                let data = resultDictionary!["data"] as! Dictionary<String, AnyObject>
                let img_list = data["category_list"]! as! Array<Dictionary<String, AnyObject>>
                
                
                self.Gallerytitle = img_list.map { ($0["category_name"] as? String)! }
                self.category_id = img_list.map { ($0["category_id"] as? String)! }
                self.Gallary_Api = img_list.map { ($0["cat_thumb_img_url"] as? String)! }

                
                DispatchQueue.main.async {
                    self.ImageList.reloadData()
                    self.LoaderVu.isHidden = true
                }
            }
        })
        
        
        
    }
    

    @IBAction func Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}



extension ImageCatagoryViewController {
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//          return UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 5)
//      }

//      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//          return CGSize(width: (self.ImageList.frame.width/2)-10, height: (self.ImageList.frame.width/2)-10)
//      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.Gallerytitle.count
    }
    
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = self.ImageList.dequeueReusableCell(withReuseIdentifier: "CatagoryCell", for: indexPath) as! CatagoryCell
            
            cell.TitleLbl.text = self.Gallerytitle[indexPath.row]
//            cell.PexelImage.sd_setImage(with: URL(string: Gallary_Api[indexPath.row]), placeholderImage: UIImage(named: "placeholder"))
            
            
            let transformer = SDImageResizingTransformer(size: cell.frame.size, scaleMode: .aspectFill)

            
        
            cell.PexelImage.sd_setImage(
                with: URL(string: self.Gallary_Api[indexPath.row]),
                placeholderImage: UIImage(named: "ap=pPlaceholder"),
                context: [.imageTransformer: transformer]
            )
            
            cell.layer.cornerRadius = 3
            
            return cell
        }
    
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            let vc = kStoryboardImageGallery.instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
            vc.category_id = self.category_id[indexPath.row]
            vc.SearchTxt = "Bible%20Quotes"
            vc.Gallerytitle = self.Gallerytitle[indexPath.row]
            vc.Gallary_Api = IMAGEGALLERY_API
            vc.MainTitle = TitleTxt
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    
    
    
}



