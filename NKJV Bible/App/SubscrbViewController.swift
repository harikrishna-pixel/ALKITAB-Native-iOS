//
//  SubscrbViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 10/04/23.
//

import UIKit
import StoreKit
import Reachability


class SubscrbViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SKPaymentTransactionObserver, SKProductsRequestDelegate, UnituAdCall {
     
    @IBOutlet var Pagecontrol: UIPageControl!
    @IBOutlet weak var Watch: UIView!
    @IBOutlet var PayFeatureCollection: UICollectionView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var GetAd: UILabel!
    @IBOutlet weak var AdsMsg: UILabel!
    @IBOutlet var LoaderVu: UIView!
    @IBOutlet var Logo: UIImageView!
    

    @IBOutlet weak var RestoreBtn:UIButton!
    @IBOutlet weak var lifetime: UILabel!
    @IBOutlet weak var oneYear: UILabel!
    @IBOutlet weak var sixMonth: UILabel!
    
    
    @IBOutlet weak var lifetimeBtn: UIButton!
    @IBOutlet weak var oneYearBtn: UIButton!
    @IBOutlet weak var sixMonthBtn: UIButton!
    
    @IBOutlet var OneYearIndicator: UIActivityIndicatorView!
    @IBOutlet var LifeTimeIndicator: UIActivityIndicatorView!
    @IBOutlet var sixMonthIndicator: UIActivityIndicatorView!
    
    @IBOutlet var RealLifetimePrice: UILabel!
    @IBOutlet var RealOneyearPrice: UILabel!
    @IBOutlet var RealsixMonthPrice: UILabel!
    
    
    @IBOutlet weak var oneyearOfferImage: UIImageView!
    @IBOutlet weak var lifetimeOfferImage: UIImageView!
    @IBOutlet weak var six_monthOfferImag: UIImageView!
        
    
    
    @IBOutlet weak var AlertMessage:UILabel!
    @IBOutlet weak var AlertTitle: UILabel!
    @IBOutlet weak var AlertScreenShow: UIView!
    @IBOutlet weak var Okbtn: UIButton!
    
    @IBOutlet weak var lifetimeView: UIView!
    @IBOutlet weak var oneYearView: UIView!
    @IBOutlet weak var sixMonthView: UIView!
    
    
    var PriductIDArray = [SUBSCRIPTIONID_Six_month , SUBSCRIPTIONID_OneYear, SUBSCRIPTIONID_LifeTime]
    
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
    var presentVu = false
    

    var productIDIndex:Int = 0
    
    
    let ANIMATION_SPEED = 0.2
    var CurrentIndexPath:Int = 0
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    
    var AvailableList:Array<String> = [ APPNAME, "Make an image of your favorite verse", "Audio track with easy navigation", "Mark where you left & collect important points", "Elegant low-light reading experience" ]
    
    var colorList:Array<String> = ["1C46B2", "B264E6", "63C7DC", "84881F", "5B5B51"]
    var PaymentCell: PaymentFeatureCell?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        App_Protocol.UnituAdCallDelegate = self
        
