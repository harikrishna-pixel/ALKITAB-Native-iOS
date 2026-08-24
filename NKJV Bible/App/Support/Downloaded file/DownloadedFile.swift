//
//  DownloadedFile.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 28/01/21.
//

import UIKit

class DownloadedFile: NSObject {
      
    static let shared = DownloadedFile()
    var Mp3ArrayString:Array<String>?
    func DownloadedArray() -> Array<String> {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            do {
                // Get the directory contents urls (including subfolders urls)
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
                let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
                Mp3ArrayString = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
        
            } catch {
                print(error)
            }
        
        return Mp3ArrayString!
    }


    
    
}
