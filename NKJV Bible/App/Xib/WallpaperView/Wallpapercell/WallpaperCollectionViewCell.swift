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
         
//        self.Versetext.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: 20)
        self.ButtonAnimation()
        
    }
    
    func ButtonAnimation() {
        UIView.animate(withDuration: 0.6,
            animations: {
                self.TabTxt.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: { _ in
              self.ButtonAnimation1()
            })
    }
    
    func  ButtonAnimation1() {
        UIView.animate(withDuration: 0.6,
                animations: {
                    self.TabTxt.transform = CGAffineTransform.identity 
                },
                completion: { _ in
               self.ButtonAnimation()
          })
    }
    
    

}
