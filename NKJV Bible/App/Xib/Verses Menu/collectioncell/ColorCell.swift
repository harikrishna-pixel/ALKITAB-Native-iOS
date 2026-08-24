//
//  ColorCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 13/12/22.
//

import UIKit

class ColorCell: UICollectionViewCell {
    
    @IBOutlet weak var Tick: UIImageView!
    @IBOutlet weak var ColorView: UIView!
    @IBOutlet weak var TicKiconwidth: NSLayoutConstraint!
    @IBOutlet weak var TicKiconheight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
