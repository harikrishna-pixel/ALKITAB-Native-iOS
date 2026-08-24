//
//  SlideCardView.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 24/02/21.
//


import UIKit
import AVFoundation



class SlideCardView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SlideCard {
    func NotesSavedStatus(Status: Bool) {
        
    }
    
    func paymentStatus() {
        
    }
    
    
    
    func ChapterVers(Book: String) {
        
    }
  
    
    
    func CloseVerseView() {
        
    }
    
    
    
    func VerseSelectionAction(Chapter: Int) {
        
    }
    
    
    
    func CloseChapterView() {
        
    }
    
    
    
    func CloseVc() {
    
    }
    


    
    @IBOutlet var CardCollectionCell: UICollectionView!
    @IBOutlet weak var MenuBar:UIView!
    @IBOutlet weak var BlurVu:UIView!
    @IBOutlet weak var Current_Vu:UIView!
    @IBOutlet weak var MenuBottom: NSLayoutConstraint!
    @IBOutlet weak var PreviousVu: UIView!
    @IBOutlet weak var NextVu: UIView!
    
    @IBOutlet weak var BooktitleName: UILabel!
    @IBOutlet weak var Previous_Ch: UILabel!
    @IBOutlet weak var Next_Ch: UILabel!
    @IBOutlet weak var Current_Ch: UILabel!
    
    @IBOutlet weak var BookmarkVu: UIImageView!

    
    @IBOutlet weak var MenuConstrains: NSLayoutConstraint!
    
    
    @IBOutlet weak var PreviousChapterHeight: NSLayoutConstraint!
    @IBOutlet weak var CurrentChapterHeight: NSLayoutConstraint!
    @IBOutlet weak var NextChapterHeight: NSLayoutConstraint!
    
    
    
    let cellPercentWidth: CGFloat = 0.7
    var BibleSavedVerses:Array<String> = []
    var BookFilter:Array<String> = []
     
    var imageurlArray:Array<Dictionary<String,AnyObject>> = []
    var ShuffledimageArray:Array<String> = []
    var VerseArray:Array<String> = []
    var RandImage:Array<String> = []
    var BookArrayTitle:String = ""
    var Bookname:String?
    var SelectedPath:Int = 0
    var CellSpace:Float?
    var isfirstTimeTransform:Bool = true
    var HighlightStatus:Bool = false
    var BookName:String = ""
    var bookCount:Int = 0
    var BGImage:[Int] = []
    var BGImageCount:Int = 0
    var ImageUrl:String = ""
    var ImageUrlSelected:String = ""
    var OfflineImage:Array<String> = []
    var Book_NAme:String = ""
    var ChaterNumber:String = ""
    var DisableConerRadius:Bool = false
    
    
    
    weak var HighlighterVu: HighlighterView?
    
    
    weak var CardCell: SlideCardCell?
//    weak var HighlighterVu: HighlighterView?
    
    var saveImage:UIImage?
    var myView:UIView?
    
