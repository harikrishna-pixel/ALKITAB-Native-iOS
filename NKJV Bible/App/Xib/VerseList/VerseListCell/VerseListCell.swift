//
//  VerseListCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 30/03/23.
//

import UIKit

class VerseListCell: UICollectionViewCell {

    @IBOutlet weak var mainVu: UIView!
    @IBOutlet weak var CountTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            self.CountTxt.font = self.CountTxt.font.withSize(40)
        } else {
            self.CountTxt.font = self.CountTxt.font.withSize(24)
        }
        
    }
}
