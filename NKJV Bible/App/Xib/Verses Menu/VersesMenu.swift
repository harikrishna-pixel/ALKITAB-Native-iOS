//
//  VersesMenu.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 13/12/22.
//

import UIKit
import SwiftUI

class VersesMenu: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, VersesMenuPopup {

    static let shared = VersesMenu()
    
    
    @IBOutlet var MainView: UIView!
    
    @IBOutlet weak var ColorCC: UICollectionView!
    @IBOutlet var BookNameTxt: UILabel!
    
    @IBOutlet weak var Bookmark: UIView!
    @IBOutlet weak var BookmarkTxt:UILabel!
    @IBOutlet weak var BookmarkImg: UIImageView!
    

    @IBOutlet weak var Note: UIView!
    @IBOutlet weak var NoteTxt:UILabel!
    @IBOutlet weak var NoteImg: UIImageView!
    

    @IBOutlet weak var Underline: UIView!
    @IBOutlet weak var UnderlineTxt: UILabel!
    @IBOutlet weak var UnderlineImg: UIImageView!
    
    
    @IBOutlet weak var Image: UIView!
    @IBOutlet weak var ImageTxt: UILabel!
    @IBOutlet weak var ImageImg: UIImageView!
    
    
    @IBOutlet weak var Refresh: UIView!
    @IBOutlet weak var RefreshTxt: UILabel!
    @IBOutlet weak var RefreshImg: UIImageView!
    
    @IBOutlet weak var Copy: UIView!
    @IBOutlet weak var CopyTxt: UILabel!
    @IBOutlet weak var CopyImg: UIImageView!
    
    @IBOutlet weak var Share: UIView!
    @IBOutlet weak var ShareTxt: UILabel!
    @IBOutlet weak var ShareImg: UIImageView!
    
    @IBOutlet weak var ExplainView: UIView!
    @IBOutlet weak var ExplainTxt: UILabel!
    
    @IBOutlet weak var ExplainImg: UIImageView!
    
    private var getExplanationButton: UIButton?
    private var getExplanationAdded = false
    
    private static let getExplanationTopInset: CGFloat = 12
    private static let getExplanationHorizontalInset: CGFloat = 20
    private static let getExplanationButtonHeight: CGFloat = 44
    private static let getExplanationBookNameGap: CGFloat = 12
    private static var getExplanationExtraHeight: CGFloat {
        getExplanationTopInset + getExplanationButtonHeight + getExplanationBookNameGap
    }
    
    var SelectedColor:Int = -1
    

