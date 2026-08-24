//
//  GiftCardClaimVC.swift
//  General Quiz
//
//  Created by ajayprasanth on 13/03/23.
//

import UIKit
import CoreData

class GiftCardClaimVC: UIViewController, CardProtocol {

//    @IBOutlet var FreeCardVu: UIView!
    @IBOutlet weak var GiftCardFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var GiftCardFramewidth: NSLayoutConstraint!
    @IBOutlet weak var InnerBack: UIView!
    @IBOutlet weak var SwipeView: UIView!
    @IBOutlet weak var SubView: UIView!
    @IBOutlet weak var swipeImage: UIButton!
    @IBOutlet weak var OfferLbl: UILabel!
    
    @IBOutlet weak var AdVu: UIView!
    @IBOutlet weak var ClimeButtonVu: UIView!
    @IBOutlet weak var AlertVu: UIView!
    @IBOutlet weak var AdLoader: UIView!
    @IBOutlet weak var ButtonLoader: UIView!
    @IBOutlet weak var WalletMoney: UILabel!
    
    @IBOutlet weak var TapCarVu: UIView!
    @IBOutlet weak var TapCarLbl: UILabel!
     
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    
    @IBOutlet weak var CoinsTxt: UILabel!
    var AdEnable = false
    
    var CoinCards:[Any] = [10,20,30,40,50,60,70,80,90,100,150,200,250,300,350,400,450,500,"Life","50:50","Hint"]
    var coins:Int = 0
    var CardType:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QuizProtocol.CardDelegate = self
        self.WalletMoney.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)

        self.AdVu.backgroundColor = Themecolor
        self.ButtonLoader.backgroundColor = Themecolor
        
        
        
        DispatchQueue.main.async {
            if CoreDataModel.sharedInstance.GetCardAry(entity: CDCardList).count % 10 == 0 {
                self.CoinCards = [100,150,200,250,300,350]
                self.swipeImage.setImage(UIImage(named: "card.png"), for: .normal)
            } else {
                self.CoinCards = [10,20,30,40,50,60,70,80,90]
                self.swipeImage.setImage(UIImage(named: "card.png"), for: .normal)
            }
            
            self.AdVu.layer.masksToBounds = true
            self.ClimeButtonVu.isHidden = true
            
            let randCard = self.CoinCards.randomElement()!
            if let coin:Int = randCard as? Int {
                self.coins = coin
                self.SubView.isHidden = false
            } else {
                self.CardType = randCard as? String ?? ""
                self.SubView.isHidden = true
                self.OfferLbl.text = self.CardType
                self.OfferLbl.backgroundColor = (self.CardType == "Life" ? .clear : hexColorConvert.shared.hexStringToUIColor(hex: "6B1B13"))
            }
                
            
            self.GiftCardFrameHeight.constant = ScreenWidth/1.2
            self.GiftCardFramewidth.constant = ScreenWidth/1.2
            
            self.CoinsTxt.text =  "Collect \(self.coins) Coins"
            self.ButtonAnimation()
            
            if UserDefaults.standard.integer(forKey: "CardCount") == 0 && TimeConvert.sharedInstance.ConvertSeconds(toDate: UserDefaults.standard.string(forKey: "CardAdTime") ?? Date().string(format: "MM/dd/yy HH:mm:ss")) <= 0 {
                CoreDataModel.sharedInstance.deleteAllData(CDCardList)
            }
        }
    
        
        
    }
    
    
    
    func ButtonAnimation() {
        UIView.animate(withDuration: 0.6,
            animations: {
                self.TapCarLbl.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: { _ in
              self.ButtonAnimation1()
            })
    }
    
    func  ButtonAnimation1() {
        UIView.animate(withDuration: 0.6,
                animations: {
                    self.TapCarLbl.transform = CGAffineTransform.identity
                },
                completion: { _ in
                self.ButtonAnimation()
          })
    }
    

        
    
    @IBAction func Claim_Answer(_ sender: UIButton) {
        self.TapCarVu.isHidden = true
        sender.isEnabled = false
        
        if CardType == "" {
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+coins, forKey: "WalletMoney")
            self.CardSaver(cardCoins: coins, cartType: "CoinCard")
            self.view.makeToast("Coins claimed successfully!", duration: 2.0, position: .center)
            
        } else {
            self.CardSaver(cardCoins: 0, cartType: CardType)
        }
        App_Protocol.CardShowdelegate?.ReloadList()

        self.WalletMoney.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.8) {
//            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func CardClick_Action(_ sender: Any) {
        self.TapCarVu.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                self.AdLoader.isHidden = true
                self.swipeImage.setImage(UIImage(named: "CoinPic.png"), for: .normal)
                if UserDefaults.standard.bool(forKey: "ToneSwitch") {
                    QuizClickSound.shared.CardCollectSound()
                }
                UIView.transition(with: self.SwipeView, duration: 0.6, options: .transitionFlipFromLeft,  animations: {
                    self.swipeImage.isHidden = true
                    self.ClimeButtonVu.isHidden = false
                    self.AdVu.isHidden = false
                })
            }
