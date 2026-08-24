//
//  fontAlign.swift
//  ImageEditor
//
//  Created by ajayprasanth on 29/03/23.
//

import UIKit

class fontAlign: UIView {

//    @IBOutlet weak var TLheight: NSLayoutConstraint!
//    @IBOutlet weak var BLheight: NSLayoutConstraint!
    
    
    @IBOutlet weak var CenterA: UIView!
    @IBOutlet weak var LeftA: UIView!
    @IBOutlet weak var RightA: UIView!
    
    @IBOutlet weak var CenterImg: UIImageView!
    @IBOutlet weak var LeftImg: UIImageView!
    @IBOutlet weak var RightImg: UIImageView!
    
    
    @IBOutlet weak var FrameLeft: NSLayoutConstraint!
    @IBOutlet weak var FrameRight: NSLayoutConstraint!
    
    var LettervaluePlus:CGFloat = 20.0
    var TextvaluePlus:CGFloat = 1.0
    var LinevaluePlus:CGFloat = 1.0
    
 
    override func draw(_ rect: CGRect) {
        self.InitVu()
        
//        self.BLheight.constant = UIScreen.main.bounds.width-24
        
        let Fwidth = UIScreen.main.bounds.width-24
         
        if  Fwidth > 447 {
            self.FrameLeft.constant = (Fwidth-447)/2
            self.FrameRight.constant = (Fwidth-447)/2
        } else {
            self.FrameLeft.constant = 0
            self.FrameRight.constant = 0
        }
    
        switch Talignment {
        case .right:
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.RightImg!, colorVu: .white)
            self.RightA.backgroundColor = .blue
        case .left:
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.LeftImg!, colorVu: .white)
            self.LeftA.backgroundColor = .blue
        default:
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.CenterImg!, colorVu: .white)
            self.CenterA.backgroundColor = .blue
        }
        
    }

    
    
    func InitVu() {
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.CenterImg!, colorVu: AlignIconColor)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.LeftImg!, colorVu: AlignIconColor)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.RightImg!, colorVu: AlignIconColor)
        
        self.CenterA.backgroundColor = HexColorConvert.shared.hexStringToUIColor(hex: "EEEEEE")
        self.LeftA.backgroundColor = HexColorConvert.shared.hexStringToUIColor(hex: "EEEEEE")
        self.RightA.backgroundColor = HexColorConvert.shared.hexStringToUIColor(hex: "EEEEEE")
    }
    
    
    
    @IBAction func AlignLeft_Action(_ sender: Any) {
        self.InitVu()
        self.LeftA.backgroundColor = .blue
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.LeftImg!, colorVu: .white)
        ImageAppProtocol.ImageTxtEditDelegate?.alignment_Action(alignment: .left)
    }
    
    @IBAction func AlignRight_Action(_ sender: Any) {
        self.InitVu()
        self.RightA.backgroundColor = .blue
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.RightImg!, colorVu: .white)
        ImageAppProtocol.ImageTxtEditDelegate?.alignment_Action(alignment: .right)
    }
    
    @IBAction func AlignCenter_Action(_ sender: Any) {
        self.InitVu()
        self.CenterA.backgroundColor = .blue
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.CenterImg!, colorVu: .white)
        ImageAppProtocol.ImageTxtEditDelegate?.alignment_Action(alignment: .center)
    }
    
    
    

    @IBAction func TextPlus_Action(_ sender: Any) {
        if TextvaluePlus < 6.0 && TextvaluePlus >= 1.0 {
            TextvaluePlus = TextvaluePlus+0.5
            ImageAppProtocol.ImageTxtEditDelegate?.textspace_Action(textGape: TextvaluePlus)
        } else {
            self.makeToast("Reached End", duration: 1.5, position: .center)
        }
    }

    @IBAction func TextMinus_Action(_ sender: Any) {
        if TextvaluePlus <= 6.0 && TextvaluePlus > 1.0 {
            TextvaluePlus = TextvaluePlus-0.5
            ImageAppProtocol.ImageTxtEditDelegate?.textspace_Action(textGape: TextvaluePlus)
        } else {
            self.makeToast("Reached End", duration: 1.5, position: .center)
        }
    }




    @IBAction func LetterPlus_Action(_ sender: Any) {
        if LettervaluePlus < 30 && LettervaluePlus >= 10 {
            LettervaluePlus = LettervaluePlus+1.0
            ImageAppProtocol.ImageTxtEditDelegate?.FontSize_Action(FontSize: LettervaluePlus)
        } else {
            self.makeToast("Reached End", duration: 1.5, position: .center)
        }
    }

    @IBAction func LetterMinus_Action(_ sender: Any) {
        if LettervaluePlus <= 30 && LettervaluePlus > 10 {
            LettervaluePlus = LettervaluePlus-1.0
            ImageAppProtocol.ImageTxtEditDelegate?.FontSize_Action(FontSize: LettervaluePlus)
        } else {
            self.makeToast("Reached End", duration: 1.5, position: .center)
        }
    }


    @IBAction func LinePlus_Action(_ sender: Any) {
        
        if LinevaluePlus < 10.0 && LinevaluePlus >= 1.0 {
            LinevaluePlus = LinevaluePlus+0.5
            ImageAppProtocol.ImageTxtEditDelegate?.linegape_Action(lineGape: LinevaluePlus)
        } else {
            self.makeToast("Reached End", duration: 1.5, position: .center)
        }
    }
    
    @IBAction func LineMinus_Action(_ sender: Any) {
        if LinevaluePlus <= 10.0 && LinevaluePlus > 1.0 {
            LinevaluePlus = LinevaluePlus-0.5
            ImageAppProtocol.ImageTxtEditDelegate?.linegape_Action(lineGape: LinevaluePlus)
        } else {
            self.makeToast("Reached End", duration: 1.5, position: .center)
        }
    }
    
    
    
    
    
    

}
