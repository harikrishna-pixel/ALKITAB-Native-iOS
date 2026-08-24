//
//  RateUsViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 29/05/23.
//

import UIKit
import StoreKit

class RateUsViewController: UIViewController {

    @IBOutlet weak var rateTitle: UILabel!
    @IBOutlet weak var More: UILabel!
    @IBOutlet weak var Less: UILabel!
    @IBOutlet weak var RateBtn: UIButton!
    @IBOutlet weak var Logo: UIImageView!
    

    @IBOutlet weak var RateBtn1: UIButton!
    @IBOutlet weak var RateBtn2: UIButton!
    @IBOutlet weak var RateBtn3: UIButton!
    @IBOutlet weak var RateBtn4: UIButton!
    @IBOutlet weak var RateBtn5: UIButton!
    
    
    var RateContent = "Rate Your Happiness, \nLet it Shine Bright!"
    var RateStarCount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.rateTitle.text = RateContent
        self.RateBtn.backgroundColor = .darkGray
                
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.Logo!, colorVu: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
        
        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func StarRating(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
                
        self.RateBtn1.setImage(UIImage(named: (button.tag >= 1 ? "star-1":"star")), for: .normal)
        self.RateBtn2.setImage(UIImage(named: (button.tag >= 2 ? "star-1":"star")), for: .normal)
        self.RateBtn3.setImage(UIImage(named: (button.tag >= 3 ? "star-1":"star")), for: .normal)
        self.RateBtn4.setImage(UIImage(named: (button.tag >= 4 ? "star-1":"star")), for: .normal)
        self.RateBtn5.setImage(UIImage(named: (button.tag >= 5 ? "star-1":"star")), for: .normal)

        
        self.RateBtn.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        self.RateStarCount = button.tag
        self.moreLess(button.tag)
        
        if button.tag <= 3 {
            UserDefaults.standard.setValue(Date.Week.string(format: "dd-MM-yyyy"), forKey: "RateAction")
        } else {
            UserDefaults.standard.setValue("RateNotShared", forKey: "Rate5")
        }
        
    }
    
    
    func moreLess(_ tagNum:Int) {
        
        self.More.textColor = (tagNum < 4 ? .gray:.black)
        self.Less.textColor = (tagNum > 3 ? .gray:.black)
        self.rateTitle.text = (tagNum < 4 ? "Share your thoughts!!":RateContent)
        self.RateBtn.setTitle((tagNum < 4 ? "Feedback":"Rate Us"), for: .normal)
    }
    
    @IBAction func RateAction(_ sender: Any) {
        if RateStarCount > 0 {
            // BUG FIX 5 (OFFLINE FEEDBACK & RATE): Check internet before both feedback and rate
            
            if self.RateBtn.titleLabel?.text == "Feedback" {
                // Feedback requires internet
                if NetworkManager.sharedInstance.isConnectedToInternet() {
                    App_Protocol.SettingDelegate?.CallRate(Rate: "Feedback")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                }
            } else {
                // NEW FIX: Rate Us also requires internet check
                if NetworkManager.sharedInstance.isConnectedToInternet() {
                    App_Protocol.SettingDelegate?.CallRate(Rate: (self.RateBtn.titleLabel?.text)!)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                }
            }
        }
    }
     
    
    @IBAction func CloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
}