//        }
    }
    
    
    
    
    
    
    @IBAction func AdClick_Action(_ sender: Any) {
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            
            self.ClimeButtonVu.isHidden = true
            self.ButtonLoader.isHidden = false
            AdmobManager.shared.IronSource_Reward_ShowAds(vw: self, RewardAd: "Scratch")
            self.ClimeButtonVu.isHidden = false
            
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    
    func AdNotAvailable() {
        
//        self.view.makeToast("Ad not Available", duration: 2.0, position: .center)
        self.ButtonLoader.isHidden = true
        
//        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+self.coins, forKey: "WalletMoney")
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) {
////            self.CardSaver(cardCoins: self.coins, cartType: "CoinCard")
////            App_Protocol.CardShowdelegate?.ReloadList()
////            self.AlertVu.isHidden = false
////            self.dismiss(animated: true, completion: nil)
//        }
        
    }
    
    
    
    func CollectCoin() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+(self.coins*2), forKey: "WalletMoney")
            self.ButtonLoader.isHidden = true
            self.CardSaver(cardCoins: self.coins*2, cartType: "CoinCard")
            self.ClimeButtonVu.isHidden = true
            self.AdLoader.isHidden = true
            self.AlertVu.isHidden = false
            App_Protocol.CardShowdelegate?.ReloadList()
        }
        
    }

    
    
    
    @IBAction func ClimeCoinsDouble_Action(_ sender: Any) {
        self.AlertVu.isHidden = true
        App_Protocol.CardShowdelegate?.ReloadList()
        self.WalletMoney.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    @IBAction func ListVu_Answer(_ sender: Any) {
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "GiftCardVC") as! GiftCardVC
        self.navigationController?.pushViewController(vc, animated: true)
       }
    
    
    
    func CardSaver(cardCoins:Int,cartType:String) {
        
        
        if UserDefaults.standard.integer(forKey: "CardCount") >= 2 {
            let now = Date()
            let HoursAgo = Calendar.current.date(byAdding: .hour, value: 12, to: now)
            UserDefaults.standard.setValue(HoursAgo!.string(format: "MM/dd/yy HH:mm:ss"), forKey: "CardAdTime")
        } else {
            let now = Date()
            let date = Calendar.current.date(byAdding: .minute, value: 30, to: now)
            UserDefaults.standard.setValue(date!.string(format: "MM/dd/yy HH:mm:ss"), forKey: "CardAdTime")
        }
        
        
        
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "CardCount")+1, forKey: "CardCount")
        
        
                guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                let managedContext = appdelegate.persistentContainer.viewContext
                let userEntity = NSEntityDescription.entity(forEntityName: CDCardList, in: managedContext)
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)

                    user.setValue(cardCoins, forKey: "cardCoins")
                    user.setValue(cartType, forKey: "cartType")
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
            }
        
        
        
        if UserDefaults.standard.integer(forKey: "CardCount") == 3 {
            self.CardNotification(CardType: "hour")
        } else {
            self.CardNotification(CardType: "min")
        }
    }


    

    
    
    
    
    
    
    func CardNotification(CardType:String) {
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["ScrachCard"])
        
        
        var MinAgo: Date?
        
        if CardType == "min" {
            MinAgo = Calendar.current.date(byAdding: .minute, value: 30, to: Date.current)
        } else {
            MinAgo = Calendar.current.date(byAdding: .hour, value: 12, to: Date.current)
        }
          
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            
            content.title = "Don't miss out! "
            content.body = "Your gift card is now available for claiming. Enjoy!"
            
            content.sound = UNNotificationSound.default
            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let components = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: MinAgo! as Date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "ScrachCard", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                
            })
        }
    }
    

    
    
    
    
    
}


