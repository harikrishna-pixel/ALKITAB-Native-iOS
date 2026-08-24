//
//  WalletViewController.swift
//  General Quiz
//
//  Created by ajayprasanth on 19/05/23.
//

import UIKit
import StoreKit

class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKPaymentTransactionObserver, SKProductsRequestDelegate , WalletProtocol{

    

    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        @IBOutlet var LifeTimeIndicator: UIActivityIndicatorView!

        @IBOutlet weak var YearlyLbl: UILabel!
        @IBOutlet weak var MonthlyLbl: UILabel!
        @IBOutlet weak var WalletLbl: UILabel!

        @IBOutlet var LoaderVu: UIView!
        var PriductIDArray:[String] = []

        var PRODUCT_ID = ""
        var productID = ""
        var FAQView: FAQVu?
    
        var PresentVu:Bool = false

        var productsRequest = SKProductsRequest()
        var iapProducts = Array<[SKProduct]>()

        var Price1: String = ""
        var Price2: String = ""
        var Product_title: Array<String> = []

        var transDate = ""
        var transId = ""
    
        var productIDIndex:Int = 0
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    @IBOutlet weak var WalletViewTableView: UITableView!
    @IBOutlet weak var ClimeAlert: UIView!
    
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    var WalletTableCell:WalletCell!
    var TimeCell:TimerCell!
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    var Coins:[Int] = []
    var Offer:[Int] = []
    var PayList:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        QuizProtocol.WalletProtocoldelegate = self
        
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        
        if UserDefaults.standard.array(forKey: "identifier") != nil  {
            PriductIDArray.append(contentsOf: UserDefaults.standard.array(forKey: "identifier") as! [String])
            self.Coins = UserDefaults.standard.array(forKey: "item_1") as! [Int]
            self.Offer = UserDefaults.standard.array(forKey: "value") as! [Int]
        }
        
                
        
