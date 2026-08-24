//
//  DropDownCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 17/02/21.
//

import UIKit

class DropDownCell: UITableViewCell {

    @IBOutlet weak var ListItem: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
