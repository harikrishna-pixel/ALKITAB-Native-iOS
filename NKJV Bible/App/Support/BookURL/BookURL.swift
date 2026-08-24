//
//  BookURL.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 22/01/21.
//

import UIKit

class BookURL: NSObject {
    
    
    static let sharedInstance = BookURL()
    let Userdefault = UserDefaults.standard
    var audioURLKEY = "Chapter"
    

    func bookURL(BookNo:String) -> String {
    
        let BooKPosition =  BibleContent.sharedInstance.BookToPosition(stringBook: UserDefaults.standard.string(forKey: "BookName") ?? BibleContent.sharedInstance.BookToPosition()[0].components(separatedBy: "-")[0])
         
        
        
        let Book = String(format: "%02i%03i",BooKPosition+1,Int(BookNo)!)
        UserDefaults.standard.set(Book, forKey: "Bookurl")
        var BookurlForAudio:String = "" 
        
        if BASEPATH_TYPE == "1" {
            BookurlForAudio = String(format: "%02i/%03i",BooKPosition+1,Int(BookNo)!)
        } else if BASEPATH_TYPE == "3" {
            BookurlForAudio = String(format: "%i/%i",BooKPosition+1,Int(BookNo)!)
        } else {
            BookurlForAudio = Book
        }
        
        UserDefaults.standard.set(BookurlForAudio, forKey: "BookurlForAudio")
        
        return Book
    }    
}
