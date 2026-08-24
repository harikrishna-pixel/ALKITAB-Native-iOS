//
//  BookTableViewCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 09/12/22.
//

import UIKit
import CircleProgressView
class BookTableViewCell: UITableViewCell {

    @IBOutlet weak var BookTxt: UILabel!
    @IBOutlet weak var BookCount: UILabel!
    @IBOutlet weak var ProgressValue: UILabel!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.circleProgressView.trackFillColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
