//
//  BookAdListViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 31/05/24.
//

import UIKit

class BookAdListViewController: UIViewController {
    @IBOutlet var BookCatagory : UICollectionView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    @IBOutlet weak var BannerVu: UIView!
    
    
    var BookDictionary: Array<Dictionary<String, AnyObject>> = []
    var book_cat_id: String = "0"
    var AllMoreLink: [String] = []
    
    var bookThumbURL: [String] = []
    var book_age: [String] = []
    var book_id: [String] = []
    var book_name: [String] = []
    var book_published_by: [String] = []
    var book_url: [String] = []
    var storeTitle: [String] = []
    
    var embeddedInReader = false
    var ImgWidth: CGFloat = 0.0
    var ImgHeight: CGFloat = 0.0
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        self.BookCatagory!.register(UINib(nibName: "BookCell", bundle: nil), forCellWithReuseIdentifier: "BookCell")
        applyExploreBooksHeader()
        
        
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            self.ImgWidth = (ScreenWidth/3)-12
            self.ImgHeight = (ScreenWidth/2)
        } else {
            self.ImgWidth = (ScreenWidth/2)-12
            self.ImgHeight = (ScreenWidth/1.2)
        }
        
        
        let cellSize:CGSize = CGSize(width:self.ImgWidth , height:self.ImgHeight)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        layout.minimumLineSpacing = 6.0
        layout.minimumInteritemSpacing = 0.0
        self.BookCatagory.setCollectionViewLayout(layout, animated: true)

        
        self.ApiCall(Apiid: book_cat_id)
    }
    
    
    
    
    func ApiCall(Apiid:String) {
        loadBooksFromStore()
        BookCatagory?.reloadData()

        // Screen only reads Core Data; if empty, fetch once and reload.
        guard AllMoreLink.isEmpty,
              NetworkManager.sharedInstance.isConnectedToInternet() else { return }
        BookApi.shared.GetBookCatagory { [weak self] in
            DispatchQueue.main.async {
                self?.loadBooksFromStore()
                self?.BookCatagory?.reloadData()
            }
        }
    }

    private func loadBooksFromStore() {
        AllMoreLink = CoreDataModel.sharedInstance.GetMoreBookShare(entity: CDMoreBookApi)

        bookThumbURL.removeAll()
        book_age.removeAll()
        book_id.removeAll()
        book_name.removeAll()
        book_published_by.removeAll()
        book_url.removeAll()
        storeTitle.removeAll()

        for item in AllMoreLink {
            let itemSeperate = item.components(separatedBy: "####")
            guard itemSeperate.count > 6 else { continue }
            bookThumbURL.append(itemSeperate[0])
            book_age.append(itemSeperate[1])
            book_id.append(itemSeperate[2])
            book_name.append(itemSeperate[3])
            book_published_by.append(itemSeperate[4])
            book_url.append(itemSeperate[5])
            storeTitle.append(itemSeperate[6])
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyExploreBooksHeader()
    }

    /// Header matches the Explore Books screen: title plus the Ads badge.
    private func applyExploreBooksHeader() {
        guard let title = BannerVu.subviews.compactMap({ $0 as? UILabel }).first else { return }
        title.text = "Explore Books"
        title.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        for constraint in BannerVu.constraints where (constraint.firstItem as? UILabel) == title && constraint.firstAttribute == .centerX {
            constraint.constant = -22
        }

        let badgeTag = 77120
        let badge: UILabel
        if let existing = BannerVu.viewWithTag(badgeTag) as? UILabel {
            badge = existing
        } else {
            let label = UILabel()
            label.tag = badgeTag
            label.text = "Ads"
            label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            label.textColor = .white
            label.textAlignment = .center
            label.layer.borderColor = UIColor.white.cgColor
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 9
            label.clipsToBounds = true
            BannerVu.addSubview(label)
            badge = label
        }
        let badgeHeight: CGFloat = 18
        badge.frame = CGRect(x: title.frame.maxX + 8, y: title.frame.midY - badgeHeight / 2, width: 36, height: badgeHeight)
    }

    @IBAction func Back(_ sender: Any) {
        if embeddedInReader, let reader = parent as? ReaderViewController {
            reader.closeExploreBooks()
            return
        }
        navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension BookAdListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    


       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return self.book_name.count
       }
       

     
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

           
        let cell = self.BookCatagory!.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
            cell.BookCatagoryList.text = self.book_name[indexPath.item]
           
           
           if let CoverImage = ImageLoader.getImageFromDir(imageName: self.bookThumbURL[indexPath.item], FolderName: "BookImageS") {
               cell.BookImage.image = CoverImage.imageWithSize(scaledToSize: CGSize(width: self.ImgWidth, height: self.ImgHeight))
           } else {
               cell.BookImage.image = UIImage(named: "bookplaceholder")!.imageWithSize(scaledToSize: CGSize(width: self.ImgWidth, height: self.ImgHeight))
           }
           
           
           cell.BookLinkBtn.tag = indexPath.item
           cell.BookLinkBtn.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
           
           cell.BookLinkBtn.addTarget(self, action: #selector(ClickBookLink), for: .touchUpInside)
           cell.BookImgLinkBtn.tag = indexPath.item
           cell.BookImgLinkBtn.addTarget(self, action: #selector(ClickBookLink), for: .touchUpInside)
           
    
         return cell
       }
    

   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
   }
    
    
    
    
    @objc func ClickBookLink(sender: UIButton!) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
                   if let url = URL(string: self.book_url[sender.tag]), UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url, options: [:]) { success in
                           print(success ? "URL was opened successfully." : "Failed to open URL.")
                       }
                   } else {
                       self.view.makeToast("Invalid URL or cannot open.", duration: 2.0, position: .top)
                   }
                   
               } else {
                   self.view.makeToast("No internet connection", duration: 2.0, position: .top)
               }
        
    }
    
    
}