    let TRANSFORM_CELL_VALUE = CGAffineTransform(scaleX: 0.8, y: 0.8)
    let ANIMATION_SPEED = 0.2
  
 
    override func draw(_ rect: CGRect) {
        self.Config()
        
        MenuConstrains.constant = (isIpad ? 90:60)
        App_Protocol.DelegateSlideCard = self
        
        
        PreviousChapterHeight.constant = (isIpad ? 60:34)
        CurrentChapterHeight.constant = (isIpad ? 60:34)
        NextChapterHeight.constant = (isIpad ? 60:34)
        
        self.Current_Vu.layer.cornerRadius = (isIpad ? 30:17)
        self.PreviousVu.layer.cornerRadius = (isIpad ? 30:17)
        self.NextVu.layer.cornerRadius = (isIpad ? 30:17)
        
        self.MenuBar.layer.cornerRadius = (isIpad ? 45:30)
//
        
    }
    
    
    func Config() {
        
        DispatchQueue.main.async {
            self.CardCollectionCell.isPagingEnabled = false
            self.CardCollectionCell.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
            self.CardCollectionCell.isPagingEnabled = true
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadNotedata), name: Notification.Name("ReloadCard"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: Notification.Name("ReloadNightMode"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeHighlightStatus), name: Notification.Name("CloseHighLite"), object: nil)
        
        self.reloadView()
        self.CellSpace = Float(self.frame.width)-Float((self.bounds.width/10)*7)
        
        
        let BookArray = Bookname!.components(separatedBy: [":", "-"])
        self.VerseArray = BibleContent.sharedInstance.AudioBibleList(selecterBookName: BookArray[0], selectedId: Int(BookArray[BookArray.count-2])!-1)
        BookArrayTitle =  String(format: "%@ %@", BookArray[0],BookArray[1])
        
        ChaterNumber = BookArray[1]
        
        
        self.BooktitleName.text = BookArray[0]
        self.BookName = BookArray[0]
        self.ReloadCoredata()
        self.CardCollectionCell.delegate = self
        self.CardCollectionCell.dataSource = self
        self.CardCollectionCell.register(UINib(nibName: "SlideCardCell", bundle: nil), forCellWithReuseIdentifier: "SlideCardCell")
        
        self.MenuBottom.constant = StatusbarHeight
        self.CardCollectionCell.reloadData()
        
        self.setNeedsLayout()
        self.bookCount = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: BookArray[0])
        
        
        self.Previous_Ch.text = "Ch \(Int(BookArray[BookArray.count-2])!-1)"
        self.Next_Ch.text = "Ch \(Int(BookArray[BookArray.count-2])!+1)"
        self.Current_Ch.text = "Ch \(Int(BookArray[BookArray.count-2])!)"
        
        self.SelectedPath = 0
        BGImage.removeAll()
        
        for i in 0 ..< self.VerseArray.count {
            if BGImageCount >= 11 {
                BGImageCount = 0
            }
            BGImageCount = BGImageCount+1
            BGImage.append(BGImageCount)
        }
        
        if Int(BookArray[BookArray.count-2])!+1 == bookCount {
            self.NextVu.isHidden = true
        }
        
        self.PreviousVu.isHidden = false
        self.NextVu.isHidden = false
        
        
        if self.bookCount == Int(BookArray[BookArray.count-2])! {
            self.NextVu.isHidden = true
        }
        if self.Current_Ch.text == "Ch 1" {
            self.PreviousVu.isHidden = true
        }
                
//        UserDefaults.standard.setValue(BookURL.sharedInstance.bookURL(BookNo: BookArray[BookArray.count-2]), forKey: "Bookurl")

        
        self.CardCollectionCell.reloadData()
    }
    
    
    
    @objc func reloadView() {
        self.MenuBar.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor")
        self.Next_Ch.textColor = UserDefaults.standard.color(forKey: "AppThemeColor")
        self.Previous_Ch.textColor = UserDefaults.standard.color(forKey: "AppThemeColor")
        self.Current_Vu.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor")
        
        if (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor).toHexString() == BGNightMode.toHexString() {
            self.BlurVu.backgroundColor = BGNightMode
        } else {
            self.BlurVu.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor")?.withAlphaComponent(0.3)
        }
    }
    
    

    
    
// MARK:- COllection view Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
          if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
              return CGSize(width: self.bounds.width-10, height: self.bounds.width-10)
          } else {
              return CGSize(width: self.bounds.width-10, height: self.bounds.width+(self.bounds.width*0.20))
          }
          
      }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.VerseArray.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            self.CardCell = (self.CardCollectionCell.dequeueReusableCell(withReuseIdentifier: "SlideCardCell", for: indexPath) as! SlideCardCell)
            
    
            self.CardCell!.Verse.font = UIFont.systemFont(ofSize: (isIpad ? 30:22), weight: .bold)
            self.CardCell!.Book.font = UIFont.systemFont(ofSize: (isIpad ? 22:14))
            
            
//            if indexPath.row < self.imageurlArray.count {
//                self.CardCell!.SliderImage.image = UIImage(named: "S\(BGImage).jpg")
//            } else {
////                self.CardCell!.SliderImage.image = UIImage(named: "holy cross.jpg")
//                self.CardCell!.SliderImage.image = UIImage(named: "S\(BGImage).jpg")
//            }
            self.CardCell!.SliderImage.image = UIImage(named: "S\(BGImage[indexPath.row]).jpg")
            
            self.CardCell!.Verse.text = self.VerseArray[indexPath.row]
            self.CardCell!.Book.text = "\(self.BookArrayTitle):\(indexPath.row+1)"
            
        
            
            var B_Title = "\(BookName)-\(ChaterNumber):\(indexPath.row+1)"
            
            
