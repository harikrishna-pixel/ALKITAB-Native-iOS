//
//  NotificationList_data.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 14/09/23.
//

import UIKit

class NotificationList_data: NSObject {
    
    static let sharedInstance = NotificationList_data()
     
    
//    func RefreshData() {
//
//
////        let Date1 = GetReceptKey.shared.convertData(date: "11-05-2023")
//
//        let Date1 = GetReceptKey.shared.convertData(date: UserDefaults.standard.string(forKey: "TodayDate")!)
//        var diff = Date().interval(ofComponent: .day, fromDate: Date1)
//        diff = diff-1
//
//        if diff >= 0 {
//            for i in 0..<diff {
//                VerseNotification.sharedInstance.VersCall()
//            }
//            UserDefaults.standard.set(Date().string(format: "dd-MM-yyyy"), forKey: "TodayDate")
//        }
//
//        return
//    }

    
    
    // =>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    // =>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    // =>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    
    func UpdateDailyVerse() {
                
        let Date1 = GetReceptKey.shared.convertData(date: UserDefaults.standard.string(forKey: "LastOpenedDate")!)
        let diff = Date().interval(ofComponent: .day, fromDate: Date1)
        
        
        if diff > 1 {
            
            let ti:TimeInterval = 24*60*60 //one day
            let dateFrom = Date.yesterday
            let dateTo = dateFrom.addingTimeInterval(TimeInterval(24*60*60*diff))

            var nextDate = Date.yesterday
            let endDate = dateTo.addingTimeInterval(0)

            
            let filename = "audio.plist"
            let foldername:String = UserDefaults.standard.string(forKey: "SelectedLanguage")!
        
        guard
            let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/\(foldername)/\(filename)")
            else { fatalError("Unable to get file") }
        
            let Bibledata = try! Data(contentsOf: fileURL)
            let BibleDictionary = try! PropertyListSerialization.propertyList(from: Bibledata, options: [], format: nil) as! Dictionary<String,Array<String>>
            
            
            if let path = Bundle.main.path(forResource: "dailyVerse", ofType: "json") {
                
                do {                    
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    let jsonOutput = jsonResult as! Array<AnyObject>
                    
                    
                    while nextDate.compare(endDate as Date) == ComparisonResult.orderedAscending
                    {
                        if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
                                      UserDefaults.standard.set(1, forKey: "Verses")
                                  }
                        self.VersCall(DateOfVerse: nextDate.string(format: "MMM d, yyyy"), BibleDictionary: BibleDictionary, jsonOutput: jsonOutput)
                        
                        if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
                            UserDefaults.standard.set(1, forKey: "Verses")
                        }
                        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Verses"), forKey: "NotifiVerses")
                        nextDate = nextDate.addingTimeInterval(ti)
                    }
                    
                } catch {
                    
                }
                
//                UserDefaults.standard.setValue(Date1.string(format: "dd-MM-yyyy"), forKey: "LastOpenedDate")
                UserDefaults.standard.setValue(Date().string(format: "dd-MM-yyyy"), forKey: "LastOpenedDate")
                
            }
        }
        
    }
    
    
    
    
    
    func VersCall(DateOfVerse:String, BibleDictionary: [String : Array<String>], jsonOutput: [AnyObject]) {
        
        
        if UserDefaults.standard.integer(forKey: "Verses") == 563 {
            UserDefaults.standard.set(1, forKey: "Verses")
        }
        
        
        var VersePosition = UserDefaults.standard.integer(forKey: "Verses")
        let VerseInfo = jsonOutput[VersePosition]
        
        
        
        let chapterList =  self.AudioBibleListJson(selecterBookName: VerseInfo["Book"] as! String, selectedId: VerseInfo["Chapter"] as! Int-1, bookNameID: VerseInfo["Book_Id"] as! Int, BibleDictionary: BibleDictionary)
                
                  var verse = VerseInfo["Verse"] as! String
                  let BookId = VerseInfo["Book_Id"] as! Int
                  let BookName = BibleContent.sharedInstance.BookToPosition()[BookId-1].components(separatedBy: "-")
                  let bookChapterId = "\(BookName[0]) \(VerseInfo["Chapter"] as! Int):\(verse)"
                 
                
                if verse.contains("--") {
                    var verseArray = verse.components(separatedBy: "--")
                    
                    if Int(verseArray[0])! > chapterList.count {
                        verseArray[0] = String(chapterList.count-1)
                    }
                    if Int(verseArray[1])! > chapterList.count {
                        verseArray[1] = String(chapterList.count-1)
                    }
                    let verseText = String(format: "%@\n%@",chapterList[Int(verseArray[0])!-1],chapterList[Int(verseArray[1])!-1])

                    CoreDataModel.sharedInstance.coreDataInsertNotification(CDDailyVerses, book: bookChapterId, verseDate:DateOfVerse, verse: verseText)
                } else {
                    
                    if Int(verse)! > chapterList.count {
                        verse = String(chapterList.count-1)
                    }
                    
                    CoreDataModel.sharedInstance.coreDataInsertNotification(CDDailyVerses, book: bookChapterId, verseDate:DateOfVerse, verse: chapterList[Int(verse)!-1])
                }
        
        
        if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
            VersePosition = 0
            UserDefaults.standard.set(VersePosition+1, forKey: "Verses")
        } else {
            UserDefaults.standard.set(VersePosition+1, forKey: "Verses")
        }
  
    }
    
    
    
    
         
    
    
    func AudioBibleListJson(selecterBookName:String,selectedId:Int,bookNameID:Int, BibleDictionary: [String : Array<String>]) -> Array<String> {
            let AudioBiblestring = BibleDictionary[String(bookNameID)]! as Array<String>
        
            var audio1: String
                if selectedId >= AudioBiblestring.count {
                    audio1 = AudioBiblestring[AudioBiblestring.count-1]
                } else {
                    audio1 = AudioBiblestring[selectedId]
                }
            
            audio1 = audio1.withoutHtmlTags()
            audio1 = audio1.deletingPrefix("\n")
            var BibleLis: Array<String> = []
            
           if audio1.contains("@@@@\n") { BibleLis = audio1.components(separatedBy: "@@@@\n") }
               else { BibleLis = audio1.components(separatedBy: "@@@@") }
        
        
        return BibleLis
    }
    
    
    
    
    
    // =>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    // =>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    // =>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    
    
    
}

