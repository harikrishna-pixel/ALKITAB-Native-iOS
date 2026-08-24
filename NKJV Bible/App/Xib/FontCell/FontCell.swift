//
//  FontCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 10/02/21.
//

import UIKit

class FontCell: UITableViewCell {

    @IBOutlet weak var FontLabel: UILabel!
    @IBOutlet weak var FontImage: UIImageView!
    @IBOutlet weak var FontLineVu: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.FontImage! , colorVu: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
