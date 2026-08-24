//
//  QuizWalletVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 28/02/23.
//

import UIKit
import StoreKit

class QuizWalletVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SKPaymentTransactionObserver,SKProductsRequestDelegate, QuizPay {
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//        @IBOutlet var OneYearIndicator: UIActivityIndicatorView!
//        @IBOutlet var LifeTimeIndicator: UIActivityIndicatorView!
        
    
//        @IBOutlet weak var WalletLbl: UILabel!
        
//        @IBOutlet var LoaderVu: UIView!
        var PriductIDArray = [SUBSCRIPTIONID_OneYear]
        
        var PRODUCT_ID = ""
        var productID = ""
        
        var productsRequest = SKProductsRequest()
        var iapProducts = [SKProduct]()
        var iapProducts1 = [SKProduct]()
        
        var Price1: String = ""
        var Price2: String = ""
        var Product_title: Array<String> = []
        
        var transDate = ""
        var transId = ""
        
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
    
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    @IBOutlet var WalletCoin: UILabel!
    @IBOutlet var WalletTable: UITableView!
    
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    var QuizWalletCell: QuizWalletTableCell?
    var TimerCell: QuizWalletTableCell?
    var RemoveAdCell: QuizWalletTableCell?
    
    var timer: Timer?
    var totalTime = 1200
    
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        self.WalletCoin.text =  "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        QuizProtocol.QuizPaydelegate = self
                  
        
        
        for i in 0..<self.PriductIDArray.count {
            self.PRODUCT_ID = self.PriductIDArray[i]
           self.fetchAvailableProducts()
        }
        
        
        
        let indexPaths = NSIndexPath(row:0 , section: 1)
        self.TimerCell = (self.WalletTable.dequeueReusableCell(withIdentifier: "DailyClaim", for: indexPaths as IndexPath) as! QuizWalletTableCell)
        
        let AdRemoveindexPath = NSIndexPath(row:0 , section: 0)
        self.RemoveAdCell = (self.WalletTable.dequeueReusableCell(withIdentifier: "AdRemove", for: AdRemoveindexPath as IndexPath) as! QuizWalletTableCell)
        
        
        self.TimerRun()
    }
    
    
    
    func TimerRun() {
        
        if UserDefaults.standard.string(forKey: "AdTime") ?? "" != "" {
                        
            if totalTime <= 0 {
                if let timer = self.timer {
                    timer.invalidate()
                    self.timer = nil
                }
            } else {
                var adtime = UserDefaults.standard.string(forKey: "AdTime")
                let f = DateFormatter()
                f.dateFormat = "HH:mm:ss"
                                
                
                let date = Date()
                self.totalTime = date.compareTimeOnly(to:  f.date(from: adtime!)!)
                
                self.startOtpTimer()
            }
        }
    }
    

    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
        QuizProtocol.QuizMaindelegate?.UpdatePay()
    }
    

    func AdAmount(amount: Int) {
        self.WalletCoin.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))" 
    }
    
    
     // MARK:- Tableview Delegate
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return 60
     }
     
     func numberOfSections(in tableView: UITableView) -> Int {
         return 4
     }
     
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
       }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         switch (indexPath.section) {
         
         case 0:
             
             self.QuizWalletCell = (self.WalletTable.dequeueReusableCell(withIdentifier: "AdRemove") as! QuizWalletTableCell?)
               self.QuizWalletCell!.RemoveAd.ViewShadow(0, color: UIColor.gray)
             
             return self.QuizWalletCell!
             
         case 1:
             
             self.QuizWalletCell = (self.WalletTable.dequeueReusableCell(withIdentifier: "DailyClaim") as! QuizWalletTableCell?)
               self.QuizWalletCell!.DailyVu.ViewShadow(0, color: UIColor.gray)
               self.QuizWalletCell!.TimerTxt.text = ""
             
             return self.QuizWalletCell!
             
         case 2:
             
             self.QuizWalletCell = (self.WalletTable.dequeueReusableCell(withIdentifier: "QuizWalletCell") as! QuizWalletTableCell?)
               self.QuizWalletCell!.walletVu.ViewShadow(0, color: UIColor.gray)
             return self.QuizWalletCell!
              
         case 3:
             
             self.QuizWalletCell = (self.WalletTable.dequeueReusableCell(withIdentifier: "RateUs") as! QuizWalletTableCell?)
             
             self.QuizWalletCell!.RateUsVu.ViewShadow(0, color: UIColor.gray)
             
             return self.QuizWalletCell!
             
         default: break
             
         }
         
         return self.QuizWalletCell!
       }
     

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.WalletTable.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section) {
        case 0:
            self.OneYearAction()
        case 1:
                self.CallInterstitialAd()
            
            break
        case 2:
            break

        case 3:
            if NetworkManager.sharedInstance.isConnectedToInternet() {
                SKStoreReviewController.requestReviewInCurrentScene()
                   } else {
                       self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                   }
            
            break

        default:
          break
            
        }
    }
    
    
    func alertVu() {
//        let alert = UIAlertController(title: "Alert", message: "Ad not available please try again", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default))
//        self.present(alert, animated: true)
    }
    
    
    
    func CallInterstitialAd() {
        
        if UserDefaults.standard.string(forKey: "AdTime") == nil {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "WalletMoney")+20, forKey: "WalletMoney")
            self.WalletCoin.text =  "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
                        
            let date = Date().addingTimeInterval(20 * 60)
            UserDefaults.standard.setValue(date.string(format: "HH:mm:ss"), forKey: "AdTime")
            
            self.TimerRun()
            
        } else if UserDefaults.standard.string(forKey: "AdTime") ?? "" == "" {
            let date = Date().addingTimeInterval(20 * 60)
            UserDefaults.standard.setValue(date.string(format: "HH:mm:ss"), forKey: "AdTime")
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "WalletMoney")+20, forKey: "WalletMoney")
            self.WalletCoin.text =  "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
            self.TimerRun()
        } else {
            var adtime = UserDefaults.standard.string(forKey: "AdTime")
            let f = DateFormatter()
            f.dateFormat = "HH:mm:ss"
        
            if  f.date(from: Date().string(format: "HH:mm:ss"))! >=  f.date(from: adtime!)! {
                UserDefaults.standard.setValue("", forKey: "AdTime")
                UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "WalletMoney")+20, forKey: "WalletMoney")
                self.TimerRun()
                self.WalletCoin.text =  "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
            } else {
                let alert = UIAlertController(title: "Alert", message: "Try again after few minutes", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
            }
        }
        self.WalletTable.reloadData()
    }
    
    
    
    
    
    
    
    
    private func startOtpTimer() {
        if totalTime > 0 {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            self.WalletTable.reloadData()
        }
    }

    
    @objc func updateTimer() {

        DispatchQueue.main.async {
            self.timerCall()
        }
        
        
        self.timerCall()
                 if totalTime != 0 {
                     totalTime -= 1
                     if totalTime == 0 {
                         self.TimerCell!.TimerTxt.text = ""
                         self.WalletTable.reloadData()
                     }
                 } else {
                     if let timer = self.timer {
                         
                         UserDefaults.standard.setValue("", forKey: "AdTime")
                         
                         timer.invalidate()
                         self.timer = nil
                     }
                 }
             }

             
         func timeFormatted(_ totalSeconds: Int) -> String {
             let seconds: Int = totalSeconds % 60
             let minutes: Int = (totalSeconds / 60) % 60
             return String(format: "%02d:%02d", minutes, seconds)
         }

    
    
    func timerCall() {
        self.TimerCell!.TimerTxt.text = self.timeFormatted(self.totalTime)
        if self.TimerCell!.TimerTxt.text == "00:00" {
            self.TimerCell!.TimerTxt.text = ""
            self.WalletTable.reloadData()
        }
    }
    
    

}