//            if BookFilter.count > 0 {
////                if BookFilter[0].components(separatedBy: " ").count == 2 {
////                    let SeperateVAlue = BookArrayTitle.components(separatedBy: " ")[2]
////                    B_Title = "\(BooktitleName.text!)-\(SeperateVAlue)"
////
////                } else if BookFilter[0].components(separatedBy: " ").count >= 2 {
////                    let SeperateVAlue = BookArrayTitle.components(separatedBy: "  ")[1]
////                    B_Title = "\(BooktitleName.text!)-\(SeperateVAlue)"
////                }
//            }
             

            
            
            if self.BookFilter.contains(B_Title) {
                let indexOfVerse = self.BookFilter.firstIndex(of: B_Title)
   
                let SplitCellData = CoreDataModel.sharedInstance.seperateByArray(SeperateValue: self.BibleSavedVerses[indexOfVerse!])

                
                
                if SplitCellData[0] != "#000000" {
                    self.CardCell!.SliderShadowVu.layer.borderWidth = (DisableConerRadius ? 0:5)
                    self.CardCell!.SliderShadowVu.layer.borderColor = hexStringToUIColor(hex: SplitCellData[0]).cgColor
                } else {
                    self.CardCell!.SliderShadowVu.layer.borderWidth = 0
                }

            } else {
                self.CardCell!.SliderShadowVu.layer.borderWidth = 0
            }
            
            self.CardCell!.changeImage.addTarget(self, action: #selector(clickIMage), for: .touchUpInside)
            
            self.CardCell!.SliderImageView.layer.masksToBounds = true
            self.CardCell!.SliderImageView.layer.cornerRadius = (DisableConerRadius ? 0:10)
//            self.SelectedPath = indexPath.row
               
            return self.CardCell!
        }
    
        

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.SelectedPath == indexPath.row {
            self.clickIMage()
        }
    }

    
    @objc func clickIMage() {
        self.CardCollectionCell.isScrollEnabled = false
        let indexPaths = NSIndexPath(row: self.SelectedPath, section: 0)
        self.CardCell = self.CardCollectionCell.cellForItem(at: indexPaths as IndexPath)  as? SlideCardCell
        
        if BGImageCount >= 11 {
            BGImageCount = 0
        }
        BGImageCount = BGImageCount+1
        self.CardCell!.SliderImage.image = UIImage(named: "S\(BGImageCount).jpg")
        
        self.CardCollectionCell.isScrollEnabled = true
    }
    

    
    func CloseHighlite() {
        if HighlightStatus == true {
            self.DismissVu()
            HighlightStatus = false
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        self.CloseHighlite()
        
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
        
        
       }
    
    
    
    func HigliteStatus() {
        if HighlightStatus == true {
            HighlightStatus = false
            self.DismissVu()
        }
    }

    
    
    // MARK:- Button Action
    
    @IBAction func ShareAction(_ sender: Any) {
        self.CloseHighlite()
        let indexPaths = NSIndexPath(row: self.SelectedPath, section: 0)
        
        
        let multilineCell = self.CardCollectionCell.cellForItem(at: indexPaths as IndexPath)  as? SlideCardCell
        multilineCell!.SliderShadowVu.layer.borderWidth = 0
        let BorerColors = UIColor(cgColor: multilineCell!.SliderShadowVu.layer.borderColor!)
        self.saveImage = multilineCell!.SliderShadowVu.asImage()
        
        if  BorerColors.toHexString() != "#000000" {
            multilineCell!.SliderShadowVu.layer.borderWidth = 5
        }
        
        let BookName = "\(self.BookArrayTitle.replacingOccurrences(of: "-", with: " ")):\(self.SelectedPath+1)"
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = url.appendingPathComponent("\(BookName).png")
        try! self.saveImage?.pngData()?.write(to: fileURL)
                    
        App_Protocol.delegateReader?.sharedImage(sharedUrl:fileURL,VerseStr:multilineCell!.Verse.text!, Bookname:BookName)
        
    }
    
    
    
 
      
    
    @IBAction func Close(_ sender: Any) {
        DispatchQueue.main.async {
            App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
            App_Protocol.delegateReader?.CloseView()
        }
    }
    
    @IBAction func Next(_ sender: Any) {
        
        let BookArray = Bookname!.components(separatedBy: [":", "-"])
        
    
        self.bookCount = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: BookArray[0])
        
        if Int(BookArray[1])! >= 1 && Int(BookArray[1])! < self.bookCount {
            HigliteStatus()
            self.PreviousVu.isHidden = false
            self.VerseArray = BibleContent.sharedInstance.AudioBibleList(selecterBookName: BookArray[0], selectedId: Int(BookArray[BookArray.count-2])!)
            
            Bookname = String(format: "%@-%i:1",BookArray[0],Int(BookArray[BookArray.count-2])!+1)
            self.Config()
 
        } else {
            self.NextVu.isHidden = true
        }
    }
    
    
    @IBAction func Previous(_ sender: Any) {
        
        let BookArray = Bookname!.components(separatedBy: [":", "-"])

        if Int(BookArray[1])! > 1 {
            HigliteStatus()
            self.NextVu.isHidden = false
            self.VerseArray = BibleContent.sharedInstance.AudioBibleList(selecterBookName: BookArray[0], selectedId: Int(BookArray[BookArray.count-2])!-1)
            Bookname = String(format: "%@-%i:1",BookArray[0],Int(BookArray[BookArray.count-2])!-1)
            self.Config()
        } else {
            self.PreviousVu.isHidden = true
        }
    }
    
    
    @IBAction func HighlightAction(_ sender: Any) {
        self.ChangeHighlightStatus()
    }
    
    @IBAction func CopyAction(_ sender: Any) {
        self.CloseHighlite()
        self.SelectedPath =  (self.SelectedPath >= self.VerseArray.count ?  self.SelectedPath-1:self.SelectedPath)
        
        let copyverse = "\(self.VerseArray[self.SelectedPath])\n\n       \(BookName)-\(ChaterNumber):\(self.SelectedPath+1) \n\n \(APP_LINK)"
        
        UIPasteboard.general.string = copyverse
        self.makeToast("Copied successfully", duration: 2.0, position: .bottom)
         
    }
    
    
    @IBAction func SaveAction(_ sender: Any) {
        self.CloseHighlite()
//        App_Protocol.delegateReader?.SliderCardPreview(Verese: self.VerseArray[self.SelectedPath!], Book: "\(BookArrayTitle):\(self.SelectedPath!+1)")
        
        
        let indexPaths = NSIndexPath(row: self.SelectedPath, section: 0)
        
        DispatchQueue.main.async {
            
            self.DisableConerRadius = true
            
            self.CardCell = self.CardCollectionCell.cellForItem(at: indexPaths as IndexPath)  as? SlideCardCell
            self.saveImage = self.CardCell!.SliderShadowVu.asImage()
//            self.CardCollectionCell.reloadItems(at: [indexPaths as IndexPath])
        
            self.DisableConerRadius = false
//            self.CardCollectionCell.reloadItems(at: [indexPaths as IndexPath])
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                App_Protocol.delegateReader?.SliderCardPreview(Vereseimage: self.saveImage!)
        
                let imageRectsize = AVMakeRect(aspectRatio: self.saveImage!.size, insideRect: UIScreen.main.bounds)
                App_Protocol.delegateReader?.OpenPreview(SavedImage: self.saveImage!, FrameHeight: imageRectsize.height)

            }
            
        }

    

    }
    
    
    
  
    
    
    @IBAction func NoteAction(_ sender: Any) {
        self.ConvertImage()
    }
    
    
    func ConvertImage() {
        
        self.SelectedPath =  (self.SelectedPath >= self.VerseArray.count ?  self.SelectedPath-1:self.SelectedPath)
        
        let dic = ["VersesTitle": "\(self.BookArrayTitle):\(self.SelectedPath+1)", "Verses": self.VerseArray[self.SelectedPath],"verseimage": self.ImageUrlSelected]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PreviewImage"),object: nil, userInfo: dic as [AnyHashable : Any])
        
    }
    
    
    @IBAction func BookMarkAction(_ sender: Any) {
        self.CloseHighlite()
        
        self.SelectedPath =  (self.SelectedPath >= self.VerseArray.count ?  self.SelectedPath-1:self.SelectedPath)
        
        
        var B_Title = "\(BookName)-\(ChaterNumber):\(self.SelectedPath+1)"
        
        let indexPaths = NSIndexPath(row: self.SelectedPath, section: 0)
        
        let multilineCell = self.CardCollectionCell.cellForItem(at: indexPaths as IndexPath)  as? SlideCardCell
        
//        if multilineCell!.SliderBookMarkIcon.isHidden == false {
//            CoreDataModel.sharedInstance.coreDataInsertBookmarked(CDBookSavedInfo, bookVerse:B_Title , Bookmark: "", Verses: self.VerseArray[self.SelectedPath])
//            self.makeToast("Bookmark removed.", duration: 2.0, position: .bottom)
//
//        } else {
//            CoreDataModel.sharedInstance.coreDataInsertBookmarked(CDBookSavedInfo, bookVerse:B_Title , Bookmark: "bookMarked", Verses: self.VerseArray[self.SelectedPath])
//            self.makeToast("Bookmarked successfully", duration: 2.0, position: .bottom)
//        }
        
        self.reloadCoreCollectionData(Index: self.SelectedPath)
    }
    
    
    
    
    @objc func ChangeHighlightStatus() {
        if HighlightStatus == false {
            HighlightStatus = true
            self.SliderNib()
        } else {
            self.DismissVu()
            HighlightStatus = false
        }
    }
    
    
    
    func reloadCoreCollectionData(Index:Int) {
        self.ReloadCoredata()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            let indexPath = NSIndexPath(row: Index, section: 0)
            self.CardCollectionCell.reloadItems(at: [indexPath as IndexPath])
            let cell = self.CardCollectionCell.cellForItem(at: indexPath as IndexPath)  as? SlideCardCell
            cell?.transform = CGAffineTransform.identity
        }
    }
    
    
    func ReloadCoredata() {
        self.BibleSavedVerses.removeAll()
        self.BookFilter.removeAll()
        self.BibleSavedVerses = CoreDataModel.sharedInstance.AudioBibleVerse(entity: CDBookSavedInfo, bookname: self.BookName)
        
        for items in self.BibleSavedVerses {
            let srt = CoreDataModel.sharedInstance.seperateByArrayBook(SeperateValue: items)
            
            self.BookFilter.append(srt)
        }
        
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    func SliderNib() {
        
        self.SelectedPath =  (self.SelectedPath >= self.VerseArray.count ?  self.SelectedPath-1:self.SelectedPath)

        let B_Title = "\(BookName)-\(ChaterNumber):\(self.SelectedPath+1)"
        
        let BookVerse = Bookname?.components(separatedBy: ":")[0]
        
        let indexPath = NSIndexPath(row: self.SelectedPath, section: 0)
        let cell = self.CardCollectionCell.cellForItem(at: indexPath as IndexPath)  as? SlideCardCell

        self.myView = UIView(frame: CGRect(x: 25, y: screenSize.height-(150+StatusbarHeight), width: screenSize.width-50, height: 60))
        self.addSubview(self.myView!)
        self.HighlighterVu = HighlighterView.fromNib(named: "HighlighterView")
        self.HighlighterVu!.frame = self.myView!.bounds
        self.HighlighterVu!.verse = self.VerseArray[self.SelectedPath]
        self.HighlighterVu!.book = B_Title  // "\(BookVerse!):\(self.SelectedPath!+1)" //"\(self.BookArrayTitle):\(self.SelectedPath!+1)"
        if cell!.SliderShadowVu.layer.borderWidth > 1 {
            self.HighlighterVu!.verseColor = UIColor(cgColor: cell!.SliderShadowVu.layer.borderColor!)
        } else  {
            self.HighlighterVu!.verseColor = UIColor.clear
        }
        self.HighlighterVu!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView!.addSubview(self.HighlighterVu!)
    }
    
    
    func DismissVu() {
        self.myView?.removeFromSuperview()
    }
    
}


extension SlideCardView {
    @objc func reloadNotedata() {
        self.reloadCoreCollectionData(Index: self.SelectedPath)
    }
}


