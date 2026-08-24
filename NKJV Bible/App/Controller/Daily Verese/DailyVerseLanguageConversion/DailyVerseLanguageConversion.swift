//
//  DailyVerseLanguageConversion.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 03/06/21.
//

import UIKit

class DailyVerseLanguageConversion: NSObject {
    
    //
    var MessageTitleAndMsg = ""
    var DeilyVersAry: Array<String> = []
    var DeilyVersDateAry: Array<String> = []
    static let sharedInstance = DailyVerseLanguageConversion()
    
    
    func DailyVerseList(Book_Name:String,Chapter:Int,Book_Id:Int,verse_Id:String) -> String {
                        
        let chapterList =  BibleContent.sharedInstance.AudioBibleListJson(selecterBookName: Book_Name, selectedId: Chapter, bookNameID: Book_Id)
                let verse = verse_Id
                let bookChapterId = "\(Book_Name) \(Chapter):\(verse)"
        
                
        if verse.contains("--") {
                let verseArray = verse.components(separatedBy: "--")
                let verseText = String(format: "%@\n%@",chapterList[Int(verseArray[0])!-1],chapterList[Int(verseArray[1])!-1])
                self.MessageTitleAndMsg = "\(verseText)_\(bookChapterId)"
                    
        } else {
            
                 self.MessageTitleAndMsg =  "\(chapterList[Int(verse)!-1])||\(chapterList[Int(verse)!-1])_\(bookChapterId)"
               }
        
        return self.MessageTitleAndMsg
     }
    
    
    
    
    func DailyVerseLAst() -> String {
        let notification_data = CoreDataModel.sharedInstance.GetAllNotificationData(entity: CDDailyVerses)
        if notification_data.count > 0 {
            self.MessageTitleAndMsg = notification_data[notification_data.count-1]
        }

        return self.MessageTitleAndMsg
    }
    
    
    
}

