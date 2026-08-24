//
//  DownloadAndLoad.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 13/09/23.
//

import UIKit

class DownloadAndLoad: NSObject {

    
    static let shared = DownloadAndLoad()
    var image:[UIImage] = []
    var imagee: [URL] = []
    
    
    func loadImageFromDiskWith() {
        
        do {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let directoryContents = try! FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
        
            imagee = directoryContents.filter{ ($0.pathExtension == "pdf") || ($0.pathExtension == "jpg") || ($0.pathExtension == "png") || ($0.pathExtension == "jpeg")}
            
            for i in imagee {
                image.append(UIImage(contentsOfFile: i.path)!)
            }
            
        } catch {
            print(error)
        }
        
    }
    
    
}