        self.Pagecontrol.currentPage = 0
        self.Pagecontrol.numberOfPages = colorList.count
        self.Pagecontrol.currentPageIndicatorTintColor = Themecolor
        
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            GetAppInfo.shared.CallParams()
        } 
        
        
        RestoreClass.shared.SourceVC = self
        
        self.sixMonthView.ViewShadow(6, color: .black)
        self.lifetimeView.ViewShadow(6, color: .black)
        self.oneYearView.ViewShadow(6, color: .black)
        
        
        self.startTimer()
        
        self.AlertMessage.text = "Rewards Claimed!"
        self.AlertTitle.text = "Enjoy ad-free reward for 3 days from now!"
        self.Okbtn.backgroundColor = Themecolor
        self.Okbtn.layer.cornerRadius = self.Okbtn.frame.height/2
        
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.Logo!, colorVu: Themecolor)
        
        
        self.GetAd.text = "Get this Ad free Bible to enjoy the unlimited \n features without any interruptions"
        self.AdsMsg.text = "You can watch a short rewarded video to remove all \n Ads for 3 days"
        

        self.sixMonthView.isHidden = (SUBSCRIPTIONID_Six_month == "" ? true:false)
        self.oneYearView.isHidden = (SUBSCRIPTIONID_OneYear == "" ? true:false)
        self.lifetime.isHidden = (SUBSCRIPTIONID_LifeTime == "" ? true:false)
        
        
        self.six_monthOfferImag.isHidden = (SUBSCRIPTIONID_Six_month == "" ? true:false)
        self.oneyearOfferImage.isHidden = (SUBSCRIPTIONID_OneYear == "" ? true:false)
        self.lifetimeOfferImage.isHidden = (SUBSCRIPTIONID_LifeTime == "" ? true:false)
        
        
        if offer_enabled != "1" {
            self.six_monthOfferImag.isHidden = true
            self.oneyearOfferImage.isHidden = true
            self.lifetimeOfferImage.isHidden = true
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
        
        
        
        self.Watch.layer.cornerRadius = 6
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        self.BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)

        self.Watch.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        self.Watch.layerGradient()
        
        
        let cellSize = CGSize(width:CGFloat(ScreenWidth-32) , height:90)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.PayFeatureCollection.setCollectionViewLayout(layout, animated: true)
        
         
        
        self.sixMonth.text = UserDefaults.standard.string(forKey: "PriceTag1") ?? ""
        self.oneYear.text = UserDefaults.standard.string(forKey: "PriceTag2") ?? ""
        self.lifetime.text = UserDefaults.standard.string(forKey: "PriceTag3") ?? ""
                
        
        if self.lifetime.text! == "" {
            self.sixMonthIndicator.isHidden = false
            self.OneYearIndicator.isHidden = false
            self.LifeTimeIndicator.isHidden = false

        } else {
            self.sixMonthIndicator.isHidden = true
            self.OneYearIndicator.isHidden = true
            self.LifeTimeIndicator.isHidden = true
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.resetValue()
        
//        if UserDefaults.standard.string(forKey: "PriceTag3") ?? "" == "" {
            if NetworkManager.sharedInstance.isConnectedToInternet() {
                if IS_SUBSCRIPTION_ENABLE == 1 {
                    self.iapProducts = [SKProduct]()
                    self.iapProducts1 = [SKProduct]()
                    self.iapProducts2 = [SKProduct]()
                    self.Callapi(i:0)
                    self.EnableBtn(enableStatus: false)
                }
            }
//        }
//        
        
        
        
        if self.lifetime.text != "" {
            self.OneYearIndicator.isHidden = true
        }
        
        if self.oneYear.text != "" {
            self.LifeTimeIndicator.isHidden = true
        }
        
        if self.sixMonth.text != "" {
            self.sixMonthIndicator.isHidden = true
        }
        
        
    }
    
    
    func EnableBtn(enableStatus:Bool) {
        self.lifetimeBtn.isEnabled = enableStatus
        self.oneYearBtn.isEnabled = enableStatus
        self.sixMonthBtn.isEnabled = enableStatus
    }
    
    
    
    func Callapi(i:Int) {
        if productIDIndex <= 2 {
            self.callingApi(i: i)
            self.resetValue()
        }
    }
    
    func callingApi(i:Int) {
        self.PRODUCT_ID = self.PriductIDArray[i]
        self.fetchAvailableProducts()
    }
    
    
    
    
    
    func checkNetworkStatus() {
        if IS_SUBSCRIPTION_ENABLE == 1 {
            self.Callapi(i:0)
        }
    }
        
    
    
    
        
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.AvailableList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        self.PaymentCell = (self.PayFeatureCollection.dequeueReusableCell(withReuseIdentifier: "PaymentFeatureCell", for: indexPath) as! PaymentFeatureCell)
        
        self.PaymentCell?.layer.cornerRadius = 15
        self.PaymentCell?.layer.borderColor = Colorhex.shared.hexStringToUIColor(hex:  colorList[indexPath.row]).cgColor
        self.PaymentCell?.layer.borderWidth = 1.0
        self.PaymentCell?.backgroundColor = Colorhex.shared.hexStringToUIColor(hex:  colorList[indexPath.row]).withAlphaComponent(0.4)
        
        
        if  indexPath.row < AvailableList.count {
            self.PaymentCell!.Features.text = AvailableList[indexPath.row]
            self.PaymentCell!.Image.image = UIImage(named: "card-\(indexPath.row+1).png")
        }
        
        self.PaymentCell!.CandleiMg.isHidden = (indexPath.row == AvailableList.count-1 ? false:true)
        
        return self.PaymentCell!
    }
    
    
}



//

