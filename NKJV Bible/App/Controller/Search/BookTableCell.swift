//
//  BookTableCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 17/12/22.
//

import UIKit

class BookTableCell: UITableViewCell {
    
    @IBOutlet weak var BookLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}



class TestamentTableCell: UITableViewCell {
    
    @IBOutlet weak var TestamentLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
