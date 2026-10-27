//
//  WallpaperCollectionViewCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 12/02/21.
//

import UIKit

class WallpaperCollectionViewCell: UICollectionViewCell {

    @IBOutlet var Wallpaper: UIImageView!
    @IBOutlet var Versetext: UILabel!
    @IBOutlet var Walpaperframe: UIView!
    @IBOutlet var Booktext: UILabel!
    @IBOutlet var TabTxt: UILabel!
    @IBOutlet var BibleName: UILabel!
    @IBOutlet var WaterMark: UIView!
    @IBOutlet var WaterMarkTxt: UILabel!
    @IBOutlet var WaterMarkVu: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TabTxt.isHidden = true
        WaterMarkVu.backgroundColor = .clear
        WaterMarkVu.layer.cornerRadius = 0
        WaterMarkVu.clipsToBounds = false
        BibleName.textAlignment = .left
        BibleName.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        BibleName.textColor = UIColor.white.withAlphaComponent(0.85)
        BibleName.alpha = 1
        BibleName.shadowColor = UIColor.black.withAlphaComponent(0.35)
        BibleName.shadowOffset = CGSize(width: 0, height: 0.5)
        for case let label as UILabel in WaterMarkVu.subviews where label !== BibleName {
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 9, weight: .regular)
            label.textColor = UIColor.white.withAlphaComponent(0.75)
            label.alpha = 1
            label.shadowColor = UIColor.black.withAlphaComponent(0.3)
            label.shadowOffset = CGSize(width: 0, height: 0.5)
        }
        for case let icon as UIImageView in WaterMarkVu.subviews {
            icon.isHidden = true
        }
        applyVerseWatermarkName()
    }

    /// Uses the configured app name, including the name loaded after the app config changes.
    func applyVerseWatermarkName() {
        let saved = (UserDefaults.standard.string(forKey: "app_name") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let splash = APPNAME_SPLASH.trimmingCharacters(in: .whitespacesAndNewlines)
        let app = APPNAME.trimmingCharacters(in: .whitespacesAndNewlines)
        if !saved.isEmpty {
            BibleName.text = saved
        } else if !splash.isEmpty {
            BibleName.text = splash
        } else {
            BibleName.text = app
        }
    }
    
    

}
