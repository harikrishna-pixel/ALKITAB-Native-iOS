
//
//  MyLibraryViewController.swift
//  Smart Bible
//
//  Created by ajayprasanth on 17/08/23.
//



import UIKit
import Photos

class MyLibraryViewController: UIViewController, MyLibraryDelegate, UIGestureRecognizerDelegate {

    
    
    
    @IBOutlet var TitleCollection: UICollectionView!
    
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var ImageGalleryView: UIView!
//    @IBOutlet weak var Bookmark: UIView!
//    @IBOutlet weak var Highlites: UIView!
//    @IBOutlet weak var Notes: UIView!
//    @IBOutlet weak var Images: UIView!
//
//    @IBOutlet weak var BookmarkImg: UIImageView!
//    @IBOutlet weak var HighlitesImg: UIImageView!
//    @IBOutlet weak var NotesImg: UIImageView!
//    @IBOutlet weak var ImagesImg: UIImageView!
//
//    @IBOutlet weak var BookmarkTxt: UILabel!
//    @IBOutlet weak var HighlitesTxt: UILabel!
//    @IBOutlet weak var NotesTxt: UILabel!
//    @IBOutlet weak var ImagesTxt: UILabel!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var ImageBottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var ListBottomConstrain: NSLayoutConstraint!
    
    
    var status: PHAuthorizationStatus?
    var corevalue:Array<String>?
    var ColorArray:Array<String> = []
    var NotesArray:Array<String> = []
    var BookmarkArray:Array<String> = []
    var UnderlineArray:Array<String> = []
    var ExplanationsArray:Array<String> = []
    
    
    private let titles = ["BookMark", "Highlights", "Underline", "Notes", "Explanations", "Images"]
    private let titlesimg = ["bookmark-gray",  "Hightlight", "underline",  "note-gray",  "ExplainVerse",  "image-gray" ]
    
    
    
    
    
    var MyLibraryCell:MyLibraryCollectionViewCell!
    
    @IBOutlet weak var SearchListFrame: UIView!
    
    weak var SearchCollectionMVC: SearchCollectionMainView?
    weak var PopupMenuView: PopupMenu?
    
    var CellTitle:String?
    var myView:UIView?
    var selectedItem:Int = 0
    var Themecolor:UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor

        self.TitleCollection.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        self.view.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        
        self.status = PHPhotoLibrary.authorizationStatus()
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
                
        self.CellTitle = "BookMark"
        self.ReloadAllData()
        
        App_Protocol.delegateMyLibrary = self
        

                
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
        
