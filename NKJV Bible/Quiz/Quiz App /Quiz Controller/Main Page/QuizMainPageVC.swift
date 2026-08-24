//
//  QuizMainPageVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 20/02/23.
//

import UIKit

class QuizMainPageVC: UIViewController, QuizMainPagePC {

     

//    @IBOutlet weak var leveltxt: UILabel!
    @IBOutlet weak var LifeView: UIView!
    @IBOutlet weak var ProgressBar: UIView!
    @IBOutlet weak var ProgressInnerBar: UIView!
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
        
//    @IBOutlet weak var TimerLbl: UILabel!
//    @IBOutlet weak var QuestionTxt: UILabel!
    @IBOutlet weak var QuestionVu: UIView!
    @IBOutlet weak var QuestionLbl: UILabel!
    
    @IBOutlet weak var Nextview: UIView!
    @IBOutlet weak var Previousview: UIView!
    @IBOutlet weak var AdsView: UIView!
    @IBOutlet weak var WalletMoney: UILabel!
    
    @IBOutlet weak var FreeCoinFrame: UIView!
    @IBOutlet weak var proceedLbl: UIView!
    
    @IBOutlet weak var FreeCoinVu: UIView!
    @IBOutlet weak var halfVu: UIView!
    @IBOutlet weak var HintVu: UIView!
    @IBOutlet weak var CardVu: UIView!
    
    @IBOutlet weak var halfBlockVu: UIView!
    @IBOutlet weak var WatchAdlbl: UILabel!

    
    @IBOutlet weak var FreeTxt: UILabel!
    @IBOutlet weak var Hinttxt: UILabel!
    
    @IBOutlet weak var PoceedBtn: UIButton!
    @IBOutlet weak var HalfBtn:UIButton!
    @IBOutlet weak var HintBtn:UIButton!
    
    
        
    
    @IBOutlet weak var life1: UIImageView!
    @IBOutlet weak var life2: UIImageView!
    @IBOutlet weak var life3: UIImageView!
    
    
    @IBOutlet weak var HalfLbl: UILabel!
    @IBOutlet weak var HintLbl: UILabel!
    
    
    @IBOutlet weak var AnswerLbl: UILabel!
    @IBOutlet weak var CloseBtn: UIButton!
    @IBOutlet weak var TimerTxt: UILabel!
    @IBOutlet weak var MainView: UIView!
    
    @IBOutlet var QuizAnswerCV: UICollectionView!
    @IBOutlet weak var progresConstrain: NSLayoutConstraint!
    
    
    @IBOutlet weak var QuestionTxt: UITextView!
    @IBOutlet weak var FreeCoinOk: UIButton!
    
    @IBOutlet weak var PayNote: UIView!

    
    @IBOutlet weak var Notetitle: UILabel!
    @IBOutlet weak var GotBtn: UIButton!
    
    
    
    var questionShow:String = ""
    var ResultCorrect:Int = 0
    var ResultWrong:Int = 0
    var Hint:Int = 0
    var SelectedVc:Bool = false
    
    var CorrectAnswers:[String] = []
    var Answer:[String] = []
    var AnswerKeyWords:Dictionary<Int,Array<String>> = [:]
    var KeyWords:Dictionary<Int,Array<String>> = [:]
    var KeyWord:[String] = []
    var BlankList:[String] = []
    var BookName:String = ""
    var Chapter:Int = 0
    var QuestionList:[String] = []
    var CurrentQuestion:Int = 1
    var level:String = ""
    var NumberOFDash:Int = 0
    var LifeLine:Int = 3
    var RawQuestionsList:[String] = []
    
    
    
    var timer: Timer?
    var totalTime = 14
    
    var Score:Int = 0
    
    var QKeyWordsAry:[String] = []
    var QAnswerAry:[String] = []
    var QAnswerKeyWords:[String] = []
    
    
    
    var AnswerKewords:[String] = []
    var Blank:[String] = []
    var AnswerBlank:[String] = []
    
    var QuizAnswer:QuizAnswerCC!
    
    
    