    @IBOutlet weak var FrameHeight: NSLayoutConstraint!
    
    
    var VersePosition:Int = -1
    var BookName:String = ""
    var Pageindex:Int = -1
    var BookVerse:Array<String>?
    var Notetxt:String = ""
    var BookmarkStatus:String = ""
    var ColorCode:String = ""
    var SelectedColorCode:String = ""
    var UnderlineStatus:String = ""
    
    
    var Themecolor:UIColor?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGetExplanationButton()
        ColorCC.delegate = self
        ColorCC.dataSource = self
        ColorCC.register(UINib(nibName: "ColorCell", bundle: nil), forCellWithReuseIdentifier: "ColorCell")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        MainView.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        hideVerseMenuCloseIcon()
        if let getExplanationButton {
            MainView.bringSubviewToFront(getExplanationButton)
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        SelectedColorCode = ColorCode
        App_Protocol.DelegateVersesMenuPopup = self
        
        
        self.BookNameTxt.text =  "\(BookName)-\(Pageindex-1):\(VersePosition)"
        
        FrameHeight.constant = (isIpad ? 380 : 360) + Self.getExplanationExtraHeight
        getExplanationButton?.backgroundColor = Themecolor
        
        
        
        
        if BookmarkStatus == "bookMarked" {
            self.BookmarkImg.image = UIImage(named: "FBookmark")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.BookmarkImg, colorVu: self.Themecolor!)
        } else {
            self.BookmarkImg.image = UIImage(named: "UBookmark")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.BookmarkImg, colorVu: UIColor.gray)
        }
        
        
        
        if UnderlineStatus == "false" || UnderlineStatus == "" {
            self.UnderlineImg.image = UIImage(named: "UUnderline")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.UnderlineImg, colorVu: UIColor.gray)
        } else {
            self.UnderlineImg.image = UIImage(named: "FUnderline")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.UnderlineImg, colorVu: self.Themecolor!)
        }
        
        
        
        if Notetxt.isEmpty {
            self.NoteImg.image = UIImage(named: "UNotes")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.NoteImg, colorVu: UIColor.gray)
        } else {
            self.NoteImg.image = UIImage(named: "FNotes")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.NoteImg, colorVu: self.Themecolor!)
        }
        

        ImageTint.sharedInstance.imageTintcolorMethod(img: self.RefreshImg, colorVu: UIColor.gray)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.CopyImg, colorVu: UIColor.gray)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.ShareImg, colorVu: UIColor.gray)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.ImageImg, colorVu: UIColor.gray)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.ExplainImg, colorVu: UIColor.gray)
        
        
        self.Underline.ViewBorder(color: UIColor.gray)
        self.Refresh.ViewBorder(color: UIColor.gray)
        self.Copy.ViewBorder(color: UIColor.gray)
        self.Share.ViewBorder(color: UIColor.gray)
        self.Image.ViewBorder(color: UIColor.gray)
        self.Note.ViewBorder(color: UIColor.gray)
        self.Bookmark.ViewBorder(color: UIColor.gray)
        self.ExplainView.ViewBorder(color: UIColor.gray)
        
        
                
        self.BookmarkTxt.textColor = self.Themecolor!
        self.NoteTxt.textColor = self.Themecolor!
        self.CopyTxt.textColor = self.Themecolor!
        self.ShareTxt.textColor = self.Themecolor!
        self.RefreshTxt.textColor = self.Themecolor!
        self.UnderlineTxt.textColor = self.Themecolor!
        self.ImageTxt.textColor = self.Themecolor!
        self.ExplainTxt.textColor = self.Themecolor!
        self.ExplainTxt.text = "Explain (ad)"
        // Ensure single line and prevent truncation - font will scale down if needed
        self.ExplainTxt.numberOfLines = 1
        self.ExplainTxt.adjustsFontSizeToFitWidth = true
        self.ExplainTxt.minimumScaleFactor = 0.6
        self.ExplainTxt.lineBreakMode = .byClipping
    }

    private func setupGetExplanationButton() {
        guard !getExplanationAdded else { return }
        getExplanationAdded = true

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get Explanation", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(GetExplanationAction(_:)), for: .touchUpInside)
        MainView.addSubview(button)
        getExplanationButton = button
        MainView.bringSubviewToFront(button)
        MainView.bringSubviewToFront(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: MainView.topAnchor, constant: Self.getExplanationTopInset),
            button.leadingAnchor.constraint(equalTo: MainView.leadingAnchor, constant: Self.getExplanationHorizontalInset),
            button.trailingAnchor.constraint(equalTo: MainView.trailingAnchor, constant: -Self.getExplanationHorizontalInset),
            button.heightAnchor.constraint(equalToConstant: Self.getExplanationButtonHeight)
        ])

        hideVerseMenuCloseIcon()
        repositionBookNameBelowGetExplanationButton(button, gap: Self.getExplanationBookNameGap)
    }

    private func hideVerseMenuCloseIcon() {
        for subview in MainView.subviews {
            if let imageView = subview as? UIImageView {
                let isCloseSize = imageView.constraints.contains {
                    ($0.firstAttribute == .width || $0.firstAttribute == .height) && $0.constant == 12
                }
                if isCloseSize {
                    imageView.isHidden = true
                }
            }
            if let button = subview as? UIButton,
               (button.actions(forTarget: self, forControlEvent: .touchUpInside) ?? []).contains("CloseAction:") {
                button.isHidden = true
                button.isUserInteractionEnabled = false
            }
        }
    }

    private func repositionBookNameBelowGetExplanationButton(_ button: UIView, gap: CGFloat) {
        MainView.constraints.filter { constraint in
            let bookNameIsTopItem = constraint.firstItem as? UILabel == BookNameTxt && constraint.firstAttribute == .top
            let bookNameIsTopSecondItem = constraint.secondItem as? UILabel == BookNameTxt && constraint.secondAttribute == .top
            let involvesMainView = constraint.firstItem as? UIView == MainView || constraint.secondItem as? UIView == MainView
            return (bookNameIsTopItem || bookNameIsTopSecondItem) && involvesMainView
        }.forEach { $0.isActive = false }

        BookNameTxt.topAnchor.constraint(equalTo: button.bottomAnchor, constant: gap).isActive = true
    }

    
    
    func ChangeNote(Notetxt:String,_ Status:Bool) {
        self.Notetxt = Notetxt
        
        self.NoteImg.image = Notetxt.isEmpty ? UIImage(named: "UNotes"):UIImage(named: "FNotes")
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.NoteImg, colorVu: Notetxt.isEmpty ? UIColor.gray:self.Themecolor!)
        
            self.makeToast("Notes \(Status ? "Deleted":"Saved") Successfully!", duration: 2.0, position: .center)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (isIpad ? 85:60), height: (isIpad ? 85:60))
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HighlightColors.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = self.ColorCC.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
            
            cell.ColorView.backgroundColor = hexColorConvert.shared.hexStringToUIColor(hex: HighlightColors[indexPath.row])
            cell.layer.cornerRadius = 4
        
            cell.Tick.isHidden = (self.SelectedColor == indexPath.row ? false : true)
            cell.Tick.isHidden = (self.SelectedColorCode == "#\(HighlightColors[indexPath.row])" ? false:true )
        
        
        cell.TicKiconwidth.constant = isIpad ? 22:14
        cell.TicKiconheight.constant = isIpad ? 22:14
        
        
            return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "OfferClick")+1, forKey: "OfferClick")
        