extension Date {
    func compareTimeOnly(to: Date) -> Int {
    let calendar = Calendar.current
    let components2 = calendar.dateComponents([.hour, .minute, .second], from: to)
    let date3 = calendar.date(bySettingHour: components2.hour!, minute: components2.minute!, second: components2.second!, of: self)!

    let seconds = calendar.dateComponents([.second], from: self, to: date3).second!
        
        return seconds
    }
}




// MARK: Pay

extension QuizWalletVC {
    
    func OneYearAction() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            PRODUCT_ID = self.PriductIDArray[0]
//            self.LoaderVu.isHidden = false
              if iapProducts.count > 0 {
                    purchaseProduct(product: iapProducts[0])
              } else {
                  self.view.makeToast("Invalied Product Id", duration: 2.0, position: .bottom)
//                  self.LoaderVu.isHidden = true
              }
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    @IBAction func LifeTimeAction(_ sender: Any) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            PRODUCT_ID = self.PriductIDArray[1]
//            self.LoaderVu.isHidden = false
              if iapProducts1.count > 0 {
                    purchaseProduct(product: iapProducts1[0])
              } else {
//                  self.view.makeToast("Invalied Product Id", duration: 2.0, position: .bottom)
              }
        } else {
//            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    
    
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            
            
            
        if response.products.count > 0 {

            let purchasingProduct = response.products[0] as SKProduct
            self.Product_title.append(purchasingProduct.localizedTitle)
                        
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = purchasingProduct.priceLocale
            
            print(response.products)
            print(numberFormatter.string(from: purchasingProduct.price)!)
            
            if self.Product_title.count == 1 {
                self.iapProducts = response.products
                self.Price1 = numberFormatter.string(from: purchasingProduct.price)!
                self.RemoveAdCell!.RemoveValue.text = self.Price1
            }
                
            if self.Product_title.count == 2 {
                self.iapProducts1 = response.products
                self.Price2 = numberFormatter.string(from: purchasingProduct.price)!
            }

            }
            
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
//                    self.LoaderVu.isHidden = true
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

                    if productID == PRODUCT_ID {
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .full
                        dateFormatter.timeStyle = .none
                        dateFormatter.locale = Locale.current
                        self.transDate = dateFormatter.string(from: trans.transactionDate!)
                        self.transId = trans.transactionIdentifier!
                        UserDefaults.standard.set(true, forKey: "isPurchased")
                        
                        
                        
//                        self.LoaderVu.isHidden = true
                        self.LoaderComplete(LoaderMsg: "Success", LoaderImg: "error")
                        
                        PaymentHistory.sharedInstance.Getpayment(completion: {
                            self.dismiss(animated: true, completion: nil)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                                self.dismiss(animated: true, completion: nil)
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                        
                    }
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
//                    dismiss(animated: false, completion: nil)
//                    self.LoaderComplete(LoaderMsg: "Something went wrong", LoaderImg: "error")
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
//                        self.navigationController?.popViewController(animated: true)
//                    }
                case .restored:
//                    self.LoaderVu.isHidden = true
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
    
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        self.LoaderVu.isHidden = true
        self.LoaderComplete(LoaderMsg: "Success", LoaderImg: "error")
        
        PaymentHistory.sharedInstance.Getpayment(completion: {
            self.dismiss(animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }

    func paymentQueue(_ queue: SKPaymentQueue,
                      restoreCompletedTransactionsFailedWithError error: Error) {
      
    }
    
    
    
    
}
