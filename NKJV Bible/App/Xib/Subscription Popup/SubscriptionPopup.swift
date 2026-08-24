//
//  SubscriptionPopup.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 13/01/23.
//

import UIKit

class SubscriptionPopup: UIView {

    
    @IBOutlet var SubscriptionText: UILabel!
    @IBOutlet var SubscriptionVc: UIView!
    @IBOutlet weak var Loader:UIActivityIndicatorView!
    var Cardframe:Bool = false
    
    
    override func draw(_ rect: CGRect) {
        
        self.SubscriptionVc.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        var enddate = CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI)
        if enddate == "" {
            enddate = Date().string(format: "dd-MM-yyyy")
        }
        
        let showDate1 = GetReceptKey.shared.convertData(date: enddate)
        let diff = showDate1.interval(ofComponent: .day, fromDate: Date())
        let newfont:UIFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        
        
        PaymentHistory.sharedInstance.Getpayment(completion: {
            if UserDefaults.standard.string(forKey: "PaymentId") ?? "" == SUBSCRIPTIONID_LifeTime {
                self.SubscriptionText.text = "Lifetime subscription Successful!\n Have endless access forever!"
            } else {
                self.SubscriptionText.attributedText = self.attributedText(withString: "\(diff+1) day(s) left for the renewal of the subscription. \n Your subscription expires on ", boldString: "\(diff+1) days", boldString2: enddate, font: newfont)
            }
            self.SubscriptionText.isHidden = false
            self.Loader.isHidden = true
            App_Protocol.delegateReader?.paymentStatus()
            App_Protocol.DelegateSlideCard?.paymentStatus()
        })
        
        
        
        
        self.SubscriptionText.textAlignment = .center
    }

    
    
    func attributedText(withString string: String, boldString: String, boldString2: String, font: UIFont) -> NSAttributedString {
      let attributedString = NSMutableAttributedString(string: string,
                                                 attributes: [NSAttributedString.Key.font: font])
      let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.white]
        
        let paragraphStyle = NSMutableParagraphStyle()
          paragraphStyle.lineSpacing = 5
          
        
        let attributedString2 = NSMutableAttributedString(string:boldString2, attributes:attrs2)
        let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white as Any, range: range)
        attributedString.addAttributes(boldFontAttribute, range: range)
        attributedString.append(attributedString2)
      return attributedString
    }
    
    
    
    
    @IBAction func DismissScreen(_ sender: Any) {
        
        if Cardframe {
            App_Protocol.DelegateSlideCard?.CloseVc()
        } else {
            App_Protocol.delegateReader?.CloseView()
        }
        
    }
    
}