//        if self.SelectedColor == indexPath.row {
//            self.SelectedColor = -1
//        } else {
            self.SelectedColor = indexPath.row
            
            if self.SelectedColorCode == "#\(HighlightColors[indexPath.row])" {
                self.SelectedColorCode = ""
                self.SelectedColor = -1
                CoreDataModel.sharedInstance.coreDataInsert(CDBookSavedInfo, bookVerse:"\(BookName)-\(Pageindex-1):\(VersePosition)" , color: "#000000", Verses: self.BookVerse![VersePosition-1])
                // BUG FIX 2: OLD CODE - No toast message was shown when highlight was removed (caused confusion)
                // (No toast message here before)
                // BUG FIX 2: NEW CODE - Added toast message to confirm highlight removal
                UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("Highlight Removed Successfully!!", duration: 2.0, position: .center)
            } else {
                self.SelectedColorCode = "#\(HighlightColors[indexPath.row])"
                
                CoreDataModel.sharedInstance.coreDataInsert(CDBookSavedInfo, bookVerse:"\(BookName)-\(Pageindex-1):\(VersePosition)" , color: "#\(HighlightColors[self.SelectedColor])", Verses: self.BookVerse![VersePosition-1])
                // BUG FIX 2: OLD CODE - No toast message was shown when highlight was saved (caused confusion)
                // (No toast message here before)
                // BUG FIX 2: NEW CODE - Added toast message to confirm highlight save
                UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("Highlight Saved Successfully!!", duration: 2.0, position: .center)
            }
            
//        }
        self.ColorCC.reloadData()
        
        App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:Pageindex-1)
    }
    
    
    
    @IBAction func CloseAction(_ sender: Any) {
        App_Protocol.delegateReader?.CloseMenu()
    }
    
    @IBAction func CloseViewAction(_ sender: Any) {
        App_Protocol.delegateReader?.CloseMenu()
    }
    
    
    @IBAction func NoteAction(_ sender: Any) {
        
        App_Protocol.delegateReader?.NoteNib(VersePosition: VersePosition, BookName: BookName, Pageindex: Pageindex, BookVerse: BookVerse!, note:Notetxt)
        App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "OfferClick")+1, forKey: "OfferClick")
        
    }
    
    
    @IBAction func BookmarkAction(_ sender: Any) {
                
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "OfferClick")+1, forKey: "OfferClick")
        
        if BookmarkStatus == "bookMarked" {
            CoreDataModel.sharedInstance.coreDataInsertBookmarked(CDBookSavedInfo, bookVerse:"\(BookName)-\(Pageindex-1):\(VersePosition)" , Bookmark: "", Verses: self.BookVerse![VersePosition-1])
            
            
            
            UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("Bookmark Removed Successfully!!", duration: 2.0, position: .center)
            
            
//            App_Protocol.delegateReader?.AlertFrame(AlertNote: "Bookmark Removed Successfully!!",Vers:self.BookVerse![VersePosition-1],Title:"\(BookName)-\(Pageindex-1):\(VersePosition)")
            
            BookmarkStatus = ""
            self.BookmarkImg.image = UIImage(named: "UBookmark")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.BookmarkImg, colorVu: UIColor.gray)
            
        } else {
            
            BookmarkStatus = "bookMarked"
            CoreDataModel.sharedInstance.coreDataInsertBookmarked(CDBookSavedInfo, bookVerse:"\(BookName)-\(Pageindex-1):\(VersePosition)" , Bookmark: "bookMarked", Verses: self.BookVerse![VersePosition-1])

            
            UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("Bookmark saved Successfully!!", duration: 2.0, position: .center)
            
//            App_Protocol.delegateReader?.AlertFrame(AlertNote: "Bookmark saved Successfully!!",Vers:self.BookVerse![VersePosition-1],Title:"\(BookName)-\(Pageindex-1):\(VersePosition)")

            self.BookmarkImg.image = UIImage(named: "FBookmark")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.BookmarkImg, colorVu: self.Themecolor!)
        }
        
        App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
        
    }
    
    
    
    @IBAction func UnderlineAction(_ sender: Any) {
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "OfferClick")+1, forKey: "OfferClick")
        
        CoreDataModel.sharedInstance.coreDataInsertUnderLine(CDBookSavedInfo, bookVerse: "\(BookName)-\(Pageindex-1):\(VersePosition)", Bookmark: "", Verses: self.BookVerse![VersePosition-1], Underlinestatus: (UnderlineStatus == "true" ? false:true))
                
        UIApplication.shared.keyWindow?.rootViewController!.view.makeToast(UnderlineStatus == "true" ?  "Underline Removed Successfully!!" : "Verse Underlined Successfully!!", duration: 2.0, position: .center)
        
