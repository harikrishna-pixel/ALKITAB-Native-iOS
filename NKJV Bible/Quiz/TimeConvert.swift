//
//  TimeConvert.swift
//  General Quiz
//
//  Created by ajayprasanth on 06/05/23.
//

import UIKit

class TimeConvert: NSObject {
    
 static let sharedInstance = TimeConvert()
    func ConvertSeconds(toDate:String) -> Int {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yy HH:mm:ss"
        
        let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: f.date(from: Date().string(format: "MM/dd/yy HH:mm:ss"))!, to: f.date(from: toDate)!)
        let minutes = diffComponents.minute
        let Second = diffComponents.second
        let hour = diffComponents.hour
        
        if f.date(from: Date().string(format: "MM/dd/yy HH:mm:ss"))! < f.date(from: toDate)!  {
            return abs(Second!)+abs(minutes!*60)+((abs(hour!)*60)*60)
        } else {
            return 0
        }
        
    }
    
    
}
