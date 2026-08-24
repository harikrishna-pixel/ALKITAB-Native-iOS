//
//  TextAttribute.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 23/12/22.
//



/*
 
 let attributedString = NSMutableAttributedString(string: "Your text")

 // *** Create instance of `NSMutableParagraphStyle`
 let paragraphStyle = NSMutableParagraphStyle()

 // *** set LineSpacing property in points ***
 paragraphStyle.lineSpacing = 2 // Whatever line spacing you want in points

 // *** Apply attribute to string ***
 attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

 // *** Set Attributed String to your label ***
 label.attributedText = attributedString
 */


import UIKit

class TextAttribute: NSObject {

    static let shared = TextAttribute()
    
    
    
    func attributedTextBoldSearch(withString string: String, boldString: String, ColorString: String, font: UIFont, line:Bool, colorStatus:Bool, color:UIColor) -> NSAttributedString {
        
      let attributedString = NSMutableAttributedString(string: string)
        
      let FontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        // OLD CODE: Thick underline was too heavy
        // let Underline: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        
        // NEW CODE: Reduced underline thickness to single line
        let Underline: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
      let BackgroundColor: [NSAttributedString.Key: Any] = [NSAttributedString.Key.backgroundColor: color]
         
      let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
        
        let range1 = (string as NSString).range(of: ColorString, options: .caseInsensitive)
        
        
        let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        attributedString.addAttribute(.foregroundColor, value: (Themecolor == BGNightMode ? DefaultYellow:Themecolor) as Any, range: range1)
        attributedString.addAttributes(FontAttribute, range: range)

        if line {
            attributedString.addAttributes(Underline, range: range)
        }
        if colorStatus {
            attributedString.addAttributes(BackgroundColor, range: range)
        }
        
        
      return attributedString
    }
    
    
    
    func attributedTextBold(withString string: String, boldString: String, font: UIFont, line:Bool, colorStatus:Bool, color:UIColor) -> NSAttributedString {
        
      let attributedString = NSMutableAttributedString(string: string)
        
      let FontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
      // OLD CODE: Thick underline was too heavy
      // let Underline: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
      
      // NEW CODE: Reduced underline thickness to single line
      let Underline: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
      let BackgroundColor: [NSAttributedString.Key: Any] = [NSAttributedString.Key.backgroundColor: color]
      let paragraphStyle = NSMutableParagraphStyle()
        // BUG FIX: Use float(forKey:) instead of integer(forKey:) for LineGap
        // OLD CODE: paragraphStyle.lineSpacing = CGFloat(UserDefaults.standard.integer(forKey: "LineGap"))
        // PROBLEM: integer() truncated float values, causing line gap to not work properly
        let savedLineGap = UserDefaults.standard.float(forKey: "LineGap")
        paragraphStyle.lineSpacing = CGFloat(savedLineGap > 0 ? savedLineGap : 4.0)

    let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
        
        attributedString.addAttributes(FontAttribute, range: range)

        if line {
            attributedString.addAttributes(Underline, range: range)
        }
        if colorStatus {
            attributedString.addAttributes(BackgroundColor, range: range)
        }
        
        
      return attributedString
    }
    
 
    func attributedTextBold1(withString string: String, SecondString: String, boldString: String, font: UIFont, Secondfont: UIFont, line:Bool, colorStatus:Bool, color:UIColor, number:String, Bookmark:Bool,Note:Bool) -> NSAttributedString {
        
        
        let textfontSize = CGFloat(UserDefaults.standard.float(forKey: "FontSize"))
        let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor")
        
      let attributedString = NSMutableAttributedString(string: string)
        
      let FontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
      // OLD CODE: Thick underline was too heavy
      // let Underline: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
      
      // NEW CODE: Reduced underline thickness to single line
      let Underline: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        
      let BackgroundColor: [NSAttributedString.Key: Any] = [NSAttributedString.Key.backgroundColor: color]
        let TextBold: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        
        let NumberBold: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: textfontSize)]
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        // BUG FIX: Use float(forKey:) instead of integer(forKey:) for LineGap
        // OLD CODE: paragraphStyle.lineSpacing = CGFloat(UserDefaults.standard.integer(forKey: "LineGap"))
        let savedLineGap = UserDefaults.standard.float(forKey: "LineGap")
        paragraphStyle.lineSpacing = CGFloat(savedLineGap > 0 ? savedLineGap : 4.0)
      
      let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
      let range1 = (string as NSString).range(of: SecondString, options: .caseInsensitive)
      let range2 = (string as NSString).range(of: number, options: .caseInsensitive)
        
        
        
        if Bookmark {
            var Bookmark = NSTextAttachment()
            
            Bookmark.image = self.resizeImage(image: UIImage(named: "UBookmark")!, targetSize: CGSizeMake(textfontSize-2, textfontSize-2), Themecolor: Themecolor!)
            
            let BookmarkString = NSAttributedString(attachment: Bookmark)
            attributedString.append(BookmarkString)
        }
        
        if Note {
            let notes = NSTextAttachment()
            notes.image = self.resizeImage(image: UIImage(named: "UNotes")!, targetSize: CGSizeMake(textfontSize-2, textfontSize-2), Themecolor: Themecolor!)
            let notesString = NSAttributedString(attachment: notes)
            attributedString.append(notesString)
        }

        attributedString.addAttributes(FontAttribute, range: range)
        attributedString.addAttributes(TextBold, range: range1)
        attributedString.addAttributes(NumberBold, range: range2)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
        
