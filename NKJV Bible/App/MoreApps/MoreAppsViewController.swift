//
//  MoreAppsViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 04/06/24.
//

import UIKit

class MoreAppsViewController: UIViewController {
    
    @IBOutlet var MoreAppList : UICollectionView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    @IBOutlet weak var BannerVu: UIView!
    
    
    var BookDictionary: Array<Dictionary<String, AnyObject>> = []
    var book_cat_id: String = "0"
    var AllMoreLink: [String] = []
    
    
    var appId: [String] = []
    var appName: [String] = []
    var thumburl: [String] = []
    var appurl: [String] = []
    var developed_by: [String] = []
    var apptype: [String] = []
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        self.MoreAppList!.register(UINib(nibName: "BookCell", bundle: nil), forCellWithReuseIdentifier: "BookCell")
        self.BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        
        let cellSize = CGSize(width:(ScreenWidth/3)-12 , height:(ScreenWidth/3)+78)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        layout.minimumLineSpacing = 6.0
        layout.minimumInteritemSpacing = 0.0
        self.MoreAppList.setCollectionViewLayout(layout, animated: true)

        
        self.ApiCall(Apiid: book_cat_id)
    }
    
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    func ApiCall(Apiid:String) {
        
        self.AllMoreLink = CoreDataModel.sharedInstance.GetAppImageSave(entity: CDMoreAppApi)
        
        
        self.appId.removeAll()
        self.appName.removeAll()
        self.apptype.removeAll()
        self.appurl.removeAll()
        self.developed_by.removeAll()
        self.thumburl.removeAll()
            

        for item in self.AllMoreLink {
            let itemSeperate = item.components(separatedBy: "####")
            
            self.appId.append(itemSeperate[0])
            self.appName.append(itemSeperate[1])
            self.apptype.append(itemSeperate[2])
            self.appurl.append(itemSeperate[3])
            self.developed_by.append(itemSeperate[4])
            self.thumburl.append(itemSeperate[5])
            
        }
        
        
        self.MoreAppList.reloadData()
    }
    
    

}

extension MoreAppsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return self.appName.count
       }
       

     
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

           
        let cell = self.MoreAppList!.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
            cell.BookCatagoryList.text = self.appName[indexPath.item]
           
           if let CoverImage = ImageLoader.getImageFromDir(imageName: self.thumburl[indexPath.item], FolderName: "AppimageS") {
               cell.BookImage.image = CoverImage.imageWithSize(scaledToSize: CGSize(width: ScreenWidth/3, height: ScreenWidth/3))
           } else {
               cell.BookImage.image = UIImage(named: "appPlaceholder")
           }
           
            cell.BookImage.layer.cornerRadius = (ScreenWidth/3)/9
            cell.layer.cornerRadius = (ScreenWidth/3)/9
           
           cell.BookLinkBtn.tag = indexPath.item
           cell.BookLinkBtn.addTarget(self, action: #selector(ClickBookLink), for: .touchUpInside)
           cell.BookLinkBtn.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
           
           cell.BookImgLinkBtn.tag = indexPath.item
           cell.BookImgLinkBtn.addTarget(self, action: #selector(ClickBookLink), for: .touchUpInside)
           
    
         return cell
       }
    

    
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
   }
    
    
    
    
    @objc func ClickBookLink(sender: UIButton!) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
                   if let url = URL(string: self.appurl[sender.tag]), UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url, options: [:]) { success in
                           print(success ? "URL was opened successfully." : "Failed to open URL.")
                       }
                   } else {
                       self.view.makeToast("Invalid URL or cannot open.", duration: 2.0, position: .bottom)
                   }
                   
               } else {
                   self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
               }
    }
    
    
    
}