        self.WalletLbl.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
         
        
//        App_Protocol.GetCoinsDelegate = self
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            if IS_SUBSCRIPTION_ENABLE == 1 {
                self.Callapi(i:0)
            }
        }
    }
    
    
    func Callapi(i:Int) {
        if productIDIndex <= 2  {
            self.callingApi(i: i)
        }
    }
    
    func callingApi(i:Int) {
        if self.PriductIDArray.count > i {
            self.PRODUCT_ID = self.PriductIDArray[i]
            self.fetchAvailableProducts()
        }
    }
    
    
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.WalletLbl.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 5 {
//            return 60
//        } else {
            return 92
//        }
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          
          if section == 3 {
              return self.PayList.count
          } else {
              return 1
          }
      }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
      {
                    
          switch (indexPath.section) {
              
          case 0:
              
              self.TimeCell = (self.WalletViewTableView.dequeueReusableCell(withIdentifier: "freeCoins") as! TimerCell?)
              self.TimeCell.AdTime.addTarget(self, action: #selector(CallFreeCoin), for: .touchUpInside)
              self.TimeCell.FreeCoinLbl.text = "\(freeCoins) coins"
              self.TimeCell.FreeCoinsVu.backgroundColor = Themecolor
              return self.TimeCell!
                            
          case 1:
              
              self.WalletTableCell = (self.WalletViewTableView.dequeueReusableCell(withIdentifier: "watchAd") as! WalletCell?)
              self.WalletTableCell.WatchAd.addTarget(self, action: #selector(CallInterstitialAd), for: .touchUpInside)
              self.WalletTableCell.RewardCoinLbl.text = "\(rewardCoins) coins"
              self.WalletTableCell.WatchAdVu.backgroundColor = Themecolor
              
              return self.WalletTableCell!
              
          case 2:
              
              self.WalletTableCell = (self.WalletViewTableView.dequeueReusableCell(withIdentifier: "Giftcard") as! WalletCell?)
              self.WalletTableCell.ScratchBtn.addTarget(self, action: #selector(ScrachCard), for: .touchUpInside)
              self.WalletTableCell.GiftcardVu.backgroundColor = Themecolor
              
              return self.WalletTableCell!
              
          case 3:
              
              self.WalletTableCell = (self.WalletViewTableView.dequeueReusableCell(withIdentifier: "WalletMoney") as! WalletCell?)
              self.WalletTableCell.coinTxt.text = "\(Coins[indexPath.row]) Coins"
              
                  self.WalletTableCell.CoinPayBtn.setTitle(PayList[indexPath.row], for: .normal)
                  self.WalletTableCell.PayList.isHidden = true
                  self.WalletTableCell.CoinPayBtn.tag = indexPath.row
                  self.WalletTableCell.CoinPayBtn.addTarget(self, action: #selector(payment), for: .touchUpInside)
                  self.WalletTableCell.WalletMoneyVu.backgroundColor = Themecolor

              let offerValue = indexPath.row < self.Offer.count ? self.Offer[indexPath.row] : 0
              if offerValue > 0, let offerImage = UIImage(named: "\(offerValue)") {
                  self.WalletTableCell.OfferImg.isHidden = false
                  self.WalletTableCell.OfferImg.image = offerImage
              } else {
                  self.WalletTableCell.OfferImg.isHidden = true
                  self.WalletTableCell.OfferImg.image = nil
              }

              
              return self.WalletTableCell!
              
          default: break
          }
          
          return self.WalletTableCell!
      }

    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
   }
    
    
    
    @objc func CallInterstitialAd(sender: UIButton!) {
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            AdmobManager.shared.IronSource_Reward_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!, RewardAd: "FreeCoins")
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    func AdNotAvailable() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
//            self.view.makeToast("Ad not Available", duration: 2.0, position: .center)
        }
    }
    
    
    @IBAction func Back(_ sender: Any) {
        if PresentVu {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        QuizProtocol.QuizMaindelegate?.UpdatePay()
    }
    
    
    func CollectCoin() {
        self.LoaderVu.isHidden = true
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+rewardCoins, forKey: "WalletMoney")
        self.WalletLbl.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        self.view.makeToast("Reward added to your wallet", duration: 2.0, position: .center)
    }
    

    @objc func CallFreeCoin(sender: UIButton!) {
        
        
        
        if UserDefaults.standard.string(forKey: "FreeAds") ?? "" == "" {
            
            let date = Date().addingTimeInterval(15 * 60)
            UserDefaults.standard.setValue(date.string(format: "MM/dd/yy HH:mm:ss"), forKey: "FreeAds")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+freeCoins, forKey: "WalletMoney")
            self.view.makeToast("Coins claimed successfully!", duration: 2.0, position: .center)
            
        } else {
            var adtime = UserDefaults.standard.string(forKey: "FreeAds")!
            let f = DateFormatter()
            f.dateFormat = "MM/dd/yy HH:mm:ss"
        
            if  f.date(from: Date().string(format: "MM/dd/yy HH:mm:ss"))! >=  f.date(from: adtime)! {
                let date = Date().addingTimeInterval(15 * 60)
                UserDefaults.standard.setValue(date.string(format: "MM/dd/yy HH:mm:ss"), forKey: "FreeAds")
                
                UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+freeCoins, forKey: "WalletMoney")
                self.view.makeToast("Coins claimed successfully!", duration: 2.0, position: .center)
            } else {
                self.ClimeAlert.isHidden = false
                print("FreeAds :",UserDefaults.standard.string(forKey: "FreeAds")!)
                print("Date :",Date().string(format: "MM/dd/yy HH:mm:ss"))
            }
        }
        
        
        let indexPath = IndexPath(item:0, section: 0)
        self.WalletViewTableView.reloadRows(at: [indexPath],
                                  with: .fade)
        
        self.WalletLbl.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        self.WalletViewTableView.reloadData()
    }
    
    
    @IBAction func ClimeAlert_Action(_ sender: Any) {
        self.ClimeAlert.isHidden = true
        
        let indexPath = IndexPath(item: 0, section: 0)
        self.WalletViewTableView.reloadRows(at: [indexPath], with: .fade)

    }
    
        
    
    @objc func ScrachCard(sender: UIButton!) {
        
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
            self.navigationController?.pushViewController(vc1, animated: true)
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "GiftCardVC") as! GiftCardVC
                self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    
    
    @objc func payment(sender: UIButton!) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            PRODUCT_ID = self.PriductIDArray[1]
            self.LoaderVu.isHidden = false
              if iapProducts.count > 0 {
                  purchaseProduct(product: iapProducts[sender.tag][0])
              }
        } else {
                self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }

    }
     
    
}






extension Date {
    public var nextHour: Date {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: self)
        let components = DateComponents(hour: 12, minute: -minutes)
        return calendar.date(byAdding: components, to: self) ?? self
    }
}







// MARK: Pay

extension WalletViewController {
    

    
    
