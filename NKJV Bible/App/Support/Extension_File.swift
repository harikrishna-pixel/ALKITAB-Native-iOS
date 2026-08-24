//
//  Extension_File.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 08/12/22.
//

import UIKit

class Extension_File: NSObject {

    
}



extension UIView {
    private static let lineDashPattern: [NSNumber] = [3, 3]
    private static let lineDashWidth: CGFloat = 1.0

    func addDashedBorderView() {
        self.backgroundColor! = UIColor.clear
        let path = CGMutablePath()
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = UIView.lineDashWidth
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineDashPattern = UIView.lineDashPattern
        path.addLines(between: [CGPoint(x: bounds.width/2 , y: bounds.minY ),
                                CGPoint(x: bounds.width/2, y: bounds.maxY )])
        
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
}


extension UIView {
    private static let DashPattern: [NSNumber] = [5, 7]
    private static let DashWidth: CGFloat = 1.0

    func addDashedLine() {
        self.backgroundColor! = UIColor.clear
        let path = CGMutablePath()
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = UIView.DashWidth
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineDashPattern = UIView.DashPattern
        path.addLines(between: [CGPoint(x: bounds.minX, y: bounds.height/2),
                                CGPoint(x: bounds.maxX, y: bounds.height/2)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
}




// view blue frame
  extension UIView {
    func ThemeColor() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
    }
}



extension UIView {
    func AbotyUsBorderVu() {
        self.layer.cornerRadius = self.layer.frame.height/2
        self.layer.masksToBounds = false
        self.layer.borderColor = UserDefaults.standard.color(forKey: "AppThemeColor")?.cgColor
        self.layer.borderWidth = 1
    }
}


extension UIView {
    func ViewShadow(_ round:CGFloat, color: UIColor) {
        self.layer.cornerRadius = round
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 3
    }
}

extension UIView {
    func VerseCountVu() {
        self.layer.masksToBounds = true
        self.layer.shadowRadius = 3
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor.gray.cgColor
    }
}



extension UIView {
    func SideShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 2
    }
}



extension UIView {
    func ViewBorder(color:UIColor, radius:CGFloat = 4) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = radius
    }
}



// MARK: ZOOM VIEW

extension UIView {
    func zoomIn(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = .identity
            }) { (animationCompleted: Bool) -> Void in
        }
    }
}






extension String {
    func withoutHtmlTags() -> String {
        let str = self.replacingOccurrences(of: "<style>[^>]+</style>", with: "", options: .regularExpression, range: nil)
        return str.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}



extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}




extension UIView {

   func roundTopCorners(radius: CGFloat = 20) {
    
       self.clipsToBounds = true
       self.layer.cornerRadius = radius
       if #available(iOS 11.0, *) {
           self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
       } else {
           self.roundCorners(corners: [.topLeft, .topRight], radius: radius)
       }
   }

   func roundBottomCorners(radius: CGFloat = 10) {
    
       self.clipsToBounds = true
       self.layer.cornerRadius = radius
       if #available(iOS 11.0, *) {
           self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
       } else {
           self.roundCorners(corners: [.bottomLeft, .bottomRight], radius: radius)
       }
   }

   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}



//// Radius
//
//extension UIView {
//   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
//        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        layer.mask = mask
//    }
//}



// MARK: - Color Extension

extension UserDefaults {

    func color(forKey key: String) -> UIColor? {

        guard let colorData = data(forKey: key) else { return nil }

        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }

    }

    func set(_ value: UIColor?, forKey key: String) {

        guard let color = value else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch let error {
            print("error color key data not saved \(error.localizedDescription)")
        }

    }
    
}


extension UIColor {
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return NSString(format:"#%06x", rgb) as String
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

}


extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}


extension String {
    