//        App_Protocol.delegateReader?.AlertFrame(AlertNote: UnderlineStatus == "true" ?  "Underline Removed Successfully!!" : "Verse Underlined Successfully!!" , Vers:self.BookVerse![VersePosition-1],Title:"\(BookName)-\(Pageindex-1):\(VersePosition)")
        
        if UnderlineStatus == "false" || UnderlineStatus == "" {
            UnderlineStatus = "true"
            self.UnderlineImg.image = UIImage(named: "FUnderline")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.UnderlineImg, colorVu: self.Themecolor!)
        } else {
            UnderlineStatus = "false"
            self.UnderlineImg.image = UIImage(named: "UUnderline")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.UnderlineImg, colorVu: UIColor.gray)
        }
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.UnderlineImg, colorVu: self.Themecolor!)
        App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
    }
    
    
    @IBAction func CopyAction(_ sender: Any) {
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "OfferClick")+1, forKey: "OfferClick")
        
        UIPasteboard.general.string = "\(self.BookVerse![VersePosition-1]) \n\n      \(BookName)-\(Pageindex-1):\(VersePosition) \n\n \(APP_LINK)"

        UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("Copied Successfully!!", duration: 2.0, position: .center)
        
//        App_Protocol.delegateReader?.AlertFrame(AlertNote: "Copied Successfully!!",Vers:self.BookVerse![VersePosition-1],Title:"\(BookName)-\(Pageindex-1):\(VersePosition)")
    }
    
    
    @IBAction func RefreshAction(_ sender: Any) {
        
        CoreDataModel.sharedInstance.coreDataRemoveAllData(CDBookSavedInfo, bookVerse: "\(BookName)-\(Pageindex-1):\(VersePosition)")
        App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
        
//        App_Protocol.delegateReader?.AlertFrame(AlertNote: "Verse Reset Successfully!!",Vers:self.BookVerse![VersePosition-1],Title:"\(BookName)-\(Pageindex-1):\(VersePosition)")
        
        UIApplication.shared.keyWindow?.rootViewController!.view.makeToast("Verse Reset Successfully!!", duration: 2.0, position: .center)
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.BookmarkImg.image = UIImage(named: "UBookmark")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.BookmarkImg, colorVu: UIColor.gray)

            self.UnderlineImg.image = UIImage(named: "UUnderline")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.UnderlineImg, colorVu: UIColor.gray)

            self.NoteImg.image = UIImage(named: "UNotes")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.NoteImg, colorVu: UIColor.gray)
        }
        
        self.SelectedColorCode = ""
        self.ColorCC.reloadData()
        
    }
    
    @IBAction func WallpaperAction(_ sender: Any) {

        App_Protocol.delegateReader?.WallpaperNib(VersePosition: VersePosition, BookName: "\(BookName)-\(Pageindex-1):\(VersePosition)", Pageindex: Pageindex, BookVerse: self.BookVerse!)
        
    }
    
    
    @IBAction func ShareAction(_ sender: Any) {
        App_Protocol.delegateReader?.shared(VerseStr: self.BookVerse![VersePosition-1], Bookname: "\(BookName)-\(Pageindex-1):\(VersePosition)")
    }
    
    @IBAction func ExplainAction(_ sender: Any) {
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "OfferClick")+1, forKey: "OfferClick")
        App_Protocol.delegateReader?.ExplanationNib(
            VersePosition: VersePosition,
            BookName: BookName,
            Pageindex: Pageindex,
            BookVerse: BookVerse!
        )
    }

    @IBAction func GetExplanationAction(_ sender: Any) {
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "OfferClick")+1, forKey: "OfferClick")
        App_Protocol.delegateReader?.ExplanationNib(
            VersePosition: VersePosition,
            BookName: BookName,
            Pageindex: Pageindex,
            BookVerse: BookVerse!
        )
    }
    
    
    
}
