//
//  GiftCardVC.swift
//  General Quiz
//
//  Created by ajayprasanth on 13/03/23.
//

import UIKit

class GiftCardVC: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CardShow {
    
    
    @IBOutlet var GiftCardCV: UICollectionView!
    @IBOutlet weak var CardCount: UILabel!
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    var timer: Timer?
//    var totalTime = 14
    var CellIndexpath: Int = 0
    
    var GiftCardCell: GiftCardCC?
    var adtime: String = UserDefaults.standard.string(forKey: "CardAdTime") ?? ""
    
    var coins:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        App_Protocol.CardShowdelegate = self
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        self.GiftCardCV.register(UINib(nibName: "CardView", bundle: nil), forCellWithReuseIdentifier: "CardView")
        self.GiftCardCV.register(UINib(nibName: "ClosedCard", bundle: nil), forCellWithReuseIdentifier: "ClosedCard")
        self.GiftCardCV.register(UINib(nibName: "OfferCardView", bundle: nil), forCellWithReuseIdentifier: "OfferCardView")
        
        coins = CoreDataModel.sharedInstance.GetCardAry(entity: CDCardList)
        CardCount.text = "\(UserDefaults.standard.integer(forKey: "CardCount"))/3"

    }
    
    
    func ReloadList() {
        coins = CoreDataModel.sharedInstance.GetCardAry(entity: CDCardList)
        DispatchQueue.main.async {
            self.GiftCardCV.reloadData()
            self.GiftCardCV.updateFocusIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        CardCount.text = "\(UserDefaults.standard.integer(forKey: "CardCount"))/3"
        
        coins = CoreDataModel.sharedInstance.GetCardAry(entity: CDCardList)
        DispatchQueue.main.async {
            self.GiftCardCV.reloadData()
            self.GiftCardCV.updateFocusIfNeeded()
        }
    }

    
    
    @IBAction func Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       }
    


}


extension GiftCardVC {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

