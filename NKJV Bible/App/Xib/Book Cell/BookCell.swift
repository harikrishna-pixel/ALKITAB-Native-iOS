//
//  BookCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 31/05/24.
//

import UIKit

class BookCell: UICollectionViewCell {

    @IBOutlet var BookCatagoryList : UILabel!
    @IBOutlet var BookImage : UIImageView!
    @IBOutlet var BookLinkBtn : UIButton!
    @IBOutlet var BookImgLinkBtn : UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
