//
//  HighlighterView.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 01/03/21.
//

import UIKit

@available(iOS 13.0, *)
class HighlighterView: UIView {

    @IBOutlet var ColorFrame: UIView!
    
    @IBOutlet weak var RedImg: UIImageView!
    @IBOutlet weak var pinkImg: UIImageView!
    @IBOutlet weak var BlueImg: UIImageView!
    @IBOutlet weak var SkyBlueImg: UIImageView!
    @IBOutlet weak var GreenImg: UIImageView!
    @IBOutlet weak var BrownImg: UIImageView!
    @IBOutlet weak var OrangeImg: UIImageView!
    @IBOutlet weak var ColorLoadFrame: UIView!
    
    
    
    var verse:String = ""
    var book:String = ""
    var verseColor:UIColor?
    var HighlightColor:String = ""
    
    
    override func draw(_ rect: CGRect) {
        self.ColorFrame.SideShadow()
        self.HighlightColor = self.verseColor!.toHexString()
        
        self.HideallButton(selectedColor: self.HighlightColor)
        
    }
        
    func HideallButton(selectedColor:String) {
        self.HighlightColor = selectedColor
        
        self.HideallColor()
        
        switch (selectedColor) {

        case "#bddffa":
            self.RedImg.isHidden = false
            
        case "#fffac3":
            self.pinkImg.isHidden = false
            
        case "#fabbd0":
            self.BlueImg.isHidden = false
            
        case "#c3e0c4":
            self.SkyBlueImg.isHidden = false
            
        case "#fed6b2":
            self.GreenImg.isHidden = false
            
        case "#fe9798":
            self.BrownImg.isHidden = false
            
        case "#e7b9f8":
            self.OrangeImg.isHidden = false
            
        default:
            break
        }
    
    }
    
    func HideallColor() {
        
        self.RedImg.isHidden = true
        self.pinkImg.isHidden = true
        self.BlueImg.isHidden = true
        self.SkyBlueImg.isHidden = true
        self.GreenImg.isHidden = true
        self.BrownImg.isHidden = true
        self.OrangeImg.isHidden = true
    }
    
    
    @IBAction func RedAction(_ sender: Any) {
        self.removeHighlite(BoxColor: "#bddffa")
    }
    
    @IBAction func pinkAction(sender: UIButton!) {
        self.removeHighlite(BoxColor: "#fffac3")
    }
        
    @IBAction func BlueAction(sender: UIButton!) {
        self.removeHighlite(BoxColor: "#fabbd0")
    }
    
    @IBAction func SkyBlueAction(sender: UIButton!) {
        self.removeHighlite(BoxColor: "#c3e0c4")
    }
     
    @IBAction func GreenAction(sender: UIButton!) {
        self.removeHighlite(BoxColor: "#fed6b2")
    }
        
    @IBAction func BrownAction(sender: UIButton!) {
        self.removeHighlite(BoxColor: "#fe9798")
    }
    
    @IBAction func OrangeAction(sender: UIButton!) {
        self.removeHighlite(BoxColor: "#e7b9f8")
    }
    
    
    @IBAction func CloseFrame(sender: UIButton!) {
//        NotificationCenter.default.post(name: Notification.Name("CloseHighLite"), object: nil)
        App_Protocol.DelegateSlideCard?.ChangeHighlightStatus()
    }
 
    
    func removeHighlite(BoxColor:String) {
        self.ColorLoadFrame.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
            self.ColorLoadFrame.isHidden = true
            if self.HighlightColor == BoxColor {
                self.Colorchange(Colorname: "#000000")
                self.HideallButton(selectedColor: "#000000")
            } else {
                self.Colorchange(Colorname: BoxColor)
                self.HideallButton(selectedColor: BoxColor)
            }
          }
    }
    
    func Colorchange(Colorname:String) {
        
        let bookreplaced = self.book.replacingOccurrences(of: "  ", with: "")
        
        CoreDataModel.sharedInstance.coreDataInsert(CDBookSavedInfo, bookVerse:bookreplaced , color: Colorname, Verses: self.verse)
//        NotificationCenter.default.post(name: Notification.Name("ReloadCard"), object: nil)
        App_Protocol.DelegateSlideCard?.reloadNotedata()
        
//        self.HideallButton(selectedColor: Colorname)
//        App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
        
        
        
    }



}
