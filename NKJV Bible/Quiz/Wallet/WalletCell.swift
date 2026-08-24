//
//  WalletCell.swift
//  General Quiz
//
//  Created by ajayprasanth on 19/05/23.
//

import UIKit

class WalletCell: UITableViewCell {

    @IBOutlet weak var coinTxt: UILabel!
    @IBOutlet weak var PayBtn: UIButton!
    @IBOutlet weak var CoinPayBtn: UIButton!
    @IBOutlet weak var WatchAd: UIButton!
    @IBOutlet weak var ScratchBtn: UIButton!
    @IBOutlet weak var OfferImg: UIImageView!
    @IBOutlet weak var RewardCoinLbl: UILabel!
    @IBOutlet var LifeTimeIndicator: UIActivityIndicatorView!
    @IBOutlet var PayList: UIActivityIndicatorView!
    
    
    
    
    @IBOutlet weak var WatchAdVu: UIView!
    @IBOutlet weak var GiftcardVu: UIView!
    @IBOutlet weak var WalletMoneyVu: UIView!
    

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}




class TimerCell: UITableViewCell {

    @IBOutlet weak var AdTime: UIButton!
    @IBOutlet weak var FreeCoinLbl: UILabel!
    
    
    @IBOutlet weak var FreeCoinsVu: UIView!
    
    
    var timer: Timer?
    var totalTime = 14
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        if UserDefaults.standard.string(forKey: "FreeAds") ?? "" != "" {
            self.timer?.invalidate()
            self.timer = nil
            
            totalTime = TimeConvert.sharedInstance.ConvertSeconds(toDate: UserDefaults.standard.string(forKey: "FreeAds") ?? Date().string(format: "MM/dd/yy HH:mm:ss"))
            
            self.startOtpTimer()
        }
                 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func startOtpTimer() {
//        self.TimerTxt.text = "15"
           self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
       }

    @objc func updateTimer() {
       
        self.MarkAsReadAction(WaitTime: self.timeFormatted(self.totalTime))
           if totalTime != 0 {
               totalTime -= 1  // decrease counter timer
           } else {
               if let timer = self.timer {
                   self.timer?.invalidate()
                   self.timer = nil
               }
           }
       }
    func timeFormatted(_ totalSeconds: Int) -> String {
             let seconds: Int = totalSeconds % 60
             let minutes: Int = (totalSeconds / 60) % 60
             return String(format: "%02d:%02d", minutes, seconds)
         }

    
    func MarkAsReadAction(WaitTime:String) {
         
        totalTime = TimeConvert.sharedInstance.ConvertSeconds(toDate: UserDefaults.standard.string(forKey: "FreeAds") ?? Date().string(format: "MM/dd/yy HH:mm:ss"))
        
        if totalTime >= 1 {
            self.AdTime.setTitle(WaitTime, for: .normal)
        } else {
            self.AdTime.setTitle("Claim", for: .normal)
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    
}



