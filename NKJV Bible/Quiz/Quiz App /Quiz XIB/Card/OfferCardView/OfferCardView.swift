//
//  OfferCardView.swift
//  General Quiz
//
//  Created by ajayprasanth on 05/05/23.
//

import UIKit

class OfferCardView: UICollectionViewCell {
    
    @IBOutlet weak var CardType: UILabel!
    
    @IBOutlet weak var ImageFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var ImageFramewidth: NSLayoutConstraint!
    
    @IBOutlet weak var StatusWidth: NSLayoutConstraint!
    @IBOutlet weak var CardTypeWidth: NSLayoutConstraint!
    @IBOutlet weak var CardTypeHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
