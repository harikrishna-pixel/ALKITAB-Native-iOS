//
//  GetReceptKey.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 04/06/21.
//

import UIKit

class GetReceptKey: NSObject {
    
    static let shared = GetReceptKey()
     
    var receiptString:String = ""
    
    func ReceptId() -> String {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                    FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
                do {

                    let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                    self.receiptString = receiptData.base64EncodedString(options: [])
                        }
                        catch { }
                    }
        return self.receiptString
    }
    
    
    func convertData(date:String) -> Date {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        let showDate = inputFormatter.date(from: date)
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let resultString = inputFormatter.string(from: showDate!)
        let showDate1 = inputFormatter.date(from: resultString)
        
        return showDate1!
    }
    
}
