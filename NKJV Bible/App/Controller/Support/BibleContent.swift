//
//  BibleContent.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 09/12/22.
//

import UIKit

class BibleContent: NSObject {
    
    
    static let sharedInstance = BibleContent()
    
    
    var BibleDictionary:Dictionary<String,Array<String>> = [:]
    var BibleLis: Array<String>?
    var url:URL?
    var Bibledata:Data?
    var BibleBookList:Array<String> = []
    
    
    
    // MARK: - Audio Property list
    
    // Get all Bible chapters from Audio Property list
    func AudioBibleList(selecterBookName:String,selectedId:Int) -> Array<String> {
        
        var selected_Id:Int = 0
        selected_Id = selectedId
        
        if selectedId < 0 { selected_Id = 0 }
        
        let filename = "audio.plist"
        let foldername:String = UserDefaults.standard.string(forKey: "SelectedLanguage")!
        
        guard
            let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/\(foldername)/\(filename)")
            else { fatalError("Unable to get file") }

                self.Bibledata = try! Data(contentsOf: fileURL)
                self.BibleDictionary = try! PropertyListSerialization.propertyList(from: self.Bibledata!, options: [], format: nil) as! Dictionary<String,Array<String>>
                
            let bookNameID = self.BookToPosition(stringBook: selecterBookName)
            let AudioBiblestring = self.BibleDictionary[String(bookNameID+1)]! as Array<String>
        
        var audio1: String
        if selectedId >= AudioBiblestring.count {
            audio1 = AudioBiblestring[AudioBiblestring.count-1]
        } else {
            
            if selectedId >= 0 && selectedId < AudioBiblestring.count {
                audio1 = AudioBiblestring[selectedId]
            } else {
                UserDefaults.standard.set(1, forKey: "BookChapter")
                audio1 = AudioBiblestring[0]
            }
            
        }
        
             audio1 = audio1.withoutHtmlTags()
             audio1 = audio1.deletingPrefix("\n")
            if audio1.contains("@@@@\n") { self.BibleLis = audio1.components(separatedBy: "@@@@\n") }
            else { self.BibleLis = audio1.components(separatedBy: "@@@@") }
        
        return BibleLis!
    }
    
    
    
    
    func BookToPosition() -> Array<String> {
        let filename = "fullchapters.plist"
        let foldername:String =  UserDefaults.standard.string(forKey: "SelectedLanguage")!
        guard
            let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/\(foldername)/\(filename)")
            else { fatalError("Unable to get file") }
        
        self.Bibledata = try! Data(contentsOf: fileURL)
        self.BibleBookList = try! PropertyListSerialization.propertyList(from: self.Bibledata!, options: [], format: nil) as! Array<String>
        return self.BibleBookList
    }
    
    
    // MARK: - Full chapter Property list
    
    // Get all Bible Book name from Full chapter Property list
    func BookToPosition(stringBook:String) -> Int {
                
            let filename = "fullchapters.plist"
            let foldername:String = UserDefaults.standard.string(forKey: "SelectedLanguage")!
            
            guard
                let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/\(foldername)/\(filename)")
                else { fatalError("Unable to get file") }
        
        self.Bibledata = try! Data(contentsOf: fileURL)
        self.BibleBookList = try! PropertyListSerialization.propertyList(from: self.Bibledata!, options: [], format: nil) as! Array<String>
         
        
        let filtered = self.BibleBookList.filter { $0.contains(stringBook ) }
        
        let BookNameIndex:Int?
        if filtered.count == 0 {
            BookNameIndex = 0
        } else {
            BookNameIndex = self.BibleBookList.firstIndex(of: filtered[0])
        }
        
        return BookNameIndex!
    }
    
    
    func AudioBibleListJson(selecterBookName:String,selectedId:Int,bookNameID:Int) -> Array<String> {
            let filename = "audio.plist"
            let foldername:String = UserDefaults.standard.string(forKey: "SelectedLanguage")!
        
        guard
            let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/\(foldername)/\(filename)")
            else { fatalError("Unable to get file") }
        
            self.Bibledata = try! Data(contentsOf: fileURL)
            self.BibleDictionary = try! PropertyListSerialization.propertyList(from: self.Bibledata!, options: [], format: nil) as! Dictionary<String,Array<String>>
            let AudioBiblestring = self.BibleDictionary[String(bookNameID)]! as Array<String>
        
        
        
        var audio1: String
        if selectedId >= AudioBiblestring.count {
            audio1 = AudioBiblestring[AudioBiblestring.count-1]
        } else {
            audio1 = AudioBiblestring[selectedId]
        }
        
        
            
            audio1 = audio1.withoutHtmlTags()
            audio1 = audio1.deletingPrefix("\n")
            
           if audio1.contains("@@@@\n") { self.BibleLis = audio1.components(separatedBy: "@@@@\n") }
               else { self.BibleLis = audio1.components(separatedBy: "@@@@") }
        
        
        return BibleLis!
    }
    
    
    
    
    
    func AudioBibleListCount(selecterBookName:String) -> Int {
        let filename = "audio.plist"
        let foldername:String = UserDefaults.standard.string(forKey: "SelectedLanguage")!
    
    guard
        let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/\(foldername)/\(filename)")
        else { fatalError("Unable to get file") }
    
        self.Bibledata = try! Data(contentsOf: fileURL)
        self.BibleDictionary = try! PropertyListSerialization.propertyList(from: self.Bibledata!, options: [], format: nil) as! Dictionary<String,Array<String>>
            let bookNameID = self.BookToPosition(stringBook: selecterBookName)
            let AudioBiblestring = self.BibleDictionary[String(bookNameID+1)]! as Array<String>
        return AudioBiblestring.count
    }
    
    

}


