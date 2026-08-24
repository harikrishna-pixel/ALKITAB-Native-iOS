//
//  AppProtocol.swift
//  ImageEditor
//
//  Created by ajayprasanth on 06/04/23.
//

import UIKit

class ImageAppProtocol: NSObject {
    
    static var ImageTxtEditDelegate: ImageTxtEdit?
}


protocol ImageTxtEdit {
    func atributetxt()
    
    func ImageChange_Action(Image:UIImage)
    func linegape_Action(lineGape: CGFloat)
    func textspace_Action(textGape: CGFloat)
    func alignment_Action(alignment:NSTextAlignment)
    func Color_Action()
    func CallColorPicker()
    func Font_Action(fontStyle:String)
    func FontSize_Action(FontSize:CGFloat)
    func StickerCall(image:UIImage)
    func fontColor_Action(fontColor: UIColor)
    
    func AdNotAvailable()
    func CollectCoin()
    func CheckPay()
    
}


