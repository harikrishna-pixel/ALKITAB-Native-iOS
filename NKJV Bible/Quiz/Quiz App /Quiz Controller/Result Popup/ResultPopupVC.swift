//
//  ResultPopupVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 03/03/23.
//

import UIKit

class ResultPopupVC: UIViewController, ResultProtocol {
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    @IBOutlet weak var Question_Count: UILabel!
    @IBOutlet weak var Answe_Status: UILabel!
    
    @IBOutlet weak var AnswerView: UIView!
    @IBOutlet weak var MainView: UIView!
    
    @IBOutlet weak var AnswerLbl: UILabel!
    @IBOutlet weak var QuestionLbl: UILabel!
    @IBOutlet weak var CloseBtn: UIButton!
    
    @IBOutlet weak var HeartImg: UIView!
    @IBOutlet weak var TryBtn: UIButton!
    @IBOutlet weak var ShowBtn: UIButton!
    @IBOutlet weak var NextLbl: UILabel!
    
    @IBOutlet weak var TryVu: UIView!
    @IBOutlet weak var ShowVu: UIView!
    @IBOutlet weak var NextVu: UIView!
    
//    @IBOutlet weak var OK: UIButton!
    @IBOutlet weak var ShowLbl: UILabel!
    
    @IBOutlet weak var life1: UIImageView!
    @IBOutlet weak var life2: UIImageView!
    @IBOutlet weak var life3: UIImageView!
    
    @IBOutlet weak var Coins: UILabel!
    @IBOutlet weak var progresConstrain: NSLayoutConstraint!
    @IBOutlet weak var ProgressBar: UIView!
    @IBOutlet weak var ProgressInnerBar: UIView!
    
    @IBOutlet weak var LifeView: UIView!
    @IBOutlet weak var TryAgainPopup: UIView!
    @IBOutlet weak var ContinueBtn: UIButton!
    @IBOutlet weak var TryAgainPopupLbl: UILabel!
    @IBOutlet weak var AnsLbl: UILabel!
    
    
    @IBOutlet weak var showAnswerVuHeight: NSLayoutConstraint!
    
    
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    var AnswerKeyWords:Dictionary<Int,Array<String>> = [:]
    
    var AnsCount:Int = 0
    var QuesCount:Int = 0
    var AnsStatus:Bool = false
    
    var AnswerStr:String = ""
    var QuestionStr:String = ""
    var CorrectAnswers:[String] = []
    var Blank:[String] = []
    var WrongAnswer:[String] = []
    var LifeLine:Int = 0
    
    var Score:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Question_Count.text =  "Question \(AnsCount)/\(QuesCount)"
        self.Answe_Status.text = (AnsStatus ? "Correct!":"Wrong!")
        
        
        if AnsStatus {
            QuizClickSound.shared.CorrectSound()
        } else {
            QuizClickSound.shared.WrongSound()
        }
        
        QuizProtocol.ResultProtocoldelegate = self
    
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        self.Answe_Status.textColor = Themecolor
        
        
        self.HeartImg.isHidden = AnsStatus
        self.TryVu.isHidden = AnsStatus
        self.ShowVu.isHidden = AnsStatus
        
        self.life1.image = UIImage(named: (LifeLine >= 1 ? "heart.png":"FadeHeart.png"))
        self.life2.image = UIImage(named: (LifeLine >= 2 ? "heart.png":"FadeHeart.png"))
        self.life3.image = UIImage(named: (LifeLine >= 3 ? "heart.png":"FadeHeart.png"))
        
        self.LifeView.layer.cornerRadius = self.LifeView.frame.height/2
        self.LifeView.layer.borderWidth = 1
        self.LifeView.layer.borderColor = Themecolor.cgColor
        
        self.ShowLbl.text = "\(ShowAnswerCoins)"
        
        self.Coins.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        self.ContinueBtn.backgroundColor = Themecolor
        self.TryAgainPopupLbl.text =  "Would you like to Try Again by spending \(tryAgainCoins) coins?"
        
        
        for i in 0 ..< Blank.count {
                        
            if i+1 <= CorrectAnswers.count {
                if Blank[i] != CorrectAnswers[i] {
                    WrongAnswer.append(Blank[i])
                }
            }
        }
        
        
        
        if LifeLine == 0 || AnsCount == QuesCount {
            self.NextLbl.text = "End Round"
        } else {
            self.NextLbl.text = "Next Question"
        }
        
        self.CloseBtn.backgroundColor = Themecolor
        self.CloseBtn.layer.cornerRadius = 17
        self.CloseBtn.layer.masksToBounds = true
        
        self.ProgressBar.layer.borderColor = Themecolor.cgColor
        self.ProgressBar.layer.borderWidth = 1
        self.ProgressInnerBar.backgroundColor = Themecolor
        
        self.AnsLbl.textColor = Themecolor
        