    var MusicName:[String] = ["The Thinking Time"]
    var recard:Int = 0
    
    
    let Themecolor:UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progresConstrain.constant = 1000
        QuizProtocol.QuizMaindelegate = self
        self.QuestionTxt.isEditable = false
        
        self.proceedLbl.layer.cornerRadius = self.proceedLbl.frame.height/2
        self.proceedLbl.layer.masksToBounds = true
        
        DispatchQueue.main.async {
            self.initQuiz()
        }
        
        self.HintLbl.addInterlineSpacing(spacingValue: 1.5)
         
    }
    
    
    
    
    
    func initQuiz() {
        
        self.Score = 0
        self.HalfLbl.text = "\(HalfCoin)"
        self.HintLbl.text = "\(HintCoins)"
        
        self.CorrectAnswers = []
        self.AnswerKeyWords = [:]
        self.KeyWords = [:]
        self.KeyWord = []
        self.BlankList = []
        self.QuestionList = []
        self.RawQuestionsList = []
        self.QuestionTxt.text = ""
        self.QuestionLbl.text = "Question 1/10"
        
        self.CurrentQuestion = 1
        
        
        self.life1.image = UIImage(named: "heart.png")
        self.life2.image = UIImage(named: "heart.png")
        self.life3.image = UIImage(named: "heart.png")

        
        self.CloseBtn.backgroundColor = Themecolor
        self.CloseBtn.layer.cornerRadius = 17
        self.CloseBtn.layer.masksToBounds = true
        
    
        
        if PaymentHistory.sharedInstance.paymentInfo() {
            
            DispatchQueue.main.async {
                IronSourceBanner.sharedInstance.ViewControl = self
                IronSourceBanner.sharedInstance.IronSource_Banner_AdLoad(bannerWidth: Int(ScreenWidth), bannerHeight: 70)
             }
            
        } else {
            self.AdsView.isHidden = true
        }
                 
        MusicBgFile.sharedInstance.playSound()
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        self.Notetitle.textColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        self.GotBtn.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        
        self.PoceedBtn.backgroundColor = Themecolor
        self.PoceedBtn.layer.cornerRadius = self.PoceedBtn.frame.height/2
        self.PoceedBtn.isHidden = true
        
        
        
        self.FreeCoinVu.backgroundColor = Themecolor
        self.halfVu.backgroundColor = Themecolor
        self.HintVu.backgroundColor = Themecolor
        self.CardVu.backgroundColor = Themecolor
        self.FreeCoinOk.backgroundColor = Themecolor
        self.FreeTxt.textColor = Themecolor
        self.Hinttxt.textColor = Themecolor
        
        self.WatchAdlbl.text = "Watch an Ad to get \(rewardCoins) free coins "
        
        self.LifeView.layer.cornerRadius = self.LifeView.frame.height/2
        self.LifeView.layer.borderWidth = 1
        self.LifeView.layer.borderColor = Themecolor.cgColor
        
        self.halfVu.layer.masksToBounds = true
        self.Nextview.backgroundColor = Themecolor
        self.Previousview.backgroundColor = Themecolor
        
        
        var AudioBibleList = BibleContent.sharedInstance.AudioBibleList(selecterBookName: BookName , selectedId: Chapter-1)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
            AudioBibleList.shuffle()
            
            let QuestionCount =  (UserDefaults.standard.integer(forKey: "QuestionList") <= AudioBibleList.count  ? UserDefaults.standard.integer(forKey: "QuestionList"):AudioBibleList.count)
            
            
            for i in 0 ..< AudioBibleList.count {
                if  self.QuestionList.count < QuestionCount && AudioBibleList[i].components(separatedBy: " ").count >= 12 {
                    self.QuestionList.append(" \(AudioBibleList[i]) ")
                }
            }
        
            
            for i in 1 ..< self.QuestionList.count+1 {
                self.AnswerKeyWords[i] = []
            }
            
            
            
            self.ProgressBar.layer.borderColor = self.Themecolor.cgColor
            self.ProgressBar.layer.borderWidth = 1
            self.ProgressInnerBar.backgroundColor = self.Themecolor
                    
            self.QuestionVu.ViewShadow(10, color: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
    
            self.progresConstrain.constant = CGFloat(self.QuestionList.count-self.CurrentQuestion)*(self.ProgressBar.frame.width/CGFloat(self.QuestionList.count))
            
        }
    }
    

    
      private func startOtpTimer() {
          self.MainView.isHidden = false
          self.TimerTxt.text = "00:15"
             self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
         }
     
     @objc func updateTimer() {
         
             self.TimerTxt.text = self.timeFormatted(self.totalTime)
             if totalTime != 0 {
                 totalTime -= 1  // decrease counter timer
             } else {
                 if let timer = self.timer {
                     timer.invalidate()
                     self.timer = nil
                     self.MainView.isHidden = true
                 }
             }
         }
     func timeFormatted(_ totalSeconds: Int) -> String {
         let seconds: Int = totalSeconds % 60
         let minutes: Int = (totalSeconds / 60) % 60
         return String(format: "%02d:%02d", minutes, seconds)
     }

    
    func UpdatePay() {
        self.WalletMoney.text =  "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.WalletMoney.text =  "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
    }
    

    override func viewDidAppear(_ animated: Bool) {
        UserDefaults.standard.set(Date().string(format: "dd-MM-yy"), forKey: "LastAnsweredDate")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            if UserDefaults.standard.bool(forKey: "MusicSwitch") {
                MusicBgFile.sharedInstance.player?.play()
            } else {
                MusicBgFile.sharedInstance.player?.stop()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            self.refreshQuestion(Number:self.CurrentQuestion)
            self.refreshAns()
            
            let comparedValue = self.Answer.filter () { self.Blank.contains($0) }
            if comparedValue.count >= 1 {
                self.PoceedBtn.isHidden = false
            } else {
                self.PoceedBtn.isHidden = true
            }
            
            if UserDefaults.standard.bool(forKey: "TimerSwitch") {
                DispatchQueue.main.async {
                    self.Previousview.isHidden = true
                }
            }
            
            if self.CurrentQuestion == 1 {
                self.halfBlockVu.isHidden = true
                self.LifeLine = 3
            }
        }
        
                
        
        if PaymentHistory.sharedInstance.paymentInfo() == false && UserDefaults.standard.bool(forKey: "PayNote") == false {
            self.PayNote.isHidden = false
        }
        
        
        
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
//        self.player?.stop() 
    }
    
    
    
    @IBAction func PayNote_OK(_ sender: Any) {
        UserDefaults.standard.setValue(true, forKey: "PayNote")
        self.PayNote.isHidden = true
    }
    
    
    


    
    func refreshAns() {
//        self.TimerLbl.text = "01:00"
        Answer = AnswerKeyWords[CurrentQuestion]!
        
        for item in Answer {
            if let range = self.questionShow.range(of:" ________ ") {
                self.questionShow = self.questionShow.replacingCharacters(in: range, with:item)
             }
        }
          
        self.QuestionTxt.attributedText = attributedTextBold(withString: self.questionShow, boldString: self.questionShow, font: UIFont.systemFont(ofSize: 17, weight: .regular), underlineValue: Answer)
            
        UIFont.systemFont(ofSize: 17, weight: .regular)
        
    }
    
    
    
    func refreshQuestion(Number:Int) {
        self.progresConstrain.constant = CGFloat(self.QuestionList.count-CurrentQuestion)*(self.ProgressBar.frame.width/CGFloat(self.QuestionList.count))

        self.QuestionLbl.text = "Question \(Number)/\(self.QuestionList.count)"
        self.Blank.removeAll()
        
        var sometext = self.QuestionList[Number-1].components(separatedBy: " ").filter { $0 != "" }.filter { $0 != " "}

        self.KeyWord.removeAll()
        self.KeyWord = sometext
        sometext.shuffle()
        var ans:[String] = []
        
        
        func validateGenericString(_ string: String) -> Bool {
            return string.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil
        }
        
        AnswerKewords.removeAll()
        for item in sometext {
            
//            if validateGenericString(item) {
                if AnswerKewords.contains(where: {$0.caseInsensitiveCompare(" \(item) ") == .orderedSame}) || AnswerKewords.contains(" \(item) ") {
                    ans.append(" \(item) ")
                } else {
                    AnswerKewords.append(" \(item) ")
                }
//            }
        }
        
    
        for item in ans {
            AnswerKewords = AnswerKewords.filter(){$0 != item}
            AnswerKewords = AnswerKewords.filter(){$0 != item.capitalized}
            AnswerKewords = AnswerKewords.filter(){$0 != item.lowercased()}
        }
        
        
        
        if !KeyWords.keys.contains(CurrentQuestion) {

            for i in 0 ..< AnswerKewords.count {
                if Blank.count == Number_of_Dash() {
                    break
                } else {
                    Blank.append(AnswerKewords[i])
                }
            }
            KeyWords[CurrentQuestion] = Blank
        } else {
            Blank = KeyWords[CurrentQuestion]!
        }
        
        
        self.questionShow = QuestionList[Number-1]
        
        if  !RawQuestionsList.contains(QuestionList[Number-1]) {
            RawQuestionsList.append(QuestionList[Number-1])
        }
        
        
        for item in Blank {
            self.questionShow = self.questionShow.replacingOccurrences(of: item, with: " ________ ")
        }
        
        
        if !BlankList.contains(self.questionShow) {
            BlankList.append(self.questionShow)
        }
        
        
        self.QuestionTxt.attributedText = attributedTextBold(withString: self.questionShow, boldString: self.questionShow, font: UIFont.systemFont(ofSize: 17.0), underlineValue: Blank)
        self.QuizAnswerCV.reloadData()
        
        
        CorrectAnswers.removeAll()
        for item in self.KeyWord {
            if Blank.contains(" \(item) ") {
                CorrectAnswers.append(" \(item) ")
            }
        }
    }
    
    
    
    
    func Number_of_Dash() -> Int {

        
        
        switch level {
        case "Easy":
            
            if level == "Easy" && AnswerKewords.count > 2 {
                NumberOFDash = 2
            }
            
        case "Medium":
            
            if level == "Medium" && AnswerKewords.count > 4 {
                NumberOFDash = 4
            } else {
                NumberOFDash = 2
            }
                        
        case "Hard":
            
            if level == "Hard" && AnswerKewords.count > 6 {
                NumberOFDash = 6
            } else {
                NumberOFDash = 4
            }
            
        default:
            
          break
        }
        
        return NumberOFDash
    }
    
    
    
    
    
    @IBAction func Back(_ sender: Any) {
        let otherAlert = UIAlertController(title: "Do you want to give up?", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        let printSomething = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { _ in
            
            MusicBgFile.sharedInstance.player?.stop()
            
            if PaymentHistory.sharedInstance.paymentInfo() {
                AdmobManager.shared.IronSource_Interstitial_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!)
            }
            
            if var viewControllers = self.navigationController?.viewControllers
            {
                for controller in viewControllers
                {
                    if controller is SelectionViewController {
                        self.SelectedVc = true
                    }
                }
            }
            
            DispatchQueue.main.async {
                if self.SelectedVc {
                    self.navigationController?.popToViewController(ofClass: SelectionViewController.self)
                } else {
                    self.navigationController?.popToViewController(ofClass: ReaderViewController.self)
                }
            }
  
            
           }
        let dismiss = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil)

           otherAlert.addAction(printSomething)
           otherAlert.addAction(dismiss)

        self.present(otherAlert, animated: true, completion: nil)
    }
    
    
    
    
    func AdNotAvailable() {
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
//             self.view.makeToast("Ad not Available", duration: 2.0, position: .center)
         }
     }
     func CollectCoin() {
         self.view.makeToast("Coins added to your wallet", duration: 2.0, position: .center)
         
         UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+rewardCoins, forKey: "WalletMoney")
         self.WalletMoney.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
     }
    
    
    
    @IBAction func Yes_Action(_ sender: Any) {
        self.FreeCoinFrame.isHidden = true
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {

            AdmobManager.shared.IronSource_Reward_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!, RewardAd: "MainFreeCoins")
//
////            Coins added to your wallet
//            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+rewardCoins, forKey: "Coins")
//            self.WalletMoney.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
            
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
        
       }
    
    @IBAction func No_Action(_ sender: Any) {
        self.FreeCoinFrame.isHidden = true
       }
    

    @IBAction func Setting_Action(_ sender: Any) {
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizSettingVC") as! QuizSettingVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Wallet_Action(_ sender: Any) {
        self.CallWalllet()
    }
    
    @IBAction func FreeCoin_Action(_ sender: Any) {
        self.FreeCoinFrame.isHidden = false
    }
    
    
    @IBAction func CoinBtn_Action(_ sender: Any) {
        self.CallWalllet()
    }
    
    @IBAction func ShowAnswerClose_Action(_ sender: Any) {
        self.MainView.isHidden = true
        self.timer!.invalidate()
        self.timer = nil
    }
      
    
    
    
    func CallWalllet() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    @IBAction func Half_Action(_ sender: Any) {
        
        if UserDefaults.standard.integer(forKey: "WalletMoney") >= HalfCoin {
            halfBlockVu.isHidden = false

//        @IBOutlet weak var HintBlockVu: UIView!
            
            let filterAry = Answer.filter { $0 != " ________ " }
            if filterAry.count <= Blank.count-2 {

                Answer = Answer.filter { $0 != " ________ " }
                
                for i in 0 ..< NumberOFDash/2 {
                    
                    if Answer.count <= i {
                        Answer.append(CorrectAnswers[i])
                        
                        let range = self.questionShow.range(of:" ________ ")
                        self.questionShow = self.questionShow.replacingCharacters(in: range!, with:CorrectAnswers[i])
                    }
                    else if CorrectAnswers[i] != Answer[i] {
                        
                        self.questionShow =  self.questionShow.replacingOccurrences(of: Answer[i], with: CorrectAnswers[i])
                        Answer[i] = CorrectAnswers[i]
                        
                    } else if let range = self.questionShow.range(of:" ________ ") {
                        
                        if CorrectAnswers[i] == Answer[i] {
                            Answer.append(CorrectAnswers[i+1])
                            self.questionShow = self.questionShow.replacingCharacters(in: range, with:CorrectAnswers[i+1])
                        } else {
                            Answer.append(CorrectAnswers[i])
                            self.questionShow = self.questionShow.replacingCharacters(in: range, with:CorrectAnswers[i])
                        }
                    }
                }
                
                AnswerKeyWords[CurrentQuestion]! = Answer
                self.QuizAnswerCV.reloadData()
                
                self.QuestionTxt.attributedText = attributedTextBold(withString: self.questionShow, boldString: self.questionShow, font: UIFont.systemFont(ofSize: 17.0), underlineValue: Blank)
                
            }
            
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "WalletMoney")-HalfCoin, forKey: "WalletMoney")
            self.WalletMoney.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
                        
        } else {
            self.CallWalllet()
        }
        
        let comparedValue = Answer.filter () { Blank.contains($0) }
        if comparedValue.count >= 1 {
            self.PoceedBtn.isHidden = false
        } else {
            self.PoceedBtn.isHidden = true
        }
    }
    
    
    
    
    
    @IBAction func Card_Action(_ sender: Any) {
        
        MusicBgFile.sharedInstance.player?.stop()
        var adtime: String = UserDefaults.standard.string(forKey: "CardAdTime") ?? ""
        
        if CoreDataModel.sharedInstance.GetCardAry(entity: CDCardList).count == 0 {
            
            if UserDefaults.standard.integer(forKey: "CardCount") >= 2 {
                let now = Date()
                let HoursAgo = Calendar.current.date(byAdding: .hour, value: 12, to: now)
                UserDefaults.standard.setValue(HoursAgo!.string(format: "MM/dd/yy HH:mm:ss"), forKey: "CardAdTime")
            } else {
                let now = Date()
                let date = Calendar.current.date(byAdding: .minute, value: 30, to: now)
                UserDefaults.standard.setValue(date!.string(format: "MM/dd/yy HH:mm:ss"), forKey: "CardAdTime")
            }
        
            
            let vc1 = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "GiftCardVC") as! GiftCardVC
            
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "GiftCardClaimVC") as! GiftCardClaimVC
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc1, animated: true)
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "GiftCardVC") as! GiftCardVC
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
        
    @IBAction func Hint_Action(_ sender: Any) {
        
        if UserDefaults.standard.integer(forKey: "WalletMoney") >= HintCoins {
             
                UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "WalletMoney")-HintCoins, forKey: "WalletMoney")
