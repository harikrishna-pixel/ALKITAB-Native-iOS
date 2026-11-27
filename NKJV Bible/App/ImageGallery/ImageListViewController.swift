//
//  ImageListViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 19/06/24.
//

import UIKit
import SDWebImage

class ImageListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var SmallIconApi:[String] = []
    var originalApi:[String] = []
    var mediumApi:[String] = []
    
    
    @IBOutlet weak var BannerTitle: UILabel!
    
    @IBOutlet weak var ImageList:UICollectionView!
    @IBOutlet weak var LoaderVu: UIView!
    @IBOutlet weak var Banner: UIView!
    
    var ADView: UIView!
    
    var SearchTxt:String = "jesus"
    var Gallerytitle:String = ""
    var category_id:String = ""
    var Gallary_Api:String = ""
    
    var MainTitle:String = ""
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    var ImageApi:[String] = []
    var cellSize:CGSize = .zero //CGSize(width:(ScreenWidth/2)-9, height:(ScreenWidth/1.2))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        Banner.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
//        if MainTitle == "Wallpaper" {
//            cellSize = CGSize(width:(ScreenWidth/2)-9, height:(ScreenWidth/1.2))
//        } else {
//            cellSize = CGSize(width:(ScreenWidth/2)-9, height:(ScreenWidth/2)-9)
//        }
//
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.itemSize = cellSize
//        layout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
//        layout.minimumLineSpacing = 6.0
//        layout.minimumInteritemSpacing = 0.0
//        self.ImageList.setCollectionViewLayout(layout, animated: true)
        
        
        
        let parameters:Dictionary<String, AnyObject> = ["category_id": category_id as AnyObject,
                                                         "device_type": dev_id_type as AnyObject,
                                                         "package_name": bundleID as AnyObject,
                                                         "app_version": appVersion as AnyObject,
                                                         "page_limit": "0" as AnyObject]


        ImageGalleryViewModel.sharedInstance.ImageFromGallery(urlString: Gallary_Api, params: parameters, completion: {(resultDictionary, error) -> () in

            defer {
                DispatchQueue.main.async {
                    self.LoaderVu?.isHidden = true
                }
            }

            guard let resultDictionary = resultDictionary,
                  let data = resultDictionary["data"] as? Dictionary<String, AnyObject>,
                  let img_list = data["img_list"] as? Array<Dictionary<String, AnyObject>> else {
                return
            }

            let urls = img_list.compactMap { $0["image_url"] as? String }
            self.SmallIconApi = urls
            self.originalApi = urls
            self.mediumApi = urls

            DispatchQueue.main.async {
                if PaymentHistory.sharedInstance.paymentInfoVerify() && GOOGLE_NATIVE_AD_ID != "" {
                    self.ImageApi.removeAll()
                    for i in 0 ..< self.mediumApi.count {
                        if (i != 0) && (i % 8 == 0) {
                            self.ImageApi.append("ADS")
                        }
                        self.ImageApi.append(self.mediumApi[i])
                    }
                } else {
                    self.ImageApi = self.mediumApi
                }
                self.ImageList?.reloadData()
                self.LoaderVu?.isHidden = true
            }
        })        
        self.BannerTitle.text = Gallerytitle
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.ADView = UIView(frame: CGRect(x: 0, y: 0, width: cellSize.width, height: cellSize.height))
        self.ADView.backgroundColor = UIColor.gray
    }
    
    

    
    
    
    
    @IBAction func Back(_ sender: Any) {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    
    
}




extension ImageListViewController {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
          return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

          if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
              if self.ImageApi[indexPath.row] == "ADS" {
                  return CGSize(width:ScreenWidth-12, height:(ScreenWidth/2))
              } else {
                  return CGSize(width:(ScreenWidth/3)-12, height:(ScreenWidth/2))
              }
          } else {
              if self.ImageApi[indexPath.row] == "ADS" {
                  return CGSize(width:ScreenWidth-12, height:(ScreenWidth/1.2))
              } else {
                  return CGSize(width:(ScreenWidth/2)-12, height:(ScreenWidth/1.2))
              }
          }
          
          
                    
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ImageApi.count
    }
    
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = self.ImageList.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            self.ADView = UIView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
            
            if self.ImageApi[indexPath.row] == "ADS" {
                cell.ADView.isHidden = false
                cell.PexelImage.isHidden = true
                for view in cell.ADView.subviews {
                       view.removeFromSuperview()
                }
                cell.ADView.addSubview(ADView)
            } else {
                cell.ADView.isHidden = true
                cell.PexelImage.isHidden = false
                
                
                let transformer = SDImageResizingTransformer(size: cell.frame.size, scaleMode: .aspectFill)

                
                cell.PexelImage.sd_setImage(
                    with: URL(string: self.ImageApi[indexPath.row]),
                    placeholderImage: UIImage(named: "appPlaceholder"),
                    context: [.imageTransformer: transformer]
                )
                
                
//                cell.PexelImage.sd_setImage(with: URL(string: ImageApi[indexPath.row]), placeholderImage: UIImage(named: "placeholder"))
            }
            
            return cell
        }
    
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if self.ImageApi[indexPath.row] != "ADS" {
                let vc = kStoryboardImageGallery.instantiateViewController(withIdentifier: "CreateImageViewController") as! CreateImageViewController
//                vc.originalApi = self.originalApi
                vc.mediumApi = self.mediumApi
                vc.ImageIndex = indexPath.row
                vc.PageTitle = Gallerytitle
                vc.MainTitle = MainTitle
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    
}



extension UITableView {
    func scrollToBottom(animated: Bool = true) {
        let section = self.numberOfSections
        if section > 0 {
            let row = self.numberOfRows(inSection: section - 1)
            if row > 0 {

                self.scrollToRow(at: IndexPath(row: row-1, section: section-1), at: .bottom, animated: animated)
            }
        }
    }
}

