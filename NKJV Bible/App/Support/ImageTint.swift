//
//  ImageTint.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 13/12/22.
//

import UIKit

class ImageTint: NSObject {
    static let sharedInstance = ImageTint()

    func imageTintcolorMethod(img:UIImageView , colorVu:UIColor){
         img.image = img.image?.withRenderingMode(.alwaysTemplate)
               img.tintColor = colorVu
    }
    
    
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            return version != currentVersion
        }
        throw VersionError.invalidResponse
    }
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    
    func convertDateFormater(_ date: String) -> String
    {
        let DateSeperate  = date.components(separatedBy: " ")
        let dateconvert  = DateSeperate[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateconvert)
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return  dateFormatter.string(from: date!)

    }
    
}
