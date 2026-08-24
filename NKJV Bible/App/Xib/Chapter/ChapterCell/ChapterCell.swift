//
//  ChapterCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 23/02/21.
//

import UIKit

class ChapterCell: UICollectionViewCell {

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
