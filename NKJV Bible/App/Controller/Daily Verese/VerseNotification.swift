//
//  VerseNotifi.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 12/02/21.
//

import UIKit

@available(iOS 13.0, *)
class VerseNotification: NSObject {

     
    static let sharedInstance = VerseNotification()

    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var MessageTitleAndMsg = ""
    var VerseDate = ""

    
    
    
//    @objc func JsonBibleBook()  -> String {
//          self.VersCountChange()
//        return self.MessageTitleAndMsg
//    }
    
   
    
    
//    func VersCountChange() {
//
//        
//        if  UserDefaults.standard.string(forKey: "NotifiDate") == nil ||  UserDefaults.standard.string(forKey: "NotifiDate")! != Date().string(format: "MMM d, yyyy") {
//            
//            self.VersCall()
//            
//            if self.MessageTitleAndMsg == "" {
////                DispatchQueue.global(qos: .background).async {
////                    DispatchQueue.main.async {
//                        self.VersCall()
////                    }
////                  }
//            }
//            UserDefaults.standard.set(Date().string(format: "MMM d, yyyy"), forKey: "NotifiDate")
//        }
//    }
    
    
    func VersCall() {
        if let path = Bundle.main.path(forResource: "dailyVerse", ofType: "json") {
            do {
                
                
                if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
                    UserDefaults.standard.set(1, forKey: "Verses")
                }

                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  let jsonOutput = jsonResult as! Array<AnyObject>
                  var VersePosition = UserDefaults.standard.integer(forKey: "Verses")
                  let VerseInfo = jsonOutput[VersePosition]

                  let chapterList =  BibleContent.sharedInstance.AudioBibleListJson(selecterBookName: VerseInfo["Book"] as! String, selectedId: VerseInfo["Chapter"] as! Int-1, bookNameID: VerseInfo["Book_Id"] as! Int)
                
                  var verse = VerseInfo["Verse"] as! String
                  let BookId = VerseInfo["Book_Id"] as! Int
                  let BookName = BibleContent.sharedInstance.BookToPosition()[BookId-1].components(separatedBy: "-")
                  let bookChapterId = "\(BookName[0]) \(VerseInfo["Chapter"] as! Int):\(verse)"
                 
                if self.VerseDate == "" {
                    self.VerseDate = Date().string(format: "MMM d, yyyy")
                }
                
                if verse.contains("--") {
                    var verseArray = verse.components(separatedBy: "--")
                    
                    if Int(verseArray[0])! > chapterList.count {
                        verseArray[0] = String(chapterList.count-1)
                    }
                    if Int(verseArray[1])! > chapterList.count {
                        verseArray[1] = String(chapterList.count-1)
                    }
                    let verseText = String(format: "%@\n%@",chapterList[Int(verseArray[0])!-1],chapterList[Int(verseArray[1])!-1])
                    self.MessageTitleAndMsg = "\(verseText)_\(bookChapterId)"

                    CoreDataModel.sharedInstance.coreDataInsertNotification(CDDailyVerses, book: bookChapterId, verseDate:self.VerseDate, verse: verseText)
                } else {
                    
                    if Int(verse)! > chapterList.count {
                        verse = String(chapterList.count-1)
                    }
                    
                    self.MessageTitleAndMsg =  "\(chapterList[Int(verse)!-1])||\(chapterList[Int(verse)!-1])_\(bookChapterId)"
                    
                    CoreDataModel.sharedInstance.coreDataInsertNotification(CDDailyVerses, book: bookChapterId, verseDate:self.VerseDate, verse: chapterList[Int(verse)!-1])
                    
                }
                self.VerseDate = ""
                
                
                if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
                    VersePosition = 0
                }
                
                UserDefaults.standard.set(VersePosition+1, forKey: "Verses")
                UserDefaults.standard.set("1", forKey: "NotifiCellStatus")
                NotificationCenter.default.post(name: Notification.Name("ReloadTable"), object: nil)
                
              } catch {
                   // handle error
            }
        }
    }
     
    
    func DateLoop() {
        
        let ti:TimeInterval = 24*60*60 //one day
        let dateFrom = Date.yesterday
        let dateTo = dateFrom.addingTimeInterval(24*60*60*11) //10 Days later

        var nextDate = Date.yesterday
        let endDate = dateTo.addingTimeInterval(0)
        
        while nextDate.compare(endDate as Date) == ComparisonResult.orderedAscending
        {
            
            if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
                UserDefaults.standard.set(1, forKey: "Verses")
            }
            self.VerseDate = nextDate.string(format: "MMM d, yyyy")
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Verses"), forKey: "NotifiVerses")
            self.VersCall()
            nextDate = nextDate.addingTimeInterval(ti)
            if UserDefaults.standard.integer(forKey: "NotifiVerses") >= 563 {
                UserDefaults.standard.set(1, forKey: "NotifiVerses")
            }
        }
        
        
    }
    
    
    func timeConversion24(time12: String) -> String {
         
        var time24:String = "08:00:00"
        let dateAsString = time12
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        let date = df.date(from: dateAsString)
        df.dateFormat = "HH:mm:ss"
        
        if date != nil{
          time24 = df.string(from: date!)
        }
        return time24
    }
    
    
}


extension Date: Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}


