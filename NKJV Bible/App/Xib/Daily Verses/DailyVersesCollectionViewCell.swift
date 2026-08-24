//
//  DailyVersesCollectionViewCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 22/02/21.
//
 
import UIKit

class DailyVersesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var verse :UILabel!
    @IBOutlet weak var Book :UILabel!
    @IBOutlet weak var Count :UILabel!
    @IBOutlet weak var Day :UILabel!
    @IBOutlet weak var CountView :UIView!
    @IBOutlet weak var DottedLines :UIView!
    @IBOutlet weak var MenuBtn :UIButton!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        widthConstraint.constant = screenWidth - 40
         
    }
    
    
     
    
    

    
    

}
