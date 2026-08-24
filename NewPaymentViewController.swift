//
//  NewPaymentViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 26/05/23.
//

import UIKit
import StoreKit

class NewPaymentViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    
    @IBOutlet weak var yearVu: UIView!
    @IBOutlet weak var LifeTimeVu: UIView!
    @IBOutlet weak var YearBuyVu: UIView!
    @IBOutlet weak var lifeBuyVu: UIView!
    @IBOutlet weak var sixMonthBuyVu: UIView!
    @IBOutlet weak var sixMonthVu: UIView!
    
    @IBOutlet var LoaderVu: UIView!
    
    @IBOutlet weak var lifetime: UILabel!
    @IBOutlet weak var oneYear: UILabel!
    @IBOutlet weak var sixMonth: UILabel!
    
    @IBOutlet weak var RealLifetimePrice: UILabel!
    @IBOutlet weak var RealOneyearPrice: UILabel!
    @IBOutlet weak var RealsixMonthPrice: UILabel!
    
    @IBOutlet weak var RestoreBtn:UIButton!
    
    @IBOutlet var OneYearIndicator: UIActivityIndicatorView!
    @IBOutlet var LifeTimeIndicator: UIActivityIndicatorView!
    @IBOutlet var SixmonthIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var CloseConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var oneyearOfferImage: UIImageView!
    @IBOutlet weak var lifetimeOfferImage: UIImageView!
    @IBOutlet weak var six_monthOfferImag: UIImageView!
    
    
    var PriductIDArray = [SUBSCRIPTIONID_Six_month, SUBSCRIPTIONID_OneYear, SUBSCRIPTIONID_LifeTime]
    
    var Product_title: Array<String> = []
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var iapProducts1 = [SKProduct]()
    var iapProducts2 = [SKProduct]()
    var transDate = ""
    var transId = ""
    var Price1: String = UserDefaults.standard.string(forKey: "PriceTag1") ?? ""
    var Price2: String = UserDefaults.standard.string(forKey: "PriceTag2") ?? ""
    var Price3: String = UserDefaults.standard.string(forKey: "PriceTag3") ?? ""
    var PRODUCT_ID = ""
    var productID = ""
    
    let ANIMATION_SPEED = 0.2
    var CurrentIndexPath:Int = 0
    lazy var PayDays:[Int] = [4,4,4,4,4,4,4] //[4,5,6,7,8,9,10]
    
    var timer: Timer?
    var totalTime = 6
    
    var productIDIndex:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        if NetworkManager.sharedInstance.isConnectedToInternet() {
            GetAppInfo.shared.CallParams()
        }
        
        
        self.lifetime.isHidden = (SUBSCRIPTIONID_LifeTime == "" ? true:false)
        self.oneYear.isHidden = (SUBSCRIPTIONID_OneYear == "" ? true:false)
        self.sixMonth.isHidden = (SUBSCRIPTIONID_OneYear == "" ? true:false)
    
        
        self.yearVu.ViewShadow(6, color: .black)
        self.LifeTimeVu.ViewShadow(6, color: .black)
        self.sixMonthVu.ViewShadow(6, color: .black)
        
        self.YearBuyVu.layer.cornerRadius = 10
        self.lifeBuyVu.layer.cornerRadius =  10
        self.sixMonthBuyVu.layer.cornerRadius =  10
        
        
        SKPaymentQueue.default().add(self)
                
        
        self.CloseConstrain.constant = (StatusbarHeight > 20 ? 60:40)
        
        self.sixMonth.text = UserDefaults.standard.string(forKey: "PriceTag1") ?? ""
        self.oneYear.text = UserDefaults.standard.string(forKey: "PriceTag2") ?? ""
        self.lifetime.text = UserDefaults.standard.string(forKey: "PriceTag3") ?? ""

        
        if self.lifetime.text! == "" {
            self.SixmonthIndicator.isHidden = false
            self.OneYearIndicator.isHidden = false
            self.LifeTimeIndicator.isHidden = false
 
            
        } else {
            self.SixmonthIndicator.isHidden = true
            self.OneYearIndicator.isHidden = true
            self.LifeTimeIndicator.isHidden = true
        }
        
        
        if sub_identifier_six_month_value != "" {
            self.six_monthOfferImag.image = UIImage(named: sub_identifier_six_month_value)
        }
        
        if sub_identifier_oneyear_value != "" {
            self.oneyearOfferImage.image = UIImage(named: sub_identifier_oneyear_value)
        }
        
        if sub_identifier_lifetime_value != "" {
            self.lifetimeOfferImage.image = UIImage(named: sub_identifier_lifetime_value)
        }
        
        
        
        if offer_enabled != "1" {
            self.six_monthOfferImag.isHidden = true
            self.oneyearOfferImage.isHidden = true
            self.lifetimeOfferImage.isHidden = true
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
     
    
    
    
//    override func viewWillAppear(_ animated: Bool) {
//
//        self.resetValue()
//
//        if UserDefaults.standard.string(forKey: "PriceTag1") ?? "" == "" {
//            if NetworkManager.sharedInstance.isConnectedToInternet() {
//                for i in 0..<self.PriductIDArray.count {
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
//                        self.PRODUCT_ID = self.PriductIDArray[i]
//                        self.fetchAvailableProducts()
//                    }
//                }
//            }
//        }
//
//    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: "PriceTag1") ?? "" == "" {
            if NetworkManager.sharedInstance.isConnectedToInternet() {
                if IS_SUBSCRIPTION_ENABLE == 1 {
                    self.Callapi(i:0)
                }
            }
        }
    }
       
    
    
    
    func Callapi(i:Int) {
        if i <= 2 {
            self.callingApi(i:i)
        }
    }
    
    func callingApi(i:Int) {
        self.PRODUCT_ID = self.PriductIDArray[i]
        self.fetchAvailableProducts()
    }
    
    
    
    
    
    
    
    func resetValue() {
        if offer_enabled == "1" {
            DispatchQueue.main.async {
                                 
                var Symbol: String = ""
                if self.Price1 != "" && sub_identifier_six_month_value != "" {
                    let R1:Int = self.StrikeCalculation(Value: Float(self.Price1.strippedtext) ?? 0.0, percentage: Float(sub_identifier_six_month_value) ?? 0.0) //Float(self.Price1.strippedtext)!*2
                    
                    Symbol = self.Price1.replacingOccurrences(of: self.Price1.strippedtext, with: "")
                    
                    let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "\(Symbol)\(R1).00")
                        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
                    
                    self.RealsixMonthPrice.attributedText = attributeString
                    
                }
                if self.Price2 != "" && sub_identifier_oneyear_value != "" {
                    let R1:Int = self.StrikeCalculation(Value: Float(self.Price2.strippedtext) ?? 0.0, percentage: Float(sub_identifier_oneyear_value) ?? 0.0)
                    
                    let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "\(Symbol)\(R1).00")
                        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
                    
                    self.RealOneyearPrice.attributedText = attributeString
                }
                
                
                if self.Price3 != "" && sub_identifier_lifetime_value != "" {
                    let R1:Int = self.StrikeCalculation(Value: Float(self.Price3.strippedtext) ?? 0.0, percentage: Float(sub_identifier_lifetime_value) ?? 0.0)
                     
                    let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "\(Symbol)\(R1).00")
                        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
                    
                    self.RealLifetimePrice.attributedText = attributeString
                }
            }
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

}


