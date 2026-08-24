//
//  QuizWalletTableCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 28/02/23.
//

import UIKit

class QuizWalletTableCell: UITableViewCell {

    @IBOutlet var RemoveAd: UIView!
    @IBOutlet var RemoveValue: UILabel!
    @IBOutlet var walletVu: UIView!
    @IBOutlet var DailyVu: UIView!
    @IBOutlet var RateUsVu: UIView!
    @IBOutlet weak var TimerTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
