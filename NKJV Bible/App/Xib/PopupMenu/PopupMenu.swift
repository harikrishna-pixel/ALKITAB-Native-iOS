//
//  PopupMenu.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 15/02/21.
//

import UIKit

class PopupMenu: UIView {
 
    
    @IBOutlet var Popupframe: UIView!
    @IBOutlet var Popupframetext: UILabel!
    @IBOutlet var PopupframeBook: UILabel!
    @IBOutlet var DeleteVu: UIView!
    
    
    @IBOutlet var Copy: UIView!
    @IBOutlet var CopyTxt:UILabel!
    @IBOutlet var CopyImg: UIImageView!
    
    
    @IBOutlet var Share: UIView!
    @IBOutlet var ShareTxt: UILabel!
    @IBOutlet var ShareImg: UIImageView!
    
    
    @IBOutlet var Read: UIView!
    @IBOutlet var ReadTxt: UILabel!
    @IBOutlet var ReadImg: UIImageView!
    
    
    @IBOutlet var Delete: UIView!
    @IBOutlet var DeleteTxt: UILabel!
    @IBOutlet var DeleteImg: UIImageView!
     
    
    
    @IBOutlet weak var FrameHeightConstrain: NSLayoutConstraint!
    
    
//    @IBOutlet weak var WLeftConstrain: NSLayoutConstraint!
//    @IBOutlet weak var WRightConstrain: NSLayoutConstraint!
    
    
     var getString: String!
     var VCSelection: String!
     var TagSelection: String!
     var explanationStoredText: String = ""
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func draw(_ rect: CGRect) {
        self.DeleteVu.isHidden = true
        let seperateArray = getString.components(separatedBy: "_")
        let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        
        self.FrameHeightConstrain.constant = CGFloat(187 + Popupframetext.maxNumberOfLinesHome)
        
        if VCSelection == "SearchViewController" {
            self.Popupframetext.text = " \(seperateArray[0])"
            self.PopupframeBook.text = seperateArray[1].replacingOccurrences(of: "-", with: ":")
        } else if VCSelection == "DailyVerses" {
            self.Popupframetext.text = " \(seperateArray[2])"
            self.PopupframeBook.text = seperateArray[0]
        } else if TagSelection == "Explanations" {
            self.DeleteVu.isHidden = false
            let parts = getString.components(separatedBy: ExplanationRecordDelimiter)
            explanationStoredText = parts.count > 2 ? parts[2] : ""
            self.Popupframetext.text = " \(parts.count > 3 ? parts[3] : "")"
            self.PopupframeBook.text = parts.first?.replacingOccurrences(of: "-", with: " ") ?? ""
        } else {
            self.DeleteVu.isHidden = false
            self.Popupframetext.text = " \(seperateArray[3])"
            self.PopupframeBook.text = seperateArray[0].replacingOccurrences(of: "-", with: " ")
        }
        
        
        
//        self.PopupframeBook.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: 15)
//        self.Popupframetext.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: 15)
        
        
        if Themecolor == BGNightMode {
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.CopyImg!, colorVu: .black)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.ShareImg!, colorVu: .black)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.ReadImg!, colorVu: .black)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.DeleteImg!, colorVu: .black)
        } else {
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.CopyImg!, colorVu: Themecolor)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.ShareImg!, colorVu: Themecolor)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.ReadImg!, colorVu: Themecolor)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.DeleteImg!, colorVu: Themecolor)
        }
        
        
        self.Copy.ViewBorder(color: Themecolor)
        self.Share.ViewBorder(color: Themecolor)
        self.Read.ViewBorder(color: Themecolor)
        self.Delete.ViewBorder(color: Themecolor)
        

        self.CopyTxt.textColor = Themecolor
        self.ShareTxt.textColor = Themecolor
        self.ReadTxt.textColor = Themecolor
        self.DeleteTxt.textColor = Themecolor
        
        
        
        self.Popupframetext.text = self.Popupframetext.text!.trimmingCharacters(in: .whitespaces)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