//            self.view.makeToast(QuestionList[CurrentQuestion-1], duration: 3, position: .center)
            self.AnswerLbl.text = QuestionList[CurrentQuestion-1]
            
            self.totalTime = 14
            self.startOtpTimer()
                self.WalletMoney.text =  "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
            
        } else {
            self.CallWalllet()
        }
    }
    
    func tryAgain() {
                
        self.LifeLine = self.LifeLine+1
        halfBlockVu.isHidden = true
        self.life1.image = UIImage(named: (LifeLine >= 1 ? "heart.png":"FadeHeart.png"))
        self.life2.image = UIImage(named: (LifeLine >= 2 ? "heart.png":"FadeHeart.png"))
        self.life3.image = UIImage(named: (LifeLine >= 3 ? "heart.png":"FadeHeart.png"))
        
        self.AnswerKeyWords[CurrentQuestion]! = []
        self.Answer = []
        for item in Blank {
            self.questionShow = self.questionShow.replacingOccurrences(of: item, with: " ________ ")
        }
        self.QuestionTxt.attributedText = attributedTextBold(withString: self.questionShow, boldString: self.questionShow, font: UIFont.systemFont(ofSize: 17.0), underlineValue: Blank)
        self.QuizAnswerCV.reloadData()
        
    }
    
    
    
    @IBAction func NextAction(_ sender: Any) {

        if CurrentQuestion == 1 {
            UserDefaults.standard.setValue([], forKey: "KeyWords")
            UserDefaults.standard.setValue([], forKey: "AnswerAry")
            UserDefaults.standard.setValue([], forKey: "AnswerKeyWords")
            
            self.QAnswerAry = []
            self.QKeyWordsAry = []
            self.QAnswerKeyWords = []
        }
        
        if !self.QAnswerAry.contains(QuestionList[CurrentQuestion-1]) {
                        
            self.QAnswerAry.append(QuestionList[CurrentQuestion-1])
            self.QKeyWordsAry.append((self.KeyWords[CurrentQuestion]?.joined(separator: "@@@"))!)
            self.QAnswerKeyWords.append((self.AnswerKeyWords[CurrentQuestion]?.joined(separator: "@@@"))!)
            
        } else {
            
            self.QKeyWordsAry[CurrentQuestion-1] = (self.KeyWords[CurrentQuestion]?.joined(separator: "@@@"))!
            self.QAnswerKeyWords[CurrentQuestion-1] = (self.AnswerKeyWords[CurrentQuestion]?.joined(separator: "@@@"))!
            
        }
        
        if questionShow != QuestionList[CurrentQuestion-1] {
            LifeLine = LifeLine-1
        } else {
            self.Score = self.Score+1
        }
        
        
        
        self.life1.image = UIImage(named: (LifeLine >= 1 ? "heart.png":"FadeHeart.png"))
        self.life2.image = UIImage(named: (LifeLine >= 2 ? "heart.png":"FadeHeart.png"))
        self.life3.image = UIImage(named: (LifeLine >= 3 ? "heart.png":"FadeHeart.png"))
        
        
        
        UserDefaults.standard.setValue(self.QKeyWordsAry, forKey: "KeyWords")
        UserDefaults.standard.setValue(self.QAnswerAry, forKey: "AnswerAry")
        UserDefaults.standard.setValue(self.QAnswerKeyWords, forKey: "AnswerKeyWords")
        
        
        
           self.PoceedBtn.isHidden = (LifeLine == 0 ? true:false)
             
        
        if LifeLine == 0 || CurrentQuestion == self.QuestionList.count {
            MusicBgFile.sharedInstance.player?.stop()
        }
        
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "ResultPopupVC") as! ResultPopupVC
//                vc.modalPresentationStyle = .overCurrentContext
//                vc.modalTransitionStyle = .crossDissolve
                vc.AnsCount = CurrentQuestion
                vc.QuesCount = self.QuestionList.count
                vc.LifeLine = self.LifeLine
            
                vc.AnsStatus = (questionShow == QuestionList[CurrentQuestion-1] ? true:false)
                vc.AnswerStr = QuestionList[CurrentQuestion-1]
                vc.QuestionStr = self.questionShow
                vc.Blank = self.Answer
                vc.Score = self.Score
                vc.CorrectAnswers = self.CorrectAnswers
                vc.AnswerKeyWords = self.AnswerKeyWords
        

