//
//  CardView.swift
//  General Quiz
//
//  Created by ajayprasanth on 04/05/23.
//

import UIKit

class CardView: UICollectionViewCell {

   @IBOutlet weak var ViewFrameHeight: NSLayoutConstraint!
   @IBOutlet weak var ViewFramewidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var ImageFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var ImageFramewidth: NSLayoutConstraint!
    
    @IBOutlet weak var CoinLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