       func lines() -> CGFloat {

        // BUG FIX: Use float(forKey:) instead of integer(forKey:) for FontSize
        // OLD CODE: var fontsize = UserDefaults.standard.integer(forKey: "FontSize")
        // PROBLEM: integer() truncated float values, causing font size to be 0 or wrong value
        let savedFontSize = UserDefaults.standard.float(forKey: "FontSize")
        var fontsize = Int(savedFontSize > 0 ? savedFontSize : 17.0)
        if fontsize == 0 { fontsize = 17 }
        
        let font =  UIFont(name: UserDefaults.standard.string(forKey: "FontName")!, size: CGFloat(fontsize)*(1.2))
       let width = ScreenWidth-40
           let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)

        return boundingBox.height/font!.lineHeight
       }
}



extension String {
    
       func Notelines() -> CGFloat {

       let font =  UIFont(name: UserDefaults.standard.string(forKey: "FontName")!, size: 20)
       let width = ScreenWidth-20
       let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)

        return boundingBox.height/font!.lineHeight
       }
}



// set nib in uiview
extension UIView {
    class func fromNib(named: String? = nil) -> Self {
        let name = named ?? "\(Self.self)"
        guard
            let nib = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
            else { fatalError("missing expected nib named: \(name)") }
        guard
            let view = nib.first as? Self
            else { fatalError("view of type \(Self.self) not found in \(nib)") }
        return view
    }
}

extension UIView {
    func chapterLayout(color:UIColor) {
      self.layer.masksToBounds = true
      self.layer.cornerRadius = 10
        self.layer.borderColor = color.cgColor
      self.layer.borderWidth = 1
  }
}


// MARK:  Date Format convert
extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}


extension Date {

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current

        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

        return end - start
    }
}






extension UIView {

    func asImage() -> UIImage {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}


extension Date {
    
    static var sixMonth: Date { return Date().sixmonthAfter }
    static var oneYear: Date { return Date().oneYearAfter }
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    static var Week:  Date { return Date().twoWeek }
    static var OneWeek:  Date { return Date().oneWeek }
    static var oneMonth:  Date { return Date().twoWeek }
    static var DayThree:  Date { return Date().ThirdDay }
    static var current:  Date { return Date() }
    static var Before30:  Date { return Date() }
    static var OneDay:  Date { return Date() }
    
    
    var sixmonthAfter: Date {
        return Calendar.current.date(byAdding: .month, value: 6, to: noon)!
    }
    
    var oneYearAfter: Date {
        return Calendar.current.date(byAdding: .year, value: 1, to: noon)!
    }
    
    
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -10, to: noon)!
    }
    
    var Before30: Date {
        return Calendar.current.date(byAdding: .minute, value: 30, to: noon)!
    }
    
    var oneWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: noon)!
    }
    
    
    var twoWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 14, to: noon)!
    }
    
    var oneMonth: Date {
        return Calendar.current.date(byAdding: .day, value: 30, to: noon)!
    }
    
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 2, to: noon)!
    }
    
    var OneDay: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    var ThirdDay: Date {
        return Calendar.current.date(byAdding: .day, value: 3, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}


extension Date {
    
  func isEqualTo(_ date: Date) -> Bool {
    return self == date
  }
  func isGreaterThan(_ date: Date) -> Bool {
     return self > date
  }
  func isSmallerThan(_ date: Date) -> Bool {
     return self < date
  }
}





// MARK: Cleat Temp Files

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}



extension String {

    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return self.filter {okayChars.contains($0) }
    }
}


extension String {

    var strippedtext: String {
        let okayChars = Set(".abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return self.filter {okayChars.contains($0) }
    }
}





extension UILabel {

    func addInterlineSpacing(spacingValue: CGFloat = 2, Align:NSTextAlignment = .left) {

       guard let textString = text else { return }
       
       let attributedString = NSMutableAttributedString(string: textString)
       let paragraphStyle = NSMutableParagraphStyle()
       paragraphStyle.lineSpacing = spacingValue
       paragraphStyle.alignment = Align

       attributedString.addAttribute(
           .paragraphStyle,
           value: paragraphStyle,
           range: NSRange(location: 0, length: attributedString.length
       ))

       attributedText = attributedString
   }

}



extension UIImage {

    func imageWithSize(scaledToSize newSize: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

}
