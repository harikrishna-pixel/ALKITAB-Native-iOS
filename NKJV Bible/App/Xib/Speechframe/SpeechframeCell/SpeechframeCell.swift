//
//  SpeechframeCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 07/10/21.
//

import UIKit

class SpeechframeCell: UITableViewCell {

    @IBOutlet weak var language:UILabel!
    @IBOutlet weak var Name:UILabel!
    @IBOutlet weak var SelectedAudio:UIImageView!
    @IBOutlet weak var MainFrame:UIView!

    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.SelectedAudio! , colorVu: UIColor.white)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
