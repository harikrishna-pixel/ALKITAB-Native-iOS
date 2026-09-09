//
//  SaveNotes.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 16/02/21.
//

import UIKit
import Toast_Swift

@available(iOS 13.4, *)
class SaveNotes: UIView, UITextViewDelegate {

    @IBOutlet var Popupframe: UIView!
    @IBOutlet var Popupframetext: UILabel!
    @IBOutlet var PopupframeBook: UILabel!
    @IBOutlet weak var NoteTxtVu: UITextView!
    @IBOutlet weak var SaveBtn: UIButton!
    @IBOutlet weak var NotNowBtn: UIButton!
    
    @IBOutlet weak var FrameWidth: NSLayoutConstraint!
    
    
    var VerseStr:String = ""
    var Bookname:String = ""
    var ChapterNo:String = ""
    var Note:String = ""
    var Color:String = ""
    var isSlideCard:Bool = false
    
    
    override func draw(_ rect: CGRect) {
        
        self.Popupframetext.text = VerseStr
        self.PopupframeBook.text = "\(Bookname) \(ChapterNo)"
        if Note == "" {
            self.NoteTxtVu.text = "Enter Notes"
            self.NoteTxtVu.textColor = UIColor.lightGray
        } else {
            self.NoteTxtVu.text = Note
            self.NoteTxtVu.textColor = UIColor.darkGray
            self.NotNowBtn.setTitle("Delete", for: .normal)
            self.NotNowBtn.setTitleColor(UIColor.red, for: .normal)
            self.SaveBtn.setTitle("Update", for: .normal)
            
        }
        self.SaveBtn.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor")
        self.NoteTxtVu.delegate = self
        self.Popupframe.layer.cornerRadius = 30
        
        FrameWidth.constant = (isIpad ? 440:330)
        
        let fontName = UserDefaults.standard.string(forKey: "FontName") ?? "Euphemia UCAS"
        let noteFont = UIFont(name: fontName, size: 15) ?? UIFont.systemFont(ofSize: 15)
        self.PopupframeBook.font = noteFont
        self.Popupframetext.font = noteFont
        
        
    }
    
    
    @IBAction func NotNow(_ sender: Any) {

        if self.NotNowBtn.titleLabel?.text ==  "Delete" {
            CoreDataModel.sharedInstance.coreDataInsertNote(CDBookSavedInfo, bookVerse: "\(self.Bookname)-\(self.ChapterNo)", notes: "", Verses: self.VerseStr)
            App_Protocol.DelegateVersesMenuPopup?.ChangeNote(Notetxt: "", true)
            App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
        }
            
        if isSlideCard {
            App_Protocol.DelegateSlideCard?.NotesSavedStatus(Status:true)
            App_Protocol.DelegateSlideCard?.CloseVc()
        } else {
            App_Protocol.delegateReader?.CloseView()
        }
    }
    
    @IBAction func CloseView(_ sender: Any) {
        if isSlideCard {
            App_Protocol.DelegateSlideCard?.CloseVc()
        } else {
            App_Protocol.delegateReader?.CloseView()
        }
    }
    
    
    
    @IBAction func Save(_ sender: Any) {
        
        if self.NoteTxtVu.text == "Enter Notes" || self.NoteTxtVu.text == "" {
            self.makeToast("Enter notes to save", duration: 2.0, position: .bottom)
        } else {
                    
            App_Protocol.DelegateVersesMenuPopup?.ChangeNote(Notetxt: self.NoteTxtVu.text ?? "", false)
            
            // Check if this is an update or new save based on button title
            let isUpdate = (self.SaveBtn.titleLabel?.text == "Update")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                CoreDataModel.sharedInstance.coreDataInsertNote(CDBookSavedInfo, bookVerse: "\(self.Bookname)-\(self.ChapterNo)", notes: self.NoteTxtVu.text ?? "", Verses: self.VerseStr)
                
                // Toast on a live view before dismissing notes (avoids toast-after-remove crash/stack).
                let message = isUpdate ? "Update notes successfully" : "Notes Saved Successfully"
                UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(message, duration: 2.0, position: .bottom)
                
                if self.isSlideCard {
                    App_Protocol.DelegateSlideCard?.CloseVc()
                    App_Protocol.DelegateSlideCard?.NotesSavedStatus(Status:false)
                } else {
                    App_Protocol.delegateReader?.CloseView()
                }
                
                App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
                
//                App_Protocol.delegateReader?.AlertFrame(AlertNote: "Note Saved!!",Vers:self.VerseStr,Title:"\(self.Bookname)-\(self.ChapterNo)")
            }
        }
        RateUsCall.shared.ClickCount()
    }
   
    
    @IBAction func Delete(_ sender: Any) {
        let bookVerse = Bookname.replacingOccurrences(of: " ", with: "-")
        self.NoteTxtVu.text = ""
        CoreDataModel.sharedInstance.coreDataInsertNote(CDBookSavedInfo, bookVerse: bookVerse, notes: self.NoteTxtVu.text, Verses: self.VerseStr)
        self.makeToast("Deleted successfully", duration: 2.0, position: .bottom)
        NotificationCenter.default.post(name: Notification.Name("Reloaddata"), object: nil)
    }
    

    
    
    //MARK: - TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Notes"
            textView.textColor = UIColor.lightGray
        }
    }
}