// MARK:  Payment 
extension SubscrbViewController {
    
    
    
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
                  self.checkNetworkStatus()
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
                  self.checkNetworkStatus()
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
                  self.checkNetworkStatus()
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
    
    
    
    
    @IBAction func WatchAdAction(_ sender: Any) {
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
//            AdmobManager.shared.IronSource_Reward_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!, RewardAd: "WatchAd")
            AdmobManager.shared.IronSource_Reward_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!, RewardAd: "WatchAd")
            } else {
                self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
            }
    }
    
    
    func NoAdClosed() {
        self.view.makeToast("Ad not Available", duration: 2.0, position: .bottom)
        App_Protocol.delegateReader?.paymentStatus()
        App_Protocol.DelegateSlideCard?.paymentStatus()
    }
    
    
    func unityAdOpen() {
        self.LoaderVu.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3.5) {
            self.LoaderVu.isHidden = true
        }
        
        AdmobManager.shared.IronSource_Reward_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!, RewardAd: "SubscrbViewController")
    }
    
    
    
    @IBAction func Ok_Action(_ sender: Any) {
        
        App_Protocol.delegateReader?.paymentStatus()
        App_Protocol.DelegateSlideCard?.paymentStatus()
        self.AlertScreenShow.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func AdDidClosed() {
        self.LoaderVu.isHidden = true
        self.AlertScreenShow.isHidden = false
        CoreDataModel.sharedInstance.deleteAllData(CDPaymentdateAPI)
        CoreDataModel.sharedInstance.coreDataInsertEndDate(CDPaymentdateAPI, endDate: Date.tomorrow.string(format: "dd-MM-yyyy"))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
            App_Protocol.delegateReader?.paymentStatus()
            App_Protocol.DelegateSlideCard?.paymentStatus()
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
    
    
    @IBAction func Restore(_ sender: Any) {
        self.RestoreBtn.isEnabled = false
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            DispatchQueue.main.async {
                self.restoreData()
            }
            self.Loader(LoaderMsg: "Please wait...")
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func startTimer() {

        let timer =  Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.scrollToNextCell), userInfo: nil, repeats: true)


       }
    
    
//    @objc func scrollToNextCell(){
//        print("startTimer()")
//      }
    
    
    @objc func scrollToNextCell(_ timer1: Timer) {

        if let coll  = PayFeatureCollection {
            for cell in coll.visibleCells {
                let indexPath: IndexPath? = coll.indexPath(for: cell)
                if ((indexPath?.row)! < AvailableList.count - 1){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)

                    coll.scrollToItem(at: indexPath1!, at: .right, animated: true)
                    self.Pagecontrol.currentPage = indexPath1!.row
                }
                else{
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                    coll.scrollToItem(at: indexPath1!, at: .left, animated: true)
                    self.Pagecontrol.currentPage = 0
                }

            }
        }
    }
    
    
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      restoreCompletedTransactionsFailedWithError error: Error) {
        
    }
    
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        var purchasedItemIDs = [AnyHashable]()
        
        
        if purchasedItemIDs.count == 0 {
            dismiss(animated: false, completion: nil)
            self.LoaderComplete(LoaderMsg: "Something went wrong", LoaderImg: "error")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                self.dismiss(animated: false, completion: nil)
            }
        }
         
        
      for transaction in queue.transactions {
            let productID = transaction.payment.productIdentifier
            purchasedItemIDs.append(productID)
        }
        
        PaymentHistory.sharedInstance.Getpayment(completion: {
            App_Protocol.delegateReader?.paymentStatus()
            App_Protocol.DelegateSlideCard?.paymentStatus()
        })
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
                        self.LoaderVu.isHidden = true
                        
                        RestoreClass.shared.paidResult(productID: productID, transId: self.transId)
                        
                    }
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    dismiss(animated: false, completion: nil)
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
    
    func SetPaymentDAte() {
        PaymentHistory.sharedInstance.Getpayment(completion: {
            App_Protocol.delegateReader?.paymentStatus()
            App_Protocol.DelegateSlideCard?.paymentStatus()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                ImageAppProtocol.ImageTxtEditDelegate?.CheckPay()
            }
        })
        if !presentVu {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ReaderViewController") as! ReaderViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
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
            
            
            if self.iapProducts.count == 0 {
                
//                if self.Price1 == "" {
                    self.iapProducts = response.products
                    self.Price1 = numberFormatter.string(from: purchasingProduct.price) ?? ""
                    self.sixMonth.text = self.Price1
                    self.sixMonthIndicator.isHidden = true
                    
                    UserDefaults.standard.setValue(self.Price1, forKey: "PriceTag1")
                    
//                } else {
//                    UserDefaults.standard.setValue(numberFormatter.string(from: purchasingProduct.price)!, forKey: "PriceTag1")
//                    self.iapProducts = response.products
//                    self.sixMonthIndicator.isHidden = true
//                }
                
            }
            
            else if self.iapProducts1.count == 0 {
                
//                if self.Price2 == "" {
                    self.iapProducts1 = response.products
                    self.Price2 = numberFormatter.string(from: purchasingProduct.price) ?? ""
                    self.oneYear.text = self.Price2
                    self.OneYearIndicator.isHidden = true
                
                    UserDefaults.standard.setValue(self.Price2, forKey: "PriceTag2")
                    
//                } else {
//                    
//                    UserDefaults.standard.setValue(numberFormatter.string(from: purchasingProduct.price)!, forKey: "PriceTag2")
//                    self.iapProducts1 = response.products
//                    self.OneYearIndicator.isHidden = true
//                }
                
            }
            

            else if self.iapProducts2.count == 0 {
                
//                if self.Price3 == "" {
                    self.iapProducts2 = response.products
                    self.Price3 = numberFormatter.string(from: purchasingProduct.price) ?? ""
                    self.lifetime.text = self.Price3
                    self.LifeTimeIndicator.isHidden = true
                    
                    UserDefaults.standard.setValue(self.Price3, forKey: "PriceTag3")
                    
//                } else {
//                    UserDefaults.standard.setValue(numberFormatter.string(from: purchasingProduct.price)!, forKey: "PriceTag3")
//                    self.iapProducts2 = response.products
//                    self.LifeTimeIndicator.isHidden = true
//                }
                
            }
            

            }
            
            self.productIDIndex = self.productIDIndex+1
            
            if self.productIDIndex <= 2  {
                DispatchQueue.main.async {
                    self.Callapi(i:self.productIDIndex)
                }
            } else {
                self.EnableBtn(enableStatus: true)
            }
            self.resetValue()
            
        }
        
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