extension NewPaymentViewController {
    
    
    @IBAction func SixmonthAction(_ sender: Any) {
        self.sixmonth()
    }
    
    
    func sixmonth(_ enable:Bool = false) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            PRODUCT_ID = self.PriductIDArray[0]
            self.LoaderVu.isHidden = false
              if iapProducts.count > 0 {
                    purchaseProduct(product: iapProducts[0])
              } else {
                  self.Callapi(i:0)
                  self.LoaderVu.isHidden = true
                  self.view.makeToast("Please wait for few secs..", duration: 2.0, position: .bottom)
                  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) {
                      if enable {
                          self.view.makeToast("Poor Network Connection", duration: 2.0, position: .bottom)
                      } else {
                          self.sixmonth(true)
                      }
                      
                  }
              }
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    
    @IBAction func OneYearAction(_ sender: Any) {
        self.OneYear()
    }
    
    
    
    func OneYear(_ enable:Bool = false) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            PRODUCT_ID = self.PriductIDArray[1]
            self.LoaderVu.isHidden = false
              if iapProducts1.count > 0 {
                    purchaseProduct(product: iapProducts1[0])
              } else {
                  self.Callapi(i:0)
                  self.LoaderVu.isHidden = true
                  self.view.makeToast("Please wait for few secs..", duration: 2.0, position: .bottom)
                  
                  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) {
                      if enable {
                          self.view.makeToast("Poor Network Connection", duration: 2.0, position: .bottom)
                      } else {
                          self.OneYear(true)
                      }
                  }
              }
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
        
    }
    
    
    

    @IBAction func LifeTimeAction(_ sender: Any) {
        self.lifetimeCall()
    }
    
    
    func lifetimeCall(_ enable:Bool = false) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            PRODUCT_ID = self.PriductIDArray[2]
            self.LoaderVu.isHidden = false
              if iapProducts2.count > 0 {
                    purchaseProduct(product: iapProducts2[0])
              } else {
                  self.Callapi(i:0)
                  self.LoaderVu.isHidden = true
                  self.view.makeToast("Please wait for few secs..", duration: 2.0, position: .bottom)
                  
                  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) {
                      if enable {
                          self.view.makeToast("Poor Network Connection", duration: 2.0, position: .bottom)
                      } else {
                          self.lifetimeCall(true)
                      }
                  }
              }
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
         
    
    
    
    
        
    @IBAction func Back(_ sender: Any) {
        let today = Date()
        let nextDate = Calendar.current.date(byAdding: .day, value: Int(offer_days)!, to: today)
        UserDefaults.standard.setValue(nextDate!.string(format: "dd-MM-yyyy"), forKey: "PayCallDate")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

    @IBAction func Restore(_ sender: Any) {
        self.RestoreBtn.isEnabled = false
        self.restoreData()
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            self.Loader(LoaderMsg: "Please wait...")
                SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+10.0) {
            self.dismiss(animated: false, completion: nil)
        }
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
    
    
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      restoreCompletedTransactionsFailedWithError error: Error) {
        
        print("error :",error.localizedDescription)
        
    }
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        var purchasedItemIDs = [AnyHashable]()
        
        if purchasedItemIDs.count == 0 {
            dismiss(animated: false, completion: nil)
        }
        self.LoaderComplete(LoaderMsg: "Something went wrong", LoaderImg: "error")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
            self.dismiss(animated: false, completion: nil)
        }
        
      for transaction in queue.transactions {
            let productID = transaction.payment.productIdentifier
            purchasedItemIDs.append(productID)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
      return true
    }
    
    
    