    @IBAction func TermsAndCondition(_ sender: Any) {
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
                   if let url = URL(string: TermsURL), UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url, options: [:]) { success in
                           print(success ? "URL was opened successfully." : "Failed to open URL.")
                       }
                   } else {
                       self.view.makeToast("Invalid URL or cannot open.", duration: 2.0, position: .bottom)
                   }
                   
               } else {
                   self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
               }
        
    }
    
    
    @IBAction func Privacy(_ sender: Any) {
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
                   if let url = URL(string: PrivacyURL), UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url, options: [:]) { success in
                           print(success ? "URL was opened successfully." : "Failed to open URL.")
                       }
                   } else {
                       self.view.makeToast("Invalid URL or cannot open.", duration: 2.0, position: .bottom)
                   }
                   
               } else {
                   self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
               }
        
    }
    
    @IBAction func FAQ(_ sender: Any) {
        self.FAQView = FAQVu.fromNib(named: "FAQVu")
        self.FAQView!.frame = self.view.bounds
        self.FAQView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.FAQView!)
    }
    
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            
            
            
        if response.products.count > 0 {

            let purchasingProduct = response.products[0] as SKProduct
//            self.Product_title.append(purchasingProduct.localizedTitle)
                        
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = purchasingProduct.priceLocale
            
            print(response.products)
            print(numberFormatter.string(from: purchasingProduct.price)!)
                        
                self.iapProducts.append(response.products)
                self.PayList.append(numberFormatter.string(from: purchasingProduct.price)!)
            }

        }
        
        DispatchQueue.main.async {
            self.productIDIndex = self.productIDIndex+1
            self.Callapi(i:self.productIDIndex)
            
            self.WalletViewTableView.reloadData()
        }
        
        
    }
    
    
    
    
    // MARK: - Make purchase of a product
        func canMakePurchases() -> Bool {
            return SKPaymentQueue.canMakePayments() }
        
        func purchaseProduct(product: SKProduct) {
            if self.canMakePurchases() {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
                productID = product.productIdentifier
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+12) {
                    self.LoaderVu.isHidden = true
                }
                
            }
        }
    
    
    
    // MARK: - Fetch all available IAP products which is created in iTunes connect.
    func fetchAvailableProducts() {
        let productIdentifiers = NSSet(objects: PRODUCT_ID)
        
        guard let identifier = productIdentifiers as? Set<String> else { return }
        productsRequest = SKProductsRequest(productIdentifiers: identifier)
        productsRequest.delegate = self
        productsRequest.start()
        
    }
    
    
    func LoaderComplete(LoaderMsg:String,LoaderImg:String) {
        let alert = UIAlertController(title: nil, message: LoaderMsg, preferredStyle: .alert)
        let loaderImage = UIImageView(frame: CGRect(x: 15, y: 20, width: 20, height: 20))
        loaderImage.image = UIImage(named: LoaderImg)
        alert.view.addSubview(loaderImage)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        
        for transaction:AnyObject in transactions {

            if let trans = transaction as? SKPaymentTransaction {
                

                switch trans.transactionState {
                case .purchased:
                    
                    
                    if let paymentTransaction = transaction as? SKPaymentTransaction {
                        SKPaymentQueue.default().finishTransaction(paymentTransaction)
                    }

                    
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .full
                        dateFormatter.timeStyle = .none
                        dateFormatter.locale = Locale.current
                        self.transDate = dateFormatter.string(from: trans.transactionDate!)
                        self.transId = trans.transactionIdentifier!
                        UserDefaults.standard.set(true, forKey: "isPurchased")
                        
                        
                        if productID == PriductIDArray[0] {
                            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+Pack1, forKey: "WalletMoney")
                        } else if productID == PriductIDArray[1] {
                            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+Pack2, forKey: "WalletMoney")
                        } else if productID == PriductIDArray[2] {
                            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "WalletMoney")+Pack3, forKey: "WalletMoney")
                        }

                        self.WalletLbl.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
                        
                        self.LoaderVu.isHidden = true
                        self.LoaderComplete(LoaderMsg: "Success", LoaderImg: "error")
                    
                    
                    if productID == SUBSCRIPTIONID_LifeTime {
                        PaymentHistory.sharedInstance.Getpayment(completion: {
                            self.dismiss(animated: true, completion: nil)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
//                                self.dismiss(animated: true, completion: nil)
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    } else {
                        self.dismiss(animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
//                            self.dismiss(animated: true, completion: nil)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                    
                    
                    
                case .failed:
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    self.LoaderVu.isHidden = true
                    self.LoaderComplete(LoaderMsg: "Something went wrong", LoaderImg: "error")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                        self.dismiss(animated: false, completion: nil)
                    }
                case .restored:
                    self.LoaderVu.isHidden = true
                    self.LoaderComplete(LoaderMsg: "Success", LoaderImg: "error")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    PaymentHistory.sharedInstance.Getpayment(completion: {
                        
                    })
                    
                    
                    dismiss(animated: false, completion: nil)
                default: break
                }
            }
        }
    }
    
    
    @IBAction func Restore(_ sender: Any) {
         
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            self.LoaderVu.isHidden = false
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.LoaderVu.isHidden = true
//        self.LoaderComplete(LoaderMsg: "Success", LoaderImg: "error")
        
        PaymentHistory.sharedInstance.Getpayment(completion: {
//            self.dismiss(animated: true, completion: nil)
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
//                self.dismiss(animated: true, completion: nil)
//                self.navigationController?.popViewController(animated: true)
//            }
        })
    }

    func paymentQueue(_ queue: SKPaymentQueue,
                      restoreCompletedTransactionsFailedWithError error: Error) {
      
    }
    
    
    
    
    
}