          return CGSize(width: (self.GiftCardCV.bounds.width/2), height: (self.GiftCardCV.bounds.width/2))

      }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if coins.count > 3 {
                return 4
            } else {
                return coins.count+1
            }
        }
    
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            self.CellIndexpath  = indexPath.row-1
            
            
            if indexPath.row == 0 {
                let cell = (self.GiftCardCV.dequeueReusableCell(withReuseIdentifier: "ClosedCard", for: indexPath) as! ClosedCard)
                
                cell.layer.cornerRadius = 20
                
                
//                let totalTime = TimeConvert.sharedInstance.ConvertSeconds(toDate: UserDefaults.standard.string(forKey: "CardAdTime") ?? Date().string(format: "MM/dd/yy HH:mm:ss"))
//
//                if totalTime <= 0 {
//                    cell.SkipFrame.isHidden = true
//                } else {
//                    cell.SkipFrame.isHidden = false
//                }
                 
                if UserDefaults.standard.integer(forKey: "CardCount") >= 3 {
                    cell.orlbl.text = ""
                    cell.SkipFrame.isHidden = false
                    cell.SkipBtnFrame.isHidden = true
                }
                
                cell.offerCard.image = UIImage(named: "card.png")
                
                cell.ImageFrameHeight.constant = (self.GiftCardCV.bounds.width/2)-20
                cell.ImageFramewidth.constant = (self.GiftCardCV.bounds.width/2)-20
                
                
                
                if UserDefaults.standard.string(forKey: "CardAdTime") ?? "" != "" {
                    cell.timer?.invalidate()
                    cell.timer = nil
                    
                    
                    cell.totalTime = TimeConvert.sharedInstance.ConvertSeconds(toDate: UserDefaults.standard.string(forKey: "CardAdTime") ?? Date().string(format: "MM/dd/yy HH:mm:ss"))
                    
                    
                    if cell.totalTime > 0 {
                        cell.SkipFrame.isHidden = false
                        cell.startOtpTimer()
                    } else {
                        cell.SkipFrame.isHidden = true
                        if UserDefaults.standard.integer(forKey: "CardCount") == 3 {
                            UserDefaults.standard.setValue(0, forKey: "CardCount")
                        }
                    }
                } else {
                    cell.SkipFrame.isHidden = true
                }
                
                
                if UserDefaults.standard.integer(forKey: "CardCount") == 0 {
                    cell.SkipFrame.isHidden = true
                }
                
                cell.SkipBtn.addTarget(self, action: #selector(Skip_Action), for: .touchUpInside)
                
                return cell
            } else if coins[self.CellIndexpath].components(separatedBy: "_")[1] == "50:50" || coins[self.CellIndexpath].components(separatedBy: "_")[1] == "Hint" {
                
                let cell = (self.GiftCardCV.dequeueReusableCell(withReuseIdentifier: "OfferCardView", for: indexPath) as! OfferCardView)
                
                cell.CardType.text = coins[self.CellIndexpath].components(separatedBy: "_")[1]
                
                cell.StatusWidth.constant = (self.GiftCardCV.bounds.width/2)-10
                cell.CardTypeWidth.constant = (self.GiftCardCV.bounds.width/2)-10
                cell.CardTypeHeight.constant = ((self.GiftCardCV.bounds.width/2))
                
                
                return cell
                
            } else {
                let cell = (self.GiftCardCV.dequeueReusableCell(withReuseIdentifier: "CardView", for: indexPath) as! CardView)
                
                    cell.ImageFrameHeight.constant = (self.GiftCardCV.bounds.width/2)-20
                    cell.ImageFramewidth.constant = (self.GiftCardCV.bounds.width/2)-20
                
                cell.ViewFramewidth.constant =  (self.GiftCardCV.bounds.width/2)-10
                cell.ViewFrameHeight.constant =  (self.GiftCardCV.bounds.width/2)-10
                cell.CoinLbl.text = "Collected \(coins[self.CellIndexpath].components(separatedBy: "_")[0]) Coins"
                
                return cell
            }
        }
    
    
    
    
    
    @objc func Skip_Action(sender: UIButton!) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            self.CardViewAction(AdEnable: true)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
            
    }
    
    

    
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                          
            if indexPath.row == 0 && UserDefaults.standard.integer(forKey: "CardCount") < 3 {
                
                if UserDefaults.standard.string(forKey: "CardAdTime") ?? "" != "" {
                    let f = DateFormatter()
                    f.dateFormat = "MM/dd/yy HH:mm:ss"
                    if  f.date(from: Date().string(format: "MM/dd/yy HH:mm:ss"))! >=  f.date(from: adtime)! {
                        self.CardViewAction()
                    } else {
                        
                        let alert = UIAlertController(title: "Alert", message: "Please try again later or Tap on Skip button", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                } else {
                    self.CardViewAction()
                }
            } else if indexPath.row == 0 && UserDefaults.standard.integer(forKey: "CardCount") >= 3 {
                
//                let date = Date().addingTimeInterval(30 * 60)
//                UserDefaults.standard.setValue(date.string(format: "HH:mm:ss"), forKey: "CardAdTime")
                
            } else {
                let alert = UIAlertController(title: "Alert", message: "Coins already claimed!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    
    
    func CardViewAction(AdEnable:Bool = false) {
        
        if AdEnable {
            AdmobManager.shared.IronSource_Reward_ShowAds(vw: self, RewardAd: "OpenCard")
        } else {
            self.cardNavigate()
        }
        
    }
    
    
    func cardNavigate() {
        
        AdmobManager.shared.RewardAd = ""
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "GiftCardClaimVC") as! GiftCardClaimVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func AdNotAvailable() {
//        self.view.makeToast("Ad not Available", duration: 2.0, position: .center)
    }
    
    
    
    
    
}




extension Date {
    func withAddedMinutes(minutes: Double) -> Date {
         addingTimeInterval(minutes * 60)
    }

    func withAddedHours(hours: Double) -> Date {
         withAddedMinutes(minutes: hours * 60)
    }
}
