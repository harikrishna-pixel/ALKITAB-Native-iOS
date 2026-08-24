//
//  DailyVerseCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 15/12/22.
//

import UIKit

class DailyVerseCell: UICollectionViewCell {

    @IBOutlet weak var verse :UILabel!
    @IBOutlet weak var Book :UILabel!
    @IBOutlet weak var Day :UILabel!
    @IBOutlet weak var MenuBtn :UIButton!
    @IBOutlet weak var backgroundImage :UIImageView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}

 
