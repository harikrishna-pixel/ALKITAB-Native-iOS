//
//  QuizSettingsTableCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 23/02/23.
//

import UIKit

class QuizSettingsTableCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var MusicSwitch: UISwitch!
    @IBOutlet var ToneSwitch: UISwitch!
    @IBOutlet var TimerSwitch: UISwitch!
    @IBOutlet var VibrationSwitch: UISwitch!
    @IBOutlet var QuestionCount: UITextField!
    @IBOutlet var FaQBtn: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.QuestionCount.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
