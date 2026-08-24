//
//  ScoreBoardVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 21/03/23.
//

import UIKit

class ScoreBoardVC: UIViewController {

    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    
    @IBOutlet weak var scoreVu: UIView!
    @IBOutlet weak var Slogan: UILabel!
    @IBOutlet weak var ClaimMoney: UIButton!
    @IBOutlet weak var ClaimMoneyimg: UIImageView!
    
    @IBOutlet weak var ScoreLbl: UILabel!
    @IBOutlet weak var ScoreCoins: UILabel!
    @IBOutlet weak var WalletMoney: UILabel!
    @IBOutlet weak var ViewAnswer: UIView!
    

    let Themecolor:UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    var AnswerKeyWords:Dictionary<Int,Array<String>> = [:]
    var Score:Int = 0
    var LifeLine:Int = 0
    var QuestionCount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        self.ScoreLbl.text = "Score \(Score)/\(QuestionCount)"

        
        self.ClaimMoney.backgroundColor = Themecolor
        self.ViewAnswer.backgroundColor = Themecolor
        
        
        self.ScoreCoins.text = "X \(Score)"
        
        
        if self.Score == 0 {
            self.ScoreCoins.isHidden  = true
            self.ClaimMoney.isHidden = true
            self.ClaimMoneyimg.isHidden = true
        }
        
        
        self.Slogan.text = resultTxt(correct: Score)
        
        
        self.scoreVu.ViewBorder(color: Themecolor, radius: 20)
        self.WalletMoney.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        
        if PaymentHistory.sharedInstance.paymentInfo() {
            AdmobManager.shared.RewardAd = ""
            AdmobManager.shared.IronSource_Interstitial_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!)
        }
        
        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func Claim_Action(_ sender: Any) {
        self.ClaimMoney.backgroundColor = UIColor.gray
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "WalletMoney")+(Score), forKey: "WalletMoney")
        QuizClickSound.shared.CoinCollectSound()
        self.WalletMoney.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        self.ClaimMoney.isEnabled = false
        self.view.makeToast("Coins claimed successfully!", duration: 2.0, position: .bottom)
    }
    
    
    
    @IBAction func ViewAnswer_Action(_ sender: Any) {
        
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizAnswersVC") as! QuizAnswersVC
        vc.ShowResult = "Show"
        vc.AnswerKeyWords = self.AnswerKeyWords
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func Settings_Action(_ sender: Any) {
            
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizSettingVC") as! QuizSettingVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        
        @IBAction func Wallet_Action(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
          }
    
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popToViewController(ofClass: SelectionViewController.self)
    }
    
   
    
    
    
    func resultTxt(correct:Int) -> String {
        var Title = ""
        if correct <= 3 {
            Title = "Need Improvement"
            
        } else if correct == 4 {
            Title = "Try even better"
        } else if correct > 4 && correct <= 6 {
            Title = "Well- played!"
        }
        else if correct >= 7 &&  correct <= 9 {
            Title = "Great job!"
        } else {
            Title = "Excellent!"
        }
        return Title
    }
    
    

}
