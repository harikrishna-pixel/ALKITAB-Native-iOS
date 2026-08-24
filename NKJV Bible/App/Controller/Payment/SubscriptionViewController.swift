//
//  SubscriptionViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 13/01/23.
//

import UIKit
import StoreKit

class SubscriptionViewController: UIViewController,SKPaymentTransactionObserver, SKProductsRequestDelegate {
 

    
    @IBOutlet weak var lifetime: UILabel!
    @IBOutlet weak var oneYear: UILabel!
    @IBOutlet weak var GetAd: UILabel!
    @IBOutlet weak var AdsMsg: UILabel!
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    @IBOutlet weak var RestoreBtn:UIButton!
    
    
    @IBOutlet var LoaderVu: UIView!
    
    
    @IBOutlet var OneYearIndicator: UIActivityIndicatorView!
    @IBOutlet var LifeTimeIndicator: UIActivityIndicatorView!
    
    
    var PriductIDArray = [SUBSCRIPTIONID_OneYear , SUBSCRIPTIONID_LifeTime]
    var PRODUCT_ID = ""
    var productID = ""
    
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var iapProducts1 = [SKProduct]()
    
    var transDate = ""
    var transId = ""
    var Themecolor:UIColor?
    
    
    var Price1: String = ""
    var Price2: String = ""
    
    
    var Product_title: Array<String> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.GetAd.text = "Get this Ad free Bible to enjoy the unlimited \n features without any interruptions"
        self.AdsMsg.text = "You can watch a short rewarded video to remove all \n Ads for 3 days"
        
        self.Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        self.LoaderVu.isHidden = true
        
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (self.Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        
        for i in 0..<self.PriductIDArray.count {
            self.PRODUCT_ID = self.PriductIDArray[i]
           self.fetchAvailableProducts()
        }
        
        if self.lifetime.text == "" {
            self.OneYearIndicator.isHidden = false
            self.LifeTimeIndicator.isHidden = false
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    @IBAction func OneYearAction(_ sender: Any) {
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
                  self.view.makeToast("Invalied Product Id", duration: 2.0, position: .bottom)
//                  self.LoaderVu.isHidden = true
              }
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    @IBAction func WatchAdAction(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "InterstitialViewController") as! InterstitialViewController
                vc.LoadAdCatagory = "REWARDED"
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    func LoaderComplete(LoaderMsg:String,LoaderImg:String) {
        let alert = UIAlertController(title: nil, message: LoaderMsg, preferredStyle: .alert)
        let loaderImage = UIImageView(frame: CGRect(x: 15, y: 20, width: 20, height: 20))
        loaderImage.image = UIImage(named: LoaderImg)
        alert.view.addSubview(loaderImage)
        self.present(alert, animated: true, completion: nil)
    }
    
    

    
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
    
    
    @IBAction func Restore(_ sender: Any) {
        self.RestoreBtn.isEnabled = false
        self.restoreData()
        if NetworkManager.sharedInstance.isConnectedToInternet() {
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
}



//PaymentHistory.sharedInstance.Getpayment(completion: {
//    App_Protocol.delegateReader?.paymentStatus()
//    App_Protocol.DelegateSlideCard?.paymentStatus()
//})

// MARK:- Payment
extension SubscriptionViewController {
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        var purchasedItemIDs = [AnyHashable]()
        
        print("purchasedItemIDs :",purchasedItemIDs)
        
        if purchasedItemIDs.count == 0 {
            self.LoaderComplete(LoaderMsg: "Something went wrong", LoaderImg: "error")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                self.dismiss(animated: false, completion: nil)
            }
        }
        
      for transaction in queue.transactions {
            let productID = transaction.payment.productIdentifier
            purchasedItemIDs.append(productID)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
      return true
    }
    
    
    
    //StoreKit protocol method. Called when the AppStore responds
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        var item = response.products
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
                        self.SetPaymentDAte()
                        self.transId = trans.transactionIdentifier!
                        UserDefaults.standard.set(true, forKey: "isPurchased")
                    }
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
//                    dismiss(animated: false, completion: nil)
//                    self.LoaderComplete(LoaderMsg: "Something went wrong", LoaderImg: "error")
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
//                        self.navigationController?.popViewController(animated: true)
//                    }
                case .restored:
                    self.LoaderComplete(LoaderMsg: "Success", LoaderImg: "error")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    self.SetPaymentDAte()
                    dismiss(animated: false, completion: nil)
                default: break
                }
            }
        }
    }
    
    func SetPaymentDAte(){
        PaymentHistory.sharedInstance.Getpayment(completion: {
            App_Protocol.delegateReader?.paymentStatus()
            App_Protocol.DelegateSlideCard?.paymentStatus()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                ImageAppProtocol.ImageTxtEditDelegate?.CheckPay()
            }
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ReaderViewController") as! ReaderViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func restoreData() {
        let parameters = ["dev_app_id":push_appid,
                          "udid":Udid,
                          "dev_type":dev_id_type,] as [String : AnyObject]

             NetworkManager.sharedInstance.requestPOSTTestData(urlString: GET_SUBSCRIPTION_RECEPT_DATA,params:parameters,  completion:
                 { (resultDictionary, error) -> () in

                 })
        
        DispatchQueue.main.async {
            self.RestoreBtn.isEnabled = true
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
                self.oneYear.text = self.Price1
                self.OneYearIndicator.isHidden = true
            }
                
            if self.Product_title.count == 2 {
                self.iapProducts1 = response.products
                self.Price2 = numberFormatter.string(from: purchasingProduct.price)!
                self.lifetime.text = self.Price2
                self.LifeTimeIndicator.isHidden = true
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
                
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+12) {
//                    self.LoaderVu.isHidden = true
//                }
                
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
        
}