        self.TryVu.backgroundColor = Themecolor
        self.ShowVu.backgroundColor = Themecolor
        self.NextVu.backgroundColor = Themecolor
        
        
        self.TryBtn.isHidden = AnsStatus
        self.HeartImg.isHidden = AnsStatus
        self.ShowBtn.isHidden = AnsStatus
        UIFont.systemFont(ofSize: 15, weight: .regular)
        
        self.AnswerLbl.attributedText = attributedTextBold(withString: self.AnswerStr, boldString: self.AnswerStr, font: UIFont.systemFont(ofSize: 15, weight: .regular), underlineValue: CorrectAnswers, Wrong: [])
        
        self.QuestionLbl.attributedText = attributedTextBold(withString: self.QuestionStr, boldString: self.QuestionStr, font: UIFont.systemFont(ofSize: 15, weight: .regular), underlineValue: Blank, Wrong: WrongAnswer)
    
        DispatchQueue.main.async {
            self.progresConstrain.constant = CGFloat(self.QuesCount-self.AnsCount)*(self.ProgressBar.frame.width/CGFloat(self.QuesCount))
        }
        
        self.showAnswerVuHeight.constant = CGFloat(AnswerLbl.maxNumberOfLines+160)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.Coins.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
    }
    
    
    
    
    @IBAction func TryAgain_Action(_ sender: Any) {
        
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            AdmobManager.shared.IronSource_Reward_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!, RewardAd: "Tryagain")
            
        } else {
            self.TryAgainPopup.isHidden = false
            
//            if UserDefaults.standard.integer(forKey: "WalletMoney") >= tryAgainCoins {
//                UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")-tryAgainCoins, forKey: "WalletMoney")
//                self.Coins.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
//                QuizProtocol.QuizMaindelegate?.tryAgain()
//                self.navigationController?.popViewController(animated: true)
//            } else {
//                self.Wallet()
//            }
        }
        
    }
    
    
    func AdNotAvailable() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            self.TryAgainPopup.isHidden = false
        }
    }
    
    
    @IBAction func CoinCollect_Action(_ sender: Any) {
        if UserDefaults.standard.integer(forKey: "WalletMoney") >= tryAgainCoins {
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")-tryAgainCoins, forKey: "WalletMoney")
            self.Coins.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
            QuizProtocol.QuizMaindelegate?.tryAgain()
            self.TryAgainPopup.isHidden = true
            self.navigationController?.popViewController(animated: true)
        } else {
            self.Wallet()
        }
    }
    
    
    @IBAction func AlertCancel_Action(_ sender: Any) {
        self.TryAgainPopup.isHidden = true
    }
    
    
    
    
    
    
    func NavigateBack() {
        QuizProtocol.QuizMaindelegate?.tryAgain()
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ShowAnswer_Action(_ sender: Any) {
        if ShowAnswerCoins <= Int(UserDefaults.standard.integer(forKey: "WalletMoney")) {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "WalletMoney")-ShowAnswerCoins, forKey: "WalletMoney")
            self.Coins.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
            self.MainView.isHidden = false
        } else {
           self.Wallet()
       }
    }
    
    
    
    @IBAction func ShowAnswerClose_Action(_ sender: Any) {
        self.MainView.isHidden = true
    }
    
    
    @IBAction func Next_Action(_ sender: Any) {
        
        if self.NextLbl.text == "End Round" {
            
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "ScoreBoardVC") as! ScoreBoardVC
            vc.Score = self.Score
            vc.LifeLine = self.LifeLine
            vc.AnswerKeyWords = self.AnswerKeyWords
            vc.QuestionCount = self.QuesCount
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
            QuizProtocol.QuizMaindelegate?.nextCall_Action()
        }
        
        
        
    }
    
    
    @IBAction func Settings_Action(_ sender: Any) {
        
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizSettingVC") as! QuizSettingVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    @IBAction func Wallet_Action(_ sender: Any) {
        self.Wallet()
    }
    
    
    func Wallet() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    func attributedTextBold(withString string: String, boldString: String, font: UIFont, underlineValue:[String], Wrong:[String]) -> NSAttributedString {
        
      let attributedString = NSMutableAttributedString(string: string)
        
      let FontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
      let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6.0
         
      let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
        attributedString.addAttributes(FontAttribute, range: range)
                
        
        for item in underlineValue {
            let range1 = (string as NSString).range(of: item, options: .caseInsensitive)
            attributedString.addAttributes(FontAttribute, range: range1)
            
            let TextBold: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)]
            var ForegroundColor: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: QuizGreen]
             
            if Wrong.contains(item) {
                ForegroundColor = [NSAttributedString.Key.foregroundColor: UIColor.red]
            }
            
            
            attributedString.addAttributes(ForegroundColor, range: range1)
            attributedString.addAttributes(TextBold, range: range1)
        }
                

                
      return attributedString
    }
    
    

}
