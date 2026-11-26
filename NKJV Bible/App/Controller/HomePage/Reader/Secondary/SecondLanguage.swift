//
//  SecondLanguage.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 23/03/21.
//

import UIKit
import Zip

class SecondLanguage: NSObject {

static let shared = SecondLanguage()

    
    var BibleDictionary:Dictionary<String,Array<String>> = [:]
    var BibleLis: Array<String>?
    var url:URL?
    var Bibledata:Data?
    var BibleBookList:Array<String> = []

    /// Dual Bible (`isDualBibleApp`): ensure the second pack (`102`) is on disk and `SecondLanguage` is set.
    /// Returning users previously skipped this, so the reader only showed the primary verse.
    static func ensureSecondLanguagePack(completion: (() -> Void)? = nil) {
        guard isDualBibleApp else {
            completion?()
            return
        }

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = docs.appendingPathComponent("102/audio.plist")
        if FileManager.default.fileExists(atPath: audioURL.path) {
            if (UserDefaults.standard.string(forKey: "SecondLanguage") ?? "").isEmpty {
                UserDefaults.standard.set("102", forKey: "SecondLanguage")
            }
            completion?()
            return
        }

        guard let zipURL = Bundle.main.url(forResource: "102", withExtension: "zip") else {
            completion?()
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Zip.unzipFile(zipURL, destination: docs, overwrite: true, password: "password", progress: { _ in })
                DispatchQueue.main.async {
                    UserDefaults.standard.set("102", forKey: "SecondLanguage")
                    completion?()
                }
            } catch {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
    
    func AudioBibleList(selectedId:Int,bookPosition:Int) -> Array<String> {
        
        let filename = "audio.plist"
        guard let foldername = UserDefaults.standard.string(forKey: "SecondLanguage"), !foldername.isEmpty else {
            return []
        }
        
    
        guard
            let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/\(foldername)/\(filename)"),
            let data = try? Data(contentsOf: fileURL),
            let dictionary = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? Dictionary<String,Array<String>>,
            let AudioBiblestring = dictionary[String(bookPosition+1)],
            !AudioBiblestring.isEmpty
            else { return [] }

            self.Bibledata = data
            self.BibleDictionary = dictionary
            
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
        
        return BibleLis ?? []
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


// MARK: - Dual Bible helper
/// Safe, cached access to the second language for saving and showing verses (My Library, notes, copy, share).
/// Only active for dual-book apps (`isDualBibleApp`) when the second language files are downloaded.
/// It never crashes when a file is missing and returns "" / the original text instead.
enum DualBibleHelper {

    private static var cacheKey = ""
    private static var primaryBooks: [String] = []
    private static var secondBooks: [String] = []
    private static var secondAudio: [String: [String]] = [:]

    private static func plistURL(folder: String, name: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("/\(folder)/\(name)")
    }

    /// Loads the book lists and the second language text once. False when dual is off or a file is missing.
    private static func prepare() -> Bool {
        guard isDualBibleApp else { return false }
        let second = UserDefaults.standard.string(forKey: "SecondLanguage") ?? ""
        let primary = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? ""
        guard !second.isEmpty, !primary.isEmpty else { return false }

        let key = "\(primary)|\(second)"
        if key == cacheKey { return true }

        guard let primaryURL = plistURL(folder: primary, name: "fullchapters.plist"),
              let secondBooksURL = plistURL(folder: second, name: "fullchapters.plist"),
              let secondAudioURL = plistURL(folder: second, name: "audio.plist"),
              let primaryData = try? Data(contentsOf: primaryURL),
              let secondBooksData = try? Data(contentsOf: secondBooksURL),
              let secondAudioData = try? Data(contentsOf: secondAudioURL),
              let primaryList = (try? PropertyListSerialization.propertyList(from: primaryData, options: [], format: nil)) as? [String],
              let secondList = (try? PropertyListSerialization.propertyList(from: secondBooksData, options: [], format: nil)) as? [String],
              let audio = (try? PropertyListSerialization.propertyList(from: secondAudioData, options: [], format: nil)) as? [String: [String]]
        else { return false }

        primaryBooks = primaryList.map { $0.components(separatedBy: "-")[0] }
        secondBooks = secondList.map { $0.components(separatedBy: "-")[0] }
        secondAudio = audio
        cacheKey = key
        return true
    }

    /// Splits "John-3:16" into book, chapter and verse. Nil when the key is not in that shape.
    private static func parse(key: String) -> (book: String, chapter: Int, verse: Int, ref: String)? {
        guard let dash = key.lastIndex(of: "-") else { return nil }
        let book = String(key[..<dash])
        let ref = String(key[key.index(after: dash)...])
        let parts = ref.components(separatedBy: ":")
        guard parts.count == 2, let chapter = Int(parts[0]), let verse = Int(parts[1]), chapter >= 1, verse >= 1 else { return nil }
        return (book, chapter, verse, ref)
    }

    private static func secondText(book: String, chapter: Int, verse: Int) -> String? {
        guard let position = primaryBooks.firstIndex(of: book),
              let chapters = secondAudio[String(position + 1)],
              chapter - 1 < chapters.count else { return nil }
        let text = chapters[chapter - 1].withoutHtmlTags().deletingPrefix("\n")
        let verses = text.contains("@@@@\n") ? text.components(separatedBy: "@@@@\n") : text.components(separatedBy: "@@@@")
        guard verse - 1 < verses.count else { return nil }
        let value = verses[verse - 1].trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    private static func secondTitle(book: String) -> String? {
        guard let position = primaryBooks.firstIndex(of: book), position < secondBooks.count else { return nil }
        return secondBooks[position]
    }

    /// "\n\n" + second language verse, added after the primary verse when it is saved. "" when dual is off or the verse is missing.
    static func suffix(forKey key: String) -> String {
        guard prepare(), let item = parse(key: key),
              let text = secondText(book: item.book, chapter: item.chapter, verse: item.verse) else { return "" }
        return "\n\n\(text)"
    }

    /// For Copy and Share: "\n\n" + "SecondBook 3:16- " + second language verse. "" when dual is off.
    static func titledSuffix(forKey key: String) -> String {
        guard prepare(), let item = parse(key: key),
              let title = secondTitle(book: item.book),
              let text = secondText(book: item.book, chapter: item.chapter, verse: item.verse) else { return "" }
        return "\n\n\(title) \(item.ref)- \(text)"
    }

    /// Applies `libraryText` to a split library record (`[bookVerse, color, note, verse, ...]`).
    static func libraryValues(_ values: [String]) -> [String] {
        guard values.count > 3 else { return values }
        var result = values
        result[3] = libraryText(values[3], key: values[0]) 
        return result
    }

    /// My Library display: primary verse + second book name/reference + second language verse.
    /// Uses saved dual text when present; otherwise loads the second language for display (dual only).
    /// Returns the saved text unchanged when dual is off or the second verse is missing.
    static func libraryText(_ stored: String, key: String) -> String {
        guard prepare(), let item = parse(key: key),
              let title = secondTitle(book: item.book),
              let text = secondText(book: item.book, chapter: item.chapter, verse: item.verse) else {
            return stored
        }
        let marker = "\n\(title) \(item.ref)- "
        if let separator = stored.range(of: "\n\n") {
            return stored.replacingCharacters(in: separator, with: marker)
        }
        if stored.contains(marker) { return stored }
        return stored + marker + text
    }
}