        // Create right swipe gesture recognizer
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
        
        
        
    }
    
    
    @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
            if gestureRecognizer.direction == .left {
                if self.selectedItem < 5 {
                    self.selectedItem = self.selectedItem+1
                }
            } else if gestureRecognizer.direction == .right {
                if self.selectedItem > 0 {
                    self.selectedItem = self.selectedItem-1
                }
            }
                
          self.ReloadAllData()
          self.TitleCollection.reloadData()
          let indexPath = IndexPath(row: self.selectedItem, section: 0)
          self.TitleCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        
            if indexPath.row == titles.count-1 && self.status == .authorized {
                App_Protocol.IMageReloaddelegate?.LoadImage()
             }
        
        }
    
    
    
    
    func Defaultselection() {
//        Bookmark.ViewShadow(17, color: .black)
//        Highlites.ViewShadow(17, color: .black)
//        Notes.ViewShadow(17, color: .black)
//        Images.ViewShadow(17, color: .black)
        
//        ImageTint.sharedInstance.imageTintcolorMethod(img: self.BookmarkImg!, colorVu: .gray)
//        ImageTint.sharedInstance.imageTintcolorMethod(img: self.HighlitesImg!, colorVu: .gray)
//        ImageTint.sharedInstance.imageTintcolorMethod(img: self.NotesImg!, colorVu: .gray)
//        ImageTint.sharedInstance.imageTintcolorMethod(img: self.ImagesImg!, colorVu: .gray)
        
         
//        self.BookmarkTxt.textColor = .gray
//        self.HighlitesTxt.textColor = .gray
//        self.NotesTxt.textColor = .gray
//        self.ImagesTxt.textColor = .gray
        
        CoreDataConfig()
    }
    
    
    
    @objc func CoreDataConfig() {
        self.ColorArray.removeAll()
        self.NotesArray.removeAll()
        self.BookmarkArray.removeAll()
        self.UnderlineArray.removeAll()
        self.ExplanationsArray.removeAll()
        self.corevalue = CoreDataModel.sharedInstance.GetAllData(entity: CDBookSavedInfo)
        self.ExplanationsArray = CoreDataModel.sharedInstance.GetAllExplanations(entity: CDVerseExplanation)
        
        
        for i in 0 ..< self.corevalue!.count {
            
            let item = self.corevalue![i].components(separatedBy: "_")
            
            
            if (item[1] != "" && item[1] != "#000000") {
                self.ColorArray.append(self.corevalue![i])
            }
            if item[2] != "" {
                self.NotesArray.append(self.corevalue![i])
            }
            if item[4] == "bookMarked" {
                self.BookmarkArray.append(self.corevalue![i])
            }
            if item[5] == "true" {
                self.UnderlineArray.append(self.corevalue![i])
            }
        }
                
    }
    
    
        
        

    @IBAction func BookmarkAction(_ sender: Any) {
        
//        self.ReloadAllData()
    }
    
    @IBAction func HighlightAction(_ sender: Any) {
        
//        self.ReloadAllData()
    }
    
    @IBAction func NoteAction(_ sender: Any) {
        
//        self.ReloadAllData()
    }
    
    @IBAction func ImageAction(_ sender: Any) {
        Defaultselection()
//        Images.ViewShadow(17, color: PrimaryColor)
//        ImageTint.sharedInstance.imageTintcolorMethod(img: self.ImagesImg! , colorVu: self.Themecolor!)
//        self.ImagesTxt.textColor = self.Themecolor!
    }
    
    
    
    
    func ReloadAllData() {

        Defaultselection()
        self.ImageGalleryView.isHidden = true
        
        for view in self.SearchListFrame.subviews {
            view.removeFromSuperview() }
        
        self.SearchCollectionMVC = SearchCollectionMainView.fromNib(named: "SearchCollectionMainView")
        
        
        switch self.selectedItem {
        case 0:
            self.CellTitle = "BookMark"
            self.SearchCollectionMVC!.corevalue = self.BookmarkArray
            self.SearchCollectionMVC!.coreTitle = self.CellTitle
//            self.CollecrtionNibinit(Sublist: self.BookmarkArray)

        case 1:
            self.CellTitle = "Highlites"
            self.SearchCollectionMVC!.corevalue = self.ColorArray
            self.SearchCollectionMVC!.coreTitle = self.CellTitle
//            self.CollecrtionNibinit(Sublist: self.ColorArray)
            
        case 2:
            self.CellTitle = "Underline"
            self.SearchCollectionMVC!.corevalue = self.UnderlineArray
            self.SearchCollectionMVC!.coreTitle = self.CellTitle
//            self.CollecrtionNibinit(Sublist: self.UnderlineArray)
        case 3:
            self.CellTitle = "Notes"
            self.SearchCollectionMVC!.corevalue = self.NotesArray
            self.SearchCollectionMVC!.coreTitle = self.CellTitle
//            self.CollecrtionNibinit(Sublist: self.NotesArray)
            
        case 4:
            self.CellTitle = "Explanations"
            self.SearchCollectionMVC!.corevalue = self.ExplanationsArray
            self.SearchCollectionMVC!.coreTitle = self.CellTitle

        case 5:
            self.CellTitle = "Notes"
            self.SearchCollectionMVC!.coreTitle = self.CellTitle
            self.ImageGalleryView.isHidden = false
        default: break

        }
        
        self.SearchCollectionMVC!.frame = self.SearchListFrame!.bounds
        self.SearchCollectionMVC!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.SearchListFrame!.addSubview(self.SearchCollectionMVC!)
        self.SearchListFrame!.backgroundColor! = UIColor.clear
        
        
    }
    
    
    
    
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func CollecrtionNibinit(Sublist:Array<String>) {
        for view in self.SearchListFrame.subviews {
            view.removeFromSuperview() }
                
        
        self.SearchCollectionMVC = SearchCollectionMainView.fromNib(named: "SearchCollectionMainView")
        self.SearchCollectionMVC!.corevalue = Sublist
        self.SearchCollectionMVC!.coreTitle = self.CellTitle
        self.SearchCollectionMVC!.frame = self.SearchListFrame!.bounds
        self.SearchCollectionMVC!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.SearchListFrame!.addSubview(self.SearchCollectionMVC!)
        self.SearchListFrame!.backgroundColor! = UIColor.clear
        
    }
    
    
    func popupvuew(SelectedVerse:String,SelectedTag:String) {
                
        App_Protocol.delegateReader?.CallMenu(getString: SelectedVerse, VCSelection: "Library", TagSelection:SelectedTag)
        
//        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
//        self.view.addSubview(self.myView!)
//        self.PopupMenuView = PopupMenu.fromNib(named: "PopupMenu")
//        self.PopupMenuView!.getString = SelectedVerse
//        self.PopupMenuView!.TagSelection = SelectedTag
//        self.PopupMenuView!.frame = self.myView!.bounds
//        self.PopupMenuView!.VCSelection = "Library"
//        self.PopupMenuView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.myView!.addSubview(self.PopupMenuView!)
        
    }
    
    
    
    
    func CloseView() {
        if self.myView != nil {
            self.myView?.removeFromSuperview()
        }
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



@available(iOS 13.4, *)
extension MyLibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {


        self.MyLibraryCell = (self.TitleCollection.dequeueReusableCell(withReuseIdentifier: "MyLibraryCell", for: indexPath) as! MyLibraryCollectionViewCell)

        self.MyLibraryCell.TitleImage.image = UIImage(named: self.titlesimg[indexPath.row])

        if selectedItem == indexPath.row {
            
            self.MyLibraryCell.TitleView.ViewShadow((isIpad ? 25:15), color: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
            
            
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.MyLibraryCell.TitleImage! , colorVu: ((Themecolor == BGNightMode ? .black:Themecolor)!))
            self.MyLibraryCell.TitleLbl.textColor = (Themecolor == BGNightMode ? .black:Themecolor)
            
        } else {
            
            self.MyLibraryCell.TitleView.ViewShadow((isIpad ? 25:15), color: .black)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.MyLibraryCell.TitleImage! , colorVu: (Themecolor == BGNightMode ? LibraryTitleColor:.gray))
            
            self.MyLibraryCell.TitleLbl.textColor = (Themecolor == BGNightMode ? LibraryTitleColor:.gray)

        }
        self.MyLibraryCell.TitleLbl.text = self.titles[indexPath.row]
        return self.MyLibraryCell!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: (isIpad ? 60:40))
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedItem = indexPath.row
        self.ReloadAllData()
        self.TitleCollection.reloadData()
        self.TitleCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        if indexPath.row == titles.count-1 && self.status == .authorized {
            App_Protocol.IMageReloaddelegate?.LoadImage()
        }
        
        
    }




}

