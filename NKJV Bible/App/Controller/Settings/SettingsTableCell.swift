//
//  SettingsTableCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 11/02/21.
//

import UIKit

class SettingsTableCell: UITableViewCell {

    @IBOutlet var themeColor: UIView!
    @IBOutlet var FontStyle: UILabel!
    @IBOutlet var NotifiSwitch: UISwitch!
    @IBOutlet var NotifiTime: UILabel!
    
    @IBOutlet var NotifiMorningTime: UILabel!
    @IBOutlet var NotifiEveningTime: UILabel!
    @IBOutlet var NotifiNightTime: UILabel!
    
    @IBOutlet var Notifications: UILabel!
    @IBOutlet var NotificationTime: UILabel!
    @IBOutlet var FontType: UILabel!
    @IBOutlet var Theme: UILabel!
    @IBOutlet var Feedback: UILabel!
    @IBOutlet var AboutUs: UILabel!
    @IBOutlet var RateUs: UILabel!
    @IBOutlet var MoreApp: UILabel!
    @IBOutlet var Help: UILabel!
    @IBOutlet var Quiz: UILabel!
    
    @IBOutlet var Notification: UILabel!
    @IBOutlet var FontTheme: UILabel!
    @IBOutlet var AboutApp: UILabel!
    @IBOutlet var Support: UILabel!
    
    @IBOutlet var arrow1: UIImageView!
    @IBOutlet var arrow2: UIImageView!
    @IBOutlet var arrow3: UIImageView!
    
    
    
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}






class NotificationTableCell: UITableViewCell {
    
    @IBOutlet var NotifiMorningTime: UILabel!
    @IBOutlet var NotifiEveningTime: UILabel!
    @IBOutlet var NotifiNightTime: UILabel!
    @IBOutlet var NotifiQuizTime: UILabel!
    
    @IBOutlet var Shift1Switch: UISwitch!
    @IBOutlet var Shift2Switch: UISwitch!
    @IBOutlet var Shift3Switch: UISwitch!
    @IBOutlet var Shift4Switch: UISwitch!
    @IBOutlet var FAQ: UIButton!
    
    
            
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}



