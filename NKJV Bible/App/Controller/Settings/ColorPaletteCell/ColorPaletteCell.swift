//
//  ColorPaletteCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 17/03/21.
//

import UIKit

class ColorPaletteCell: UICollectionViewCell {
    
    @IBOutlet weak var ColorPaletteView: UIView!
    @IBOutlet weak var SelectedColor: UIView!
    @IBOutlet weak var SelectedColorImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ColorPaletteView.layer.borderColor = UIColor.white.cgColor
        self.ColorPaletteView.layer.borderWidth = 1.0
        self.ColorPaletteView.layer.cornerRadius = 10
    }
    
    
}