//    //StoreKit protocol method. Called when the AppStore responds
//    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
//        var item = response.products
//    }
    
    
    
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
                        self.LoaderVu.isHidden = true
                    }
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    dismiss(animated: false, completion: nil)
                    self.LoaderComplete(LoaderMsg: "Something went wrong", LoaderImg: "error")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                        self.dismiss(animated: false, completion: nil)
                        self.LoaderVu.isHidden = true
                    }
                         
                case .restored:
                    self.LoaderComplete(LoaderMsg: "Success", LoaderImg: "error")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    self.SetPaymentDAte()
                    dismiss(animated: false, completion: nil)
                    self.LoaderVu.isHidden = true
                default: break
                }
            }
        }
    }
    
    func SetPaymentDAte(){
        PaymentHistory.sharedInstance.Getpayment(completion: {
            App_Protocol.delegateReader?.paymentStatus()
            App_Protocol.DelegateSlideCard?.paymentStatus()
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func restoreData() {
        let parameters = ["dev_app_id":push_appid,
                          "udid":Udid,
                          "dev_type":dev_id_type,] as [String : AnyObject]

             NetworkManager.sharedInstance.requestPOSTTestData(urlString: GET_SUBSCRIPTION_RECEPT_DATA,params:parameters,  completion:
                 { (resultDictionary, error) -> () in

                 })
        
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
           
            
            if self.Product_title.count == 1 {
                
                if self.Price1 == "" {
                    self.iapProducts = response.products
                    self.Price1 = numberFormatter.string(from: purchasingProduct.price) ?? ""
                    
                    self.sixMonth.text = self.Price1
                    self.SixmonthIndicator.isHidden = true
                    
                    UserDefaults.standard.setValue(self.Price1, forKey: "PriceTag1")
                    
                } else {
                    UserDefaults.standard.setValue(numberFormatter.string(from: purchasingProduct.price) ?? "", forKey: "PriceTag1")
                    self.iapProducts = response.products
                    self.SixmonthIndicator.isHidden = true
                }
                
            }
            
            if self.Product_title.count == 2 {
                
                if self.Price2 == "" {
                    self.iapProducts1 = response.products
                    self.Price2 = numberFormatter.string(from: purchasingProduct.price) ?? ""
                
                    self.oneYear.text = self.Price2
                    self.OneYearIndicator.isHidden = true
                    
                    UserDefaults.standard.setValue(self.Price2, forKey: "PriceTag2")
                    
                } else {
                    
                    UserDefaults.standard.setValue(numberFormatter.string(from: purchasingProduct.price) ?? "", forKey: "PriceTag2")
                    self.iapProducts1 = response.products
                    self.OneYearIndicator.isHidden = true
                }
                
            }
            
            
            if self.Product_title.count == 3 {
                
                if self.Price3 == "" {
                    self.iapProducts2 = response.products
                    self.Price3 = numberFormatter.string(from: purchasingProduct.price) ?? ""
                    self.lifetime.text = self.Price3
                                        
                    self.LifeTimeIndicator.isHidden = true
                    
                    UserDefaults.standard.setValue(self.Price3, forKey: "PriceTag3")
                    
                } else {
                    UserDefaults.standard.setValue(numberFormatter.string(from: purchasingProduct.price) ?? "", forKey: "PriceTag3")
                    self.iapProducts2 = response.products
                    self.LifeTimeIndicator.isHidden = true
                }
                self.resetValue()
            }
            
            self.productIDIndex = self.productIDIndex+1
            self.Callapi(i:self.productIDIndex)
            
            }
            
        }
        
    }
    
    

    
    func StrikeCalculation(Value:Float, percentage:Float) -> Int {
        return Int((Value/(100-percentage))*100)
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
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+10) {
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
    
    
    func Loader(LoaderMsg:String) {
        let alert = UIAlertController(title: nil, message: LoaderMsg, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func LoaderComplete(LoaderMsg:String,LoaderImg:String) {
        let alert = UIAlertController(title: nil, message: LoaderMsg, preferredStyle: .alert)
        let loaderImage = UIImageView(frame: CGRect(x: 15, y: 20, width: 20, height: 20))
        loaderImage.image = UIImage(named: LoaderImg)
        alert.view.addSubview(loaderImage)
        self.present(alert, animated: true, completion: nil)
    }
    

    

    
}
