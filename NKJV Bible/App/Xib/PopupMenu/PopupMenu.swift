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
     private var explanationIsChapterSummary = false
     private var explanationTextHeightConstraint: NSLayoutConstraint?
     private var summaryScrollView: UIScrollView?
     private var summaryScrollLabel: UILabel?
     private var explanationTextColor: UIColor?
    
    
    
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
            let storedVerse = parts.count > 3 ? parts[3] : ""
            let storedExplanation = parts.count > 2 ? parts[2] : ""
            explanationStoredText = storedExplanation
            explanationIsChapterSummary = SearchCollectionMainView.isNumberedChapterDump(storedVerse)
            let shown = explanationIsChapterSummary
                ? SearchCollectionMainView.librarySummaryText(verse: storedVerse, explanation: storedExplanation)
                : storedVerse
            self.Popupframetext.text = " \(shown)"
            self.PopupframeBook.text = parts.first?.replacingOccurrences(of: "-", with: " ") ?? ""
            self.FrameHeightConstrain.constant = CGFloat(187 + Popupframetext.maxNumberOfLinesHome)
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
        if TagSelection == "Explanations" {
            fitExplanationFullView()
        }
        
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
        self.makeToast("Copied successfully", duration: 2.0, position: .top)
        if TagSelection == "Explanations" {
            if explanationIsChapterSummary {
                UIPasteboard.general.string = "\(self.Popupframetext.text!)\n\n\(self.PopupframeBook.text!)\n\n\(APP_LINK)"
            } else {
                UIPasteboard.general.string = "\(explanationStoredText)\n\n\(self.Popupframetext.text!)\n\n\(self.PopupframeBook.text!)\n\n\(APP_LINK)"
            }
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
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Bookmark removed", duration: 2.0, position: .top)

        case "Highlites":
            
            CoreDataModel.sharedInstance.coreDataDeleteColor(CDBookSavedInfo, bookVerse: self.PopupframeBook.text!, color: "#000000")
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Highlites removed", duration: 2.0, position: .top)
            
        case "Underline":
            CoreDataModel.sharedInstance.coreDataDeleteUnderline(CDBookSavedInfo, bookVerse: self.PopupframeBook.text!)
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Underline removed", duration: 2.0, position: .top)
            

        case "Notes":
            CoreDataModel.sharedInstance.coreDataDeleteNote(CDBookSavedInfo, bookVerse:self.PopupframeBook.text!, notes: "")
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Notes removed", duration: 2.0, position: .top)

        case "Explanations":
            let parts = getString.components(separatedBy: ExplanationRecordDelimiter)
            let bookVerse = parts.first ?? ""
            let bibleVersion = parts.count > 1 ? parts[1] : APPNAME
            CoreDataModel.sharedInstance.deleteVerseExplanation(bookVerse: bookVerse, bibleVersion: bibleVersion)
            (UIApplication.shared.keyWindow?.rootViewController)!.view.makeToast("Explanation removed", duration: 2.0, position: .top)

        default: break

        }
        
        
        App_Protocol.delegateReader?.CloseView()
        App_Protocol.delegateMyLibrary?.ReloadAllData()
    }

    /// Long saved summaries used to grow the sheet above the screen, so the start of the text was cut off.
    private func fitExplanationFullView() {
        let width = max((bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width) - 44, 280)
        let font = Popupframetext.font ?? UIFont.systemFont(ofSize: 18)
        let text = Popupframetext.text ?? ""
        let textHeight = ceil((text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        ).height)
        let screenHeight = bounds.height > 0 ? bounds.height : UIScreen.main.bounds.height
        let chrome: CGFloat = 187
        let maxSheet = screenHeight - 24
        let needed = chrome + textHeight

        if explanationTextColor == nil {
            explanationTextColor = Popupframetext.textColor ?? .black
        }

        if needed <= maxSheet {
            FrameHeightConstrain.constant = needed
            explanationTextHeightConstraint?.isActive = false
            summaryScrollView?.isHidden = true
            Popupframetext.textColor = explanationTextColor
            return
        }

        let maxTextHeight = maxSheet - chrome
        FrameHeightConstrain.constant = maxSheet
        Popupframetext.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        if explanationTextHeightConstraint == nil {
            let height = Popupframetext.heightAnchor.constraint(equalToConstant: maxTextHeight)
            height.priority = .required
            height.isActive = true
            explanationTextHeightConstraint = height
        }
        explanationTextHeightConstraint?.constant = maxTextHeight
        explanationTextHeightConstraint?.isActive = true
        installSummaryScroll(text: text, font: font)
    }

    private func installSummaryScroll(text: String, font: UIFont) {
        let visibleColor = explanationTextColor ?? .black
        let scroll: UIScrollView
        let label: UILabel
        if let summaryScrollView = summaryScrollView, let summaryScrollLabel = summaryScrollLabel {
            scroll = summaryScrollView
            label = summaryScrollLabel
        } else {
            let createdScroll = UIScrollView()
            createdScroll.translatesAutoresizingMaskIntoConstraints = false
            createdScroll.backgroundColor = .clear
            createdScroll.alwaysBounceVertical = true
            createdScroll.showsVerticalScrollIndicator = true
            Popupframetext.superview?.addSubview(createdScroll)
            NSLayoutConstraint.activate([
                createdScroll.topAnchor.constraint(equalTo: Popupframetext.topAnchor),
                createdScroll.leadingAnchor.constraint(equalTo: Popupframetext.leadingAnchor),
                createdScroll.trailingAnchor.constraint(equalTo: Popupframetext.trailingAnchor),
                createdScroll.bottomAnchor.constraint(equalTo: Popupframetext.bottomAnchor)
            ])
            let createdLabel = UILabel()
            createdLabel.translatesAutoresizingMaskIntoConstraints = false
            createdLabel.numberOfLines = 0
            createdScroll.addSubview(createdLabel)
            NSLayoutConstraint.activate([
                createdLabel.topAnchor.constraint(equalTo: createdScroll.contentLayoutGuide.topAnchor),
                createdLabel.leadingAnchor.constraint(equalTo: createdScroll.contentLayoutGuide.leadingAnchor),
                createdLabel.trailingAnchor.constraint(equalTo: createdScroll.contentLayoutGuide.trailingAnchor),
                createdLabel.bottomAnchor.constraint(equalTo: createdScroll.contentLayoutGuide.bottomAnchor),
                createdLabel.widthAnchor.constraint(equalTo: createdScroll.frameLayoutGuide.widthAnchor)
            ])
            summaryScrollView = createdScroll
            summaryScrollLabel = createdLabel
            scroll = createdScroll
            label = createdLabel
        }
        scroll.isHidden = false
        label.font = font
        label.textColor = visibleColor
        label.text = text
        Popupframetext.textColor = .clear
    }
    
    
    
}