//            self.Popupframe.layer.cornerRadius = 30
            self.Popupframe.roundCorners(corners: [.topLeft, .topRight], radius: 30)
          }
    }
    

    
    @IBAction func Close(_ sender: Any) {
       if VCSelection == "SearchViewController" {
            App_Protocol.delegateSearch?.CloseView()
        } else if VCSelection == "DailyVerses" {
            App_Protocol.delegateDailyVerse?.CloseView(ReadEnable: false)
         } else {
          App_Protocol.delegateReader?.CloseView()
       }

    }
    
 
    
    
    
    
    @IBAction func CloseAction(_ sender: Any) {
         if VCSelection == "SearchViewController" {
            App_Protocol.delegateSearch?.CloseView()
         } else if VCSelection == "DailyVerses" {
             App_Protocol.delegateDailyVerse?.CloseView(ReadEnable: false)
         } else {
            App_Protocol.delegateReader?.CloseView()
        }
    }
    
    
    @IBAction func ReadVerse(_ sender: Any) {
        
        UserDefaults.standard.set(self.PopupframeBook.text, forKey: "readdata")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
            App_Protocol.delegateReaderSource?.navigateToSelectedVerse()
        }
        
         if VCSelection == "SearchViewController" {
            App_Protocol.delegateSearch?.navigateMainClass()
         } else if VCSelection == "DailyVerses" {
             App_Protocol.delegateDailyVerse?.CloseView(ReadEnable: true)
         } else {
             App_Protocol.delegateReader?.CloseView()
         }
    }
    
    
    
    @IBAction func copYText(_ sender: Any) {
        self.makeToast("Copied successfully", duration: 2.0, position: .center)
        if TagSelection == "Explanations" {
            UIPasteboard.general.string = "\(explanationStoredText)\n\n\(self.Popupframetext.text!)\n\n\(self.PopupframeBook.text!)\n\n\(APP_LINK)"
        } else {
            UIPasteboard.general.string = "\(self.Popupframetext.text!)\n\n\(self.PopupframeBook.text!)\n\n\(APP_LINK)"
        }
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
              App_Protocol.delegateMyLibrary?.CloseView()
        }
    }
    
    
    @IBAction func ShareVerse(_ sender: Any) {
        App_Protocol.delegateReader?.shared(VerseStr: self.Popupframetext.text!, Bookname: self.PopupframeBook.text!)
    }
    
    
    @IBAction func DeleteVerse(_ sender: Any) {         
        
        if TagSelection != "Explanations" {
            self.PopupframeBook.text! = getString.components(separatedBy: "_")[0]
        }
        
        
        switch self.TagSelection {
        case "BookMark":

            CoreDataModel.sharedInstance.coreDataDeleteBookMark(CDBookSavedInfo, bookVerse: self.PopupframeBook.text!, Bookmark: "")
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Bookmark removed", duration: 2.0, position: .center)

        case "Highlites":
            
            CoreDataModel.sharedInstance.coreDataDeleteColor(CDBookSavedInfo, bookVerse: self.PopupframeBook.text!, color: "#000000")
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Highlites removed", duration: 2.0, position: .center)
            
        case "Underline":
            CoreDataModel.sharedInstance.coreDataDeleteUnderline(CDBookSavedInfo, bookVerse: self.PopupframeBook.text!)
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Underline removed", duration: 2.0, position: .center)
            

        case "Notes":
            CoreDataModel.sharedInstance.coreDataDeleteNote(CDBookSavedInfo, bookVerse:self.PopupframeBook.text!, notes: "")
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Notes removed", duration: 2.0, position: .center)

        case "Explanations":
            let parts = getString.components(separatedBy: ExplanationRecordDelimiter)
            let bookVerse = parts.first ?? ""
            let bibleVersion = parts.count > 1 ? parts[1] : APPNAME
            CoreDataModel.sharedInstance.deleteVerseExplanation(bookVerse: bookVerse, bibleVersion: bibleVersion)
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Explanation removed", duration: 2.0, position: .center)

        default: break

        }
        
        
        App_Protocol.delegateReader?.CloseView()
        App_Protocol.delegateMyLibrary?.ReloadAllData()
    }
    
    
    
    
}
