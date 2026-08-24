//
//  PaymentPopupVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 21/04/23.
//

import UIKit
import StoreKit

class PaymentPopupVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    @IBOutlet weak var yearVu: UIView!
    @IBOutlet weak var LifeTimeVu: UIView!
    @IBOutlet weak var YearBuyVu: UIView!
    @IBOutlet weak var lifeBuyVu: UIView!
    @IBOutlet weak var MainView: UIView!
    @IBOutlet var LoaderVu: UIView!
    
    @IBOutlet var PayFeatureCollection: UICollectionView!
    @IBOutlet var Pagecontrol: UIPageControl!
    
    
    @IBOutlet weak var lifetime: UILabel!
    @IBOutlet weak var oneYear: UILabel!
    
    @IBOutlet weak var RealLifetimePrice: UILabel!
    @IBOutlet weak var RealOneYearPrice: UILabel!
    
    
    @IBOutlet var OneYearIndicator: UIActivityIndicatorView!
    @IBOutlet var LifeTimeIndicator: UIActivityIndicatorView!
    
    
    var timer: Timer?
    var PaymentCell: PayCell?
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    var AvailableList:Array<String> = [ APPNAME, "Make an image of your favorite verse", "Audio track with easy navigation", "Mark where you left & collect important points", "Elegant low-light reading experience" ]
        
    
    
    var PriductIDArray = [SUBSCRIPTIONID_Six_month, SUBSCRIPTIONID_OneYear]
    
    var Product_title: Array<String> = []
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var iapProducts1 = [SKProduct]()
    var transDate = ""
    var transId = ""
    var Price1: String = ""
    var Price2: String = ""
    var PRODUCT_ID = ""
    var productID = ""
    
    let ANIMATION_SPEED = 0.2
    var CurrentIndexPath:Int = 0
    lazy var PayDays:[Int] = [4,4,4,4,4,4,4] //[4,5,6,7,8,9,10]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.yearVu.ViewShadow(6, color: .black)
        self.LifeTimeVu.ViewShadow(6, color: .black)
        
        self.MainView.layer.cornerRadius = 10
        self.YearBuyVu.layer.cornerRadius = 10
        self.lifeBuyVu.layer.cornerRadius =  10
        
        self.Pagecontrol.currentPage = 0
        self.Pagecontrol.numberOfPages = AvailableList.count
        self.Pagecontrol.currentPageIndicatorTintColor = Themecolor
        self.startTimer()
        
        
        
        
        let cellSize = CGSize(width:CGFloat(ScreenWidth-100) , height:80)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.PayFeatureCollection.setCollectionViewLayout(layout, animated: true)
        
        
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
    

    override func viewDidDisappear(_ animated: Bool) {
        timer!.invalidate()
        self.timer = nil
    }
   
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.AvailableList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        self.PaymentCell = (self.PayFeatureCollection.dequeueReusableCell(withReuseIdentifier: "PayCell", for: indexPath) as! PayCell)
        
        self.PaymentCell?.layer.cornerRadius = 15
        self.PaymentCell?.layer.borderWidth = 1.0
        if  indexPath.row < AvailableList.count {
            self.PaymentCell!.Features.text = AvailableList[indexPath.row]
        }

        
        return self.PaymentCell!
    }
    
    
    
    func startTimer() {
        self.timer =  Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.scrollToNextCell), userInfo: nil, repeats: true)
       }
    
    
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
    
    
}



extension PaymentPopupVC {
    
    @IBAction func OneYearAction(_ sender: Any) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            PRODUCT_ID = self.PriductIDArray[0]
            self.LoaderVu.isHidden = false
              if iapProducts.count > 0 {
                    purchaseProduct(product: iapProducts[0])
              } else {
                  self.LoaderVu.isHidden = true
              }
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    @IBAction func LifeTimeAction(_ sender: Any) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            PRODUCT_ID = self.PriductIDArray[1]
            self.LoaderVu.isHidden = false
              if iapProducts1.count > 0 {
                    purchaseProduct(product: iapProducts1[0])
              } else {
                  self.LoaderVu.isHidden = true
              }
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
        
    @IBAction func Back(_ sender: Any) {
        let today = Date()
        let nextDate = Calendar.current.date(byAdding: .day, value: PayDays.randomElement()!, to: today)
//         UserDefaults.standard.setValue(nextDate, forKey: "PayCallDate")
        UserDefaults.standard.setValue(nextDate!.string(format: "dd-MM-yyyy"), forKey: "PayCallDate")
        
        self.dismiss(animated: true, completion: nil)
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
        
//        myString.replacingOccurrences(of: "removed", with "")
        DispatchQueue.main.async {
            
            if self.Price2 != "" {
                let R1:Float = Float(self.Price2.strippedtext)!*2
                let Symbol = self.Price2.replacingOccurrences(of: self.Price2.strippedtext, with: "")
                
                
                let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "\(Symbol) \(R1)")
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
                
                self.RealLifetimePrice.attributedText = attributeString
                
            }
            if self.Price1 != "" {
                let R1:Float = Float(self.Price1.strippedtext)!*2
                let Symbol = self.Price1.replacingOccurrences(of: self.Price1.strippedtext, with: "")
                
                let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "\(Symbol) \(R1)")
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
                
                self.RealOneYearPrice.attributedText = attributeString
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