extension SubscrbViewController {

    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let pageWidth: Float = Float(self.PayFeatureCollection.bounds.width) // width + space

        let currentOffset = CGFloat(scrollView.contentOffset.x)
        let targetOffset = targetContentOffset.pointee.x
        var newTargetOffset: Float = 0

        if targetOffset > currentOffset {
            newTargetOffset = ceilf(Float(currentOffset) / pageWidth) * pageWidth
        } else {
            newTargetOffset = floorf(Float(currentOffset) / pageWidth) * pageWidth
        }
        if newTargetOffset < 0 {
            newTargetOffset = 0
        } else if CGFloat(newTargetOffset) > scrollView.contentSize.width {
            newTargetOffset = Float(scrollView.contentSize.width)
        }

        targetContentOffset.pointee.x = currentOffset
        scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: 0), animated: true)

        let index = Int((newTargetOffset / pageWidth)+0.01)

        let cell = self.PayFeatureCollection.cellForItem(at: IndexPath(item: index, section: 0))
            UIView.animate(withDuration: ANIMATION_SPEED, animations: {
                cell?.transform = CGAffineTransform.identity
                self.CurrentIndexPath = index
                self.Pagecontrol.currentPage = self.CurrentIndexPath

            })
       }
    
}

    
    
  




extension UIView {
    func layerGradient() {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.frame.origin = CGPointMake(0.0,0.0)
        layer.cornerRadius = 6

        let color0 = UIColor(red:250.0/255, green:250.0/255, blue:250.0/255, alpha:0.3).cgColor
        let color1 = UIColor(red:200.0/255, green:200.0/255, blue: 200.0/255, alpha:0.1).cgColor
        let color2 = UIColor(red:150.0/255, green:150.0/255, blue: 150.0/255, alpha:0.1).cgColor
        let color3 = UIColor(red:100.0/255, green:100.0/255, blue: 100.0/255, alpha:0.1).cgColor
        let color4 = UIColor(red:50.0/255, green:50.0/255, blue:50.0/255, alpha:0.1).cgColor
        let color5 = UIColor(red:0.0/255, green:0.0/255, blue:0.0/255, alpha:0.1).cgColor
        let color6 = UIColor(red:150.0/255, green:150.0/255, blue:150.0/255, alpha:0.1).cgColor

        layer.colors = [color0,color1,color2,color3,color4,color5,color6]
        self.layer.insertSublayer(layer, at: 0)
    }
}
