//
//  SecondLanguage.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 23/03/21.
//

import UIKit

class SecondLanguage: NSObject {

static let shared = SecondLanguage()

    
    var BibleDictionary:Dictionary<String,Array<String>> = [:]
    var BibleLis: Array<String>?
    var url:URL?
    var Bibledata:Data?
    var BibleBookList:Array<String> = []
    
    func AudioBibleList(selectedId:Int,bookPosition:Int) -> Array<String> {
        
        let filename = "audio.plist"
        let foldername:String = UserDefaults.standard.string(forKey: "SecondLanguage")!
        
    
        guard
            let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/\(foldername)/\(filename)")
            else { fatalError("Unable to get file") }
        
            self.Bibledata = try! Data(contentsOf: fileURL)
            self.BibleDictionary = try! PropertyListSerialization.propertyList(from: self.Bibledata!, options: [], format: nil) as! Dictionary<String,Array<String>>
        
            let bookNameID = bookPosition
            let AudioBiblestring = self.BibleDictionary[String(bookNameID+1)]! as Array<String>
            
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
    
    func PrimaryAudioBibleList(selectedId:Int,bookPosition:Int) -> Array<String> {
        
        let filename = "audio.plist"
        let foldername:String = UserDefaults.standard.string(forKey: "SelectedLanguage")!
        
    
        guard
            let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/\(foldername)/\(filename)")
            else { fatalError("Unable to get file") }

            self.Bibledata = try! Data(contentsOf: fileURL)
            self.BibleDictionary = try! PropertyListSerialization.propertyList(from: self.Bibledata!, options: [], format: nil) as! Dictionary<String,Array<String>>
        
            let bookNameID = bookPosition
            let AudioBiblestring = self.BibleDictionary[String(bookNameID+1)]! as Array<String>
            var audio1 = AudioBiblestring[selectedId]
                audio1 = audio1.withoutHtmlTags()
            audio1 = audio1.deletingPrefix("\n")
    
            if audio1.contains("@@@@\n") { self.BibleLis = audio1.components(separatedBy: "@@@@\n") }
                else { self.BibleLis = audio1.components(separatedBy: "@@@@") }
        
        return BibleLis!
    }
    
    
}