//        UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        if line {
            attributedString.addAttributes(Underline, range: range)
        }
        if colorStatus {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
            attributedString.addAttributes(BackgroundColor, range: range)
        }

            
      return attributedString
    }
    
    
    
    
    
    
    
    func attributedLineGap(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        
      let attributedString = NSMutableAttributedString(string: string)
      let FontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        
        let TextBold: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        let paragraphStyle = NSMutableParagraphStyle()
        // BUG FIX: Use float(forKey:) instead of integer(forKey:) for LineGap
        // OLD CODE: paragraphStyle.lineSpacing = CGFloat(UserDefaults.standard.integer(forKey: "LineGap"))
        let savedLineGap = UserDefaults.standard.float(forKey: "LineGap")
        paragraphStyle.lineSpacing = CGFloat(savedLineGap > 0 ? savedLineGap : 4.0)
      
      let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
        
        attributedString.addAttributes(FontAttribute, range: range)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
                 
            
      return attributedString
    }
    
    
    
    
    
    func resizeImage(image: UIImage, targetSize: CGSize, Themecolor: UIColor) -> UIImage {
       let size = image.size
       
        
       let widthRatio  = targetSize.width  / size.width
       let heightRatio = targetSize.height / size.height
       
       // Figure out what our orientation is, and use that to form the rectangle
       var newSize: CGSize
       if(widthRatio > heightRatio) {
           newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
       } else {
           newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       }
       
       // This is the rect that we've calculated out and this is what is actually used below
       let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
       
       // Actually do the resizing to the rect using the ImageContext stuff
       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       image.draw(in: rect)
       var newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       
       newImage = newImage!.withTintColor( Themecolor == BGNightMode ? UIColor.white:Themecolor)
        
       return newImage!
   }
    
    

    
    
    func attributedQuiz(withString string: String, boldString: String, color:UIColor) -> NSAttributedString {
        
      let attributedString = NSMutableAttributedString(string: string)
        
        
     let FontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
      let BackgroundColor: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: color]
        
        
      let range = (string as NSString).range(of: boldString, options: .caseInsensitive)

        attributedString.addAttributes(FontAttribute, range: range)
        attributedString.addAttributes(BackgroundColor, range: range)
        
      return attributedString
    }
    
    
    
}
