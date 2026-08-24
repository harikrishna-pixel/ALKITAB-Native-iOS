//
//  ClosedCard.swift
//  General Quiz
//
//  Created by ajayprasanth on 05/05/23.
//

import UIKit



class ClosedCard: UICollectionViewCell {
    @IBOutlet weak var offerCard: UIImageView!
    
    @IBOutlet weak var ImageFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var ImageFramewidth: NSLayoutConstraint!
    
    @IBOutlet weak var ViewFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var ViewFramewidth: NSLayoutConstraint!
    
    @IBOutlet weak var SkipFrame: UIView!
    @IBOutlet weak var TimerLbl: UILabel!
    @IBOutlet weak var SkipBtn: UIButton!
    @IBOutlet weak var orlbl: UILabel!
    @IBOutlet weak var SkipBtnFrame: UIView!
    
    
    
    var timer: Timer?
    var totalTime = 14
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
//        if UserDefaults.standard.string(forKey: "CardAdTime") ?? "" != "" {
//            self.timer?.invalidate()
//            self.timer = nil
//            
//            totalTime = TimeConvert.sharedInstance.ConvertSeconds(toDate: UserDefaults.standard.string(forKey: "CardAdTime") ?? Date().string(format: "MM/dd/yy HH:mm:ss"))
//            print("totalTime :",totalTime)
//
//
//            
//            if totalTime > 0 {
//                SkipFrame.isHidden = false
//                self.startOtpTimer()
//            } else {
//                SkipFrame.isHidden = true
//                if UserDefaults.standard.integer(forKey: "CardCount") == 3 {
//                    UserDefaults.standard.setValue(0, forKey: "CardCount")
//                }
//            }
//
//        }
    }

    
   
    
    func startOtpTimer() {
//        self.TimerTxt.text = "15"
           self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
       }

    @objc func updateTimer() {
       
        self.MarkAsReadAction(WaitTime: self.timeFormatted(self.totalTime))
           if totalTime != 0 {
               totalTime -= 1  // decrease counter timer
           } else {
               if let timer = self.timer {
                   self.SkipFrame.isHidden = true
                   if UserDefaults.standard.integer(forKey: "CardCount") == 3 {
                       UserDefaults.standard.setValue(0, forKey: "CardCount")
                   }
                   self.timer?.invalidate()
                   self.timer = nil
               }
           }
       }
    func timeFormatted(_ totalSeconds: Int) -> String {
             let seconds: Int = totalSeconds % 60
             let minutes: Int = (totalSeconds / 60) % 60
             let hours: Int = ((totalSeconds / 60)/60) % 60
             return String(format: "%02d:%02d:%02d",hours, minutes, seconds)
         }


    
    
    
    
    func MarkAsReadAction(WaitTime:String) {
        self.TimerLbl.text = "wait \(WaitTime)"
    }
    
    
    
    
    
}