//            self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    
    
    
    func nextCall_Action() {
        
        self.PoceedBtn.isHidden = true
        if self.LifeLine == 0 {
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "ScoreBoardVC") as! ScoreBoardVC
            vc.Score = self.Score
            vc.LifeLine = self.LifeLine
            vc.AnswerKeyWords = self.AnswerKeyWords
            vc.QuestionCount = self.QuestionList.count
            self.navigationController?.pushViewController(vc, animated: true)
             
        } else {
            
            self.halfBlockVu.isHidden = true
            
            self.Hint = 0
            
            if UserDefaults.standard.bool(forKey: "TimerSwitch") {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.totalTime = 60
                    self.startOtpTimer()
            }
            
            if QuestionList[CurrentQuestion-1] == self.questionShow && CurrentQuestion <= self.QuestionList.count {
                self.ResultCorrect = self.ResultCorrect+1
            }
            
            
            if CurrentQuestion < self.QuestionList.count {
                CurrentQuestion = CurrentQuestion+1
                self.refreshQuestion(Number:CurrentQuestion)
                self.refreshAns()
            
                
            } else if CurrentQuestion == self.QuestionList.count {
                
                self.PoceedBtn.isHidden = true
                
                self.timer?.invalidate()
                self.timer = nil
                

                
                let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "ScoreBoardVC") as! ScoreBoardVC
                vc.Score = self.Score
                vc.LifeLine = self.LifeLine
                vc.AnswerKeyWords = self.AnswerKeyWords
                vc.QuestionCount = self.QuestionList.count
                self.navigationController?.pushViewController(vc, animated: true)
                
                
                
//                let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizResultViewController") as! QuizResultViewController
//                vc.Correct = ResultCorrect
//                vc.OverAllcount = self.QuestionList.count
//                vc.Chapter = Chapter
//                vc.Booknname = BookName
//                vc.RawQuestionsList = RawQuestionsList21000
//                vc.AnswerKeyWords = AnswerKeyWords
//                vc.KeyWords = KeyWords
//                vc.BlankList = BlankList
//                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    

    
    
    
    @IBAction func PreviousAction(_ sender: Any) {
        
        if CurrentQuestion > 1 {
            CurrentQuestion = CurrentQuestion-1
            self.refreshQuestion(Number:CurrentQuestion)
            self.refreshAns()
        }
    }
    

    
    func attributedTextBold(withString string: String, boldString: String, font: UIFont, underlineValue:[String]) -> NSAttributedString {
        
      let attributedString = NSMutableAttributedString(string: string)
        
      let FontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
      let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10.0
         
      let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
        attributedString.addAttributes(FontAttribute, range: range)
        
        
        for item in underlineValue {
            let range1 = (string as NSString).range(of: item, options: .caseInsensitive)
            attributedString.addAttributes(FontAttribute, range: range1)
            
            let ForegroundColor: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor]
            
//            let TextBold: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name:"Cera Pro Bold", size: 17)!,]
            
            attributedString.addAttributes(ForegroundColor, range: range1)
//            attributedString.addAttributes(TextBold, range: range1)
        }
                
      return attributedString
    }
    
    
    
    
    func uniqueElementsFrom(array: [String]) -> [String] {
      
      var set = Set<String>()
      let result = array.filter {
        guard !set.contains($0) else {
          return false
        }
        set.insert($0)
        return true
      }
      return result
    }
    
    
    

    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}





extension QuizMainPageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Blank.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        self.QuizAnswer = (self.QuizAnswerCV.dequeueReusableCell(withReuseIdentifier: "QuizAnswerCC", for: indexPath) as! QuizAnswerCC)
        self.QuizAnswer.AnswerLbl.text = Blank[indexPath.row]
        self.QuizAnswer.AnswerVu.ViewShadow(5, color: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
        self.QuizAnswer.AnswerLbl.textColor = UserDefaults.standard.color(forKey: "AppThemeColor")
        
        if Answer.contains(Blank[indexPath.row]) {
            self.QuizAnswer.AnswerVu.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
            self.QuizAnswer.AnswerLbl.textColor = UIColor.white
        } else{
            self.QuizAnswer.AnswerVu.backgroundColor = UIColor.white
            self.QuizAnswer.AnswerLbl.textColor = UIColor.black
        }
        
        return self.QuizAnswer!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 36)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if AnswerKeyWords.count <= CurrentQuestion {
            AnswerKeyWords[CurrentQuestion] = Answer
        } else {
            Answer = AnswerKeyWords[CurrentQuestion]!
        }
        
        
        if !Answer.contains(Blank[indexPath.row]) {
            
            
            if let index = Answer.firstIndex(of: Blank[indexPath.row]) {
                Answer[index] = Blank[indexPath.row]
            } else if let index = Answer.firstIndex(of: " ________ ") {
                Answer[index] = Blank[indexPath.row]
            }
            else {
                Answer.append(Blank[indexPath.row])
            }
            
            if UserDefaults.standard.bool(forKey: "ToneSwitch") {
                QuizClickSound.shared.SelectMusic()
            }
            
            if UserDefaults.standard.bool(forKey: "VibSwitch") {
                Vibration.medium.vibrate()
            }
            
            if let range = self.questionShow.range(of:" ________ ") {
                self.questionShow = self.questionShow.replacingCharacters(in: range, with:Blank[indexPath.row])
            }
            self.QuestionTxt.attributedText = attributedTextBold(withString: self.questionShow, boldString: self.questionShow, font: UIFont.systemFont(ofSize: 17, weight: .regular), underlineValue: Blank)
            
            AnswerKeyWords[CurrentQuestion] = Answer
            
        } else {
            
            if UserDefaults.standard.bool(forKey: "VibSwitch") {
                Vibration.light.vibrate()
            }
            if UserDefaults.standard.bool(forKey: "ToneSwitch") {
                QuizClickSound.shared.DeSelectMusic()
            }
            
            
            if let range = self.questionShow.range(of:Blank[indexPath.row]) {
                self.questionShow = self.questionShow.replacingCharacters(in: range, with:" ________ ")
            }
            
            if let index = Answer.firstIndex(of: Blank[indexPath.row]) {
                //                Answer.remove(at: index)
                Answer[index] = " ________ "
            }
            AnswerKeyWords[CurrentQuestion] = Answer
            self.QuestionTxt.attributedText = attributedTextBold(withString: self.questionShow, boldString: self.questionShow, font: UIFont.systemFont(ofSize: 17, weight: .regular), underlineValue: Blank)
        }
        
        
        let comparedValue = Answer.filter () { Blank.contains($0) }
        if comparedValue.count >= 1 {
            self.PoceedBtn.isHidden = false
        } else {
            self.PoceedBtn.isHidden = true
        }
        
        if Answer.filter({ $0 != " ________ " }).count >= (Blank.count/2) {
            halfBlockVu.isHidden = false
        } else {
            halfBlockVu.isHidden = true
        }
        
        self.QuizAnswerCV.reloadData()
    }
}


extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}



extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}





extension UITextView {

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.cut) || action == #selector(UIResponderStandardEditActions.copy)
    }

//    override public func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
//        if action == #selector(NSObject.copy(_:)) || action == #selector(NSObject.paste(_:)) {
//            return false
//        }
//
//        return true
//    }

}



class CustomUITextField: UITextView {
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
        }
    
    
}




