//
//  StoreManager.swift
//  NKJV Bible
//
//  Created by Marberx Technologies on 20/08/25.
//
import SwiftUI
import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, UnituAdCall {
    
    // MARK: - Shared Instance for Preloading
    static let shared = StoreManager()
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var isLoading1 = false
    @Published var isLoading2 = false
    @Published var isLoading3 = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAdSuccessAlert = false
    @Published var isPresentedAsModal = false
    
    @Published var price1 = UserDefaults.standard.string(forKey: "PriceTag1") ?? ""
    @Published var price2 = UserDefaults.standard.string(forKey: "PriceTag2") ?? ""
    @Published var price3 = UserDefaults.standard.string(forKey: "PriceTag3") ?? ""
    
    @Published var originalPrice1 = ""
    @Published var originalPrice2 = ""
    @Published var originalPrice3 = ""
    
    @Published var exitOfferPrice = ""
    @Published var exitOfferOriginalPrice = ""
    @Published var exitOfferDiscountText = ""
    @Published var exitOfferPlanText = ""
    
    // NEW: Track if exit offer product is successfully loaded
    @Published var isExitOfferProductLoaded = false
    
    // Error states
    @Published var hasProductLoadError = false
    @Published var productLoadErrorMessage = "Unable to load products. Please check your connection and try again."
    
    // Callbacks
    var onPurchaseSuccess: (() -> Void)?
    var onPurchaseFailure: ((String) -> Void)?
    var onRestoreSuccess: (() -> Void)?
    var onRestoreFailed: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    private var purchaseTimeoutWorkItem: DispatchWorkItem?
    private var restoreTimeoutWorkItem: DispatchWorkItem?
    private var isProcessingTransaction = false
    private var hasRestoredTransactions = false
    
    private var iapProducts: [SKProduct] = []
    private var iapProducts1: [SKProduct] = []
    private var iapProducts2: [SKProduct] = []
    private var exitOfferProduct: SKProduct?
    
    private var productIDs = [SUBSCRIPTIONID_Six_month, SUBSCRIPTIONID_OneYear, SUBSCRIPTIONID_LifeTime]
    private var exitOfferProductID: String {
        return SUBSCRIPTIONID_ExitOffer
    }
    
    // MARK: - Public Product Access Methods
    
    /// Check if exit offer product is available for purchase
    var isExitOfferProductAvailable: Bool {
        return exitOfferProduct != nil
    }
    
    /// Sync exit offer product from shared instance if local is nil
    func syncExitOfferProductIfNeeded() {
        if exitOfferProduct == nil && StoreManager.shared !== self {
            if let sharedProduct = StoreManager.shared.exitOfferProduct {
                exitOfferProduct = sharedProduct
                exitOfferPrice = StoreManager.shared.exitOfferPrice
                exitOfferOriginalPrice = StoreManager.shared.exitOfferOriginalPrice
                isExitOfferProductLoaded = StoreManager.shared.isExitOfferProductLoaded
                print("✅ [StoreManager] Synced exit offer product from shared instance")
            }
        }
    }
    private var productRequests: [SKProductsRequest] = []
    private var exitOfferRequest: SKProductsRequest?  // NEW: Track exit offer request
    
    // FIXED: Match UIKit EXACTLY
    private var PRODUCT_ID: String = ""
    private var productID: String = ""
    private var transId: String = ""
    private var transDate: String = ""
    private var productIDIndex: Int = 0
    
    var shouldDismissAsModal: Bool {
        return isPresentedAsModal
    }
    
    override init() {
        super.init()
        
        setupDelegates()
        setupRestoreClass()
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            GetAppInfo.shared.CallParams()
        }
    }
    
    deinit {
        purchaseTimeoutWorkItem?.cancel()
        restoreTimeoutWorkItem?.cancel()
    }
    
    // MARK: - Setup Methods
    
    private func setupDelegates() {
        App_Protocol.UnituAdCallDelegate = self
    }
    
    private func setupRestoreClass() {
        if RestoreClass.shared.SourceVC == nil {
            let dummyVC = UIViewController()
            RestoreClass.shared.SourceVC = dummyVC
        }
    }
    
    // MARK: - Preload Products (Call from Splash Screen)
    static func preloadProducts() {
        print("🚀 [StoreManager] Preloading IAP products at splash screen...")
        
        // Ensure we have product IDs loaded (from API or fallback)
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            GetAppInfo.shared.CallParams()
        } else {
            // Load fallback or cached data
            GetAppInfo.shared.loadFallbackOrCachedData()
        }
        
        // Start loading products in background
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if IS_SUBSCRIPTION_ENABLE == 1 {
                print("   ✅ Starting product preload...")
                shared.setupProducts()
            } else {
                print("   ⚠️ IAP disabled, skipping preload")
            }
        }
    }
    
    func setupProducts() {
        print("🛒 [StoreManager] setupProducts() called")
        
        // NEW: Check if products are already loaded from shared instance (preloaded at splash)
        let shared = StoreManager.shared
        let productsAlreadyLoaded = !shared.price1.isEmpty || !shared.price2.isEmpty || !shared.price3.isEmpty || shared.isExitOfferProductLoaded
        
        if productsAlreadyLoaded && self !== shared {
            print("📦 [StoreManager] Products already loaded from shared instance, copying data...")
            // Copy prices from shared instance
            self.price1 = shared.price1
            self.price2 = shared.price2
            self.price3 = shared.price3
            self.originalPrice1 = shared.originalPrice1
            self.originalPrice2 = shared.originalPrice2
            self.originalPrice3 = shared.originalPrice3
            self.exitOfferPrice = shared.exitOfferPrice
            self.exitOfferOriginalPrice = shared.exitOfferOriginalPrice
            self.exitOfferDiscountText = shared.exitOfferDiscountText
            self.exitOfferPlanText = shared.exitOfferPlanText
            self.isExitOfferProductLoaded = shared.isExitOfferProductLoaded
            
            // Copy product arrays
            self.iapProducts = shared.iapProducts
            self.iapProducts1 = shared.iapProducts1
            self.iapProducts2 = shared.iapProducts2
            self.exitOfferProduct = shared.exitOfferProduct
            
            // FIXED: Verify exit offer product actually exists, not just the flag
            // If flag is true but product is nil, reset the flag
            if self.isExitOfferProductLoaded && self.exitOfferProduct == nil {
                print("   ⚠️ WARNING: isExitOfferProductLoaded is true but exitOfferProduct is nil!")
                print("   → This shouldn't happen - resetting flag")
                self.isExitOfferProductLoaded = false
            }
            
            // Debug logging for exit offer
            print("   → Exit offer product copied: \(self.exitOfferProduct != nil ? "YES" : "NO")")
            print("   → Exit offer price: '\(self.exitOfferPrice)'")
            print("   → Exit offer loaded flag: \(self.isExitOfferProductLoaded)")
            
            // FIXED: If product wasn't copied but should be available, try to fetch it
            if self.exitOfferProduct == nil && !self.exitOfferProductID.isEmpty && !self.exitOfferPrice.isEmpty {
                print("   ⚠️ Exit offer product missing but price exists - attempting to fetch...")
                self.fetchExitOfferProduct()
            }
            
            // Stop all loading states
            self.isLoading1 = false
            self.isLoading2 = false
            self.isLoading3 = false
            self.hasProductLoadError = false
            
            // Load exit offer text from API (if not already loaded)
            if exitOfferPlanText.isEmpty {
                loadExitOfferText()
            }
            
            resetValue()
            print("   ✅ Products copied successfully, no reload needed")
            return
        }
        
        // Products not loaded yet, proceed with normal loading
        print("📦 [StoreManager] Products not preloaded, starting fresh load...")
        resetValue()
        
        // NEW: Reset exit offer product loaded flag
        isExitOfferProductLoaded = false
        
        // Load exit offer text from API
        loadExitOfferText()
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            print("✅ [StoreManager] Internet connection available")
            if IS_SUBSCRIPTION_ENABLE == 1 {
                print("📦 [StoreManager] Subscription enabled, fetching products...")
                iapProducts = []
                iapProducts1 = []
                iapProducts2 = []
                productIDIndex = 0
                hasProductLoadError = false
                callAPI(index: 0)
                enableButtons(false)
                
                // Also fetch exit offer product
                fetchExitOfferProduct()
            } else {
                print("⚠️ [StoreManager] Subscription disabled (IS_SUBSCRIPTION_ENABLE = 0)")
            }
        } else {
            print("❌ [StoreManager] No internet connection")
            hasProductLoadError = true
            productLoadErrorMessage = "No internet connection. Please check your connection and try again."
            // Use cached prices if available
            if !price1.isEmpty || !price2.isEmpty || !price3.isEmpty {
                print("   ℹ️ Using cached prices from previous session")
            }
            calculateOriginalPrices()
        }
    }
    
    private func loadExitOfferText() {
        // Load exit offer promotional text from API
        let discountValue = sub_identifier_exit_offer_value
        let planText = sub_identifier_exit_offer_item1
        let promotionalText = sub_identifier_exit_offer_item2
        
        print("📝 [StoreManager] Loading exit offer text from API:")
        print("   - discountValue: '\(discountValue)'")
        print("   - planText: '\(planText)'")
        print("   - promotionalText: '\(promotionalText)'")
        
        // Set discount text (e.g., "30% off")
        if !discountValue.isEmpty, let discount = Int(discountValue), discount > 0 {
            exitOfferDiscountText = "\(discount)%"
            print("   ✅ Discount text set to: '\(exitOfferDiscountText)'")
        } else {
            exitOfferDiscountText = ""
            print("   ⚠️ Discount value empty or invalid")
        }
        
        // Set plan text (e.g., "Lifetime Premium")
        exitOfferPlanText = planText.isEmpty ? "" : planText
        print("   ✅ Plan text set to: '\(exitOfferPlanText)'")
    }
    
    private func fetchExitOfferProduct() {
        guard !exitOfferProductID.isEmpty else {
            print("⚠️ [StoreManager] Exit offer product ID is empty, skipping fetch")
            isExitOfferProductLoaded = false  // NEW: Explicitly set to false
            return
        }
        print("🛍️ [StoreManager] Fetching exit offer product: \(exitOfferProductID)")
        let productIdentifiers = Set([exitOfferProductID])
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        productRequests.append(request)
        exitOfferRequest = request  // NEW: Track this request
        request.start()
        print("   → SKProductsRequest started for exit offer")
        // Note: isExitOfferProductLoaded starts as false, will be set to true when product loads
    }
    
    private func enableButtons(_ enabled: Bool) {
        DispatchQueue.main.async {
            // Handled by isLoading states
        }
    }
    
    // MARK: - API Calls
    
    func callAPI(index: Int) {
        print("📞 [StoreManager] callAPI(index: \(index))")
        guard index < productIDs.count else {
            print("   ✅ All products processed, stopping loading")
            // ADDED: Safety - stop all loading if we're past the array
            isLoading1 = false
            isLoading2 = false
            isLoading3 = false
            enableButtons(true)
            return
        }
        
        let productID = productIDs[index]
        print("   → Processing product ID[\(index)]: '\(productID)'")
        
        guard !productID.isEmpty else {
            print("   ⚠️ Product ID[\(index)] is empty, skipping")
            updateLoadingState(for: index, isLoading: false)  // Stop loading for empty ID
            productIDIndex += 1
            if productIDIndex < productIDs.count {
                callAPI(index: productIDIndex)
            } else {
                enableButtons(true)
            }
            return
        }
        
        PRODUCT_ID = productID
        fetchProduct(productID, index: index)
    }

    
    func checkNetworkStatus() {
        if IS_SUBSCRIPTION_ENABLE == 1 {
            callAPI(index: 0)
        }
    }
    
    // MARK: - Product Fetching
    
    private func fetchProduct(_ productID: String, index: Int) {
        print("🔍 [StoreManager] fetchProduct('\(productID)', index: \(index))")
        let productIdentifiers = Set([productID])
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        productRequests.append(request)
        request.start()
        print("   → SKProductsRequest started")
        updateLoadingState(for: index, isLoading: true)
    }
    
    // MARK: - Purchase Methods
    
    func purchaseProduct(with identifier: String) {
        print("💳 [StoreManager] purchaseProduct called with identifier: '\(identifier)'")
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            showAlert(title: "No Internet", message: "Please check your internet connection and try again.")
            onPurchaseFailure?("No internet connection")
            return
        }
        
        var product: SKProduct?
        
        if identifier == SUBSCRIPTIONID_Six_month {
            guard !iapProducts.isEmpty else {
                print("   ❌ Six month product array is empty")
                handleProductNotLoaded()
                return
            }
            product = iapProducts.first
            print("   ✅ Found six month product: \(product?.productIdentifier ?? "nil")")
        } else if identifier == SUBSCRIPTIONID_OneYear {
            guard !iapProducts1.isEmpty else {
                print("   ❌ One year product array is empty")
                handleProductNotLoaded()
                return
            }
            product = iapProducts1.first
            print("   ✅ Found one year product: \(product?.productIdentifier ?? "nil")")
        } else if identifier == SUBSCRIPTIONID_LifeTime {
            guard !iapProducts2.isEmpty else {
                print("   ❌ Lifetime product array is empty")
                handleProductNotLoaded()
                return
            }
            product = iapProducts2.first
            print("   ✅ Found lifetime product: \(product?.productIdentifier ?? "nil")")
        } else if identifier == SUBSCRIPTIONID_ExitOffer || (!SUBSCRIPTIONID_ExitOffer.isEmpty && identifier == exitOfferProductID) {
            // FIXED: Match yearly/lifetime pattern - check both direct comparison and computed property
            print("   → Checking exit offer product...")
            print("   → exitOfferProductID: '\(exitOfferProductID)'")
            print("   → SUBSCRIPTIONID_ExitOffer: '\(SUBSCRIPTIONID_ExitOffer)'")
            print("   → exitOfferProduct is nil: \(exitOfferProduct == nil)")
            
            // FIXED: First try to sync if local is nil
            syncExitOfferProductIfNeeded()
            
            // FIXED: Check if exit offer product exists, if not try to get from shared instance
            var candidateProduct: SKProduct? = nil
            
            if let localProduct = exitOfferProduct {
                candidateProduct = localProduct
                print("   ✅ Found exit offer product in local instance: \(localProduct.productIdentifier)")
            } else if StoreManager.shared !== self, let sharedProduct = StoreManager.shared.exitOfferProduct {
                print("   ⚠️ Local exit offer product is still nil after sync, copying directly from shared instance...")
                exitOfferProduct = sharedProduct
                exitOfferPrice = StoreManager.shared.exitOfferPrice
                exitOfferOriginalPrice = StoreManager.shared.exitOfferOriginalPrice
                isExitOfferProductLoaded = StoreManager.shared.isExitOfferProductLoaded
                candidateProduct = sharedProduct
                print("   ✅ Found exit offer product in shared instance: \(sharedProduct.productIdentifier)")
            } else {
                print("   ❌ Exit offer product not available anywhere")
                print("   → Local exitOfferProduct: \(exitOfferProduct != nil ? "exists" : "nil")")
                print("   → Shared exitOfferProduct: \(StoreManager.shared.exitOfferProduct != nil ? "exists" : "nil")")
                print("   → isExitOfferProductLoaded: \(isExitOfferProductLoaded)")
                print("   → exitOfferPrice: '\(exitOfferPrice)'")
                print("   ⚠️ Attempting to fetch exit offer product...")
                
                // Try to fetch the product immediately if not available
                if !exitOfferProductID.isEmpty {
                    fetchExitOfferProduct()
                    // Wait a bit and show error - we can't wait indefinitely
                    showAlert(title: "Please Wait", message: "Loading product information. Please try again in a moment.")
                    return
                }
                
                handleProductNotLoaded()
                return
            }
            
            // FIXED: Verify the product identifier matches what we expect
            if let candidate = candidateProduct {
                let expectedID = !SUBSCRIPTIONID_ExitOffer.isEmpty ? SUBSCRIPTIONID_ExitOffer : exitOfferProductID
                if candidate.productIdentifier == expectedID || candidate.productIdentifier == identifier {
                    product = candidate
                    print("   ✅ Product identifier verified: \(candidate.productIdentifier)")
                } else {
                    print("   ⚠️ Product identifier mismatch!")
                    print("   → Expected: '\(expectedID)' or '\(identifier)'")
                    print("   → Actual: '\(candidate.productIdentifier)'")
                    // Still use it if identifier matches what was passed
                    if candidate.productIdentifier == identifier {
                        product = candidate
                        print("   ✅ Using product anyway (identifier matches)")
                    } else {
                        print("   ❌ Product identifier doesn't match, cannot proceed")
                        handleProductNotLoaded()
                        return
                    }
                }
            }
        } else {
            print("   ❌ Unknown product identifier: '\(identifier)'")
            print("   → SUBSCRIPTIONID_ExitOffer: '\(SUBSCRIPTIONID_ExitOffer)'")
            print("   → exitOfferProductID: '\(exitOfferProductID)'")
        }
        
        guard let selectedProduct = product else {
            print("   ❌ Selected product is nil after all checks")
            showAlert(title: "Error", message: "Products not available. Please try again later.")
            onPurchaseFailure?("Product not available")
            return
        }
        
        print("   ✅ Proceeding with purchase for product: \(selectedProduct.productIdentifier)")
        
        // FIXED: Match UIKit - set PRODUCT_ID first
        PRODUCT_ID = identifier
        
        isLoading = true
        let payment = SKPayment(product: selectedProduct)
        
        print("   → Creating SKPayment for: \(selectedProduct.productIdentifier)")
        print("   → Adding payment to queue...")
        
        // FIXED: Match UIKit - add observer EVERY time before purchase
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        
        // FIXED: Match UIKit - set productID AFTER adding payment
        productID = selectedProduct.productIdentifier
        
        print("   ✅ Payment added to queue successfully")
        
        // FIXED: Match UIKit - 10 second timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.isLoading = false
        }
    }
    
    private func handleProductNotLoaded() {
        print("⚠️ [StoreManager] handleProductNotLoaded() called")
        checkNetworkStatus()
        
        // FIXED: Also fetch exit offer product if it's missing
        if exitOfferProduct == nil && !exitOfferProductID.isEmpty {
            print("   → Exit offer product is nil, fetching...")
            fetchExitOfferProduct()
        }
        
        showAlert(title: "Please Wait", message: "Please wait for few seconds...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            if self.iapProducts.isEmpty && self.iapProducts1.isEmpty && self.iapProducts2.isEmpty && self.exitOfferProduct == nil {
                self.showAlert(title: "Network Error", message: "Poor Network Connection")
            }
        }
    }
    
    func restorePurchases() {
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            showAlert(title: "No Internet", message: "Please check your internet connection and try again.")
            return
        }
        
        hasRestoredTransactions = false
        isLoading = true
        
        RestoreClass.shared.restoreData(NavigateStatus: false)
        
        // FIXED: Add observer before restore
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.isLoading = false
        }
    }
    
    // MARK: - Watch Ad Method
    
//    func watchAdForFreeAccess() {
//        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
//            showAlert(title: "No Internet", message: "Please check your internet connection.")
//            return
//        }
//
//        if !PaymentHistory.sharedInstance.paymentInfo() {
//            guard let rootViewController = getRootViewController() else {
//                showAlert(title: "Error", message: "Unable to show ad at this time.")
//                return
//            }
//
//            AdmobManager.shared.IronSource_Reward_ShowAds(vw: rootViewController, RewardAd: "WatchAd")
//        } else {
//            showAlert(title: "Ad Not Available", message: "Ad not available at this time.")
//        }
//    }
    
    private func getRootViewController() -> UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        
        return windowScene?.windows.first?.rootViewController
    }
    
    // MARK: - UnituAdCall Delegate Methods
    
    func AdDidClosed() {
        showAdSuccessAlert = true
        
        CoreDataModel.sharedInstance.deleteAllData(CDPaymentdateAPI)
        CoreDataModel.sharedInstance.coreDataInsertEndDate(CDPaymentdateAPI, endDate: Date.tomorrow.string(format: "dd-MM-yyyy"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            App_Protocol.delegateReader?.paymentStatus()
            App_Protocol.DelegateSlideCard?.paymentStatus()
        }
    }
    
    func unityAdOpen() {}
    
    func NoAdClosed() {
        showAlert(title: "Ad Not Available", message: "Ad not available at this time.")
        App_Protocol.delegateReader?.paymentStatus()
        App_Protocol.DelegateSlideCard?.paymentStatus()
    }
    
    func okAction() {
        App_Protocol.delegateReader?.paymentStatus()
        App_Protocol.DelegateSlideCard?.paymentStatus()
        showAdSuccessAlert = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.onDismiss?()
        }
    }
    
    // MARK: - Reset Value
    
    func resetValue() {
        if offer_enabled == "1" {
            calculateOriginalPrices()
        }
    }
    
    // MARK: - SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            print("📥 [StoreManager] productsRequest received response")
            print("   → Products found: \(response.products.count)")
            print("   → Invalid product IDs: \(response.invalidProductIdentifiers)")
            
            // NEW: Check if this is exit offer request
            let isExitOfferRequest = (request == self.exitOfferRequest)
            print("   → Is exit offer request: \(isExitOfferRequest)")
            
            // NEW: If exit offer product failed to load
            if isExitOfferRequest {
                if response.products.isEmpty {
                    print("   ❌ Exit offer product failed to load - no products in response")
                    self.isExitOfferProductLoaded = false
                    return  // Exit early, don't process further
                }
                // Check if the product ID is in invalid list (only if exitOfferProductID is not empty)
                if !self.exitOfferProductID.isEmpty && response.invalidProductIdentifiers.contains(self.exitOfferProductID) {
                    print("   ❌ Exit offer product failed to load - invalid product ID: \(self.exitOfferProductID)")
                    self.isExitOfferProductLoaded = false
                    return  // Exit early, don't process further
                }
                print("   ✅ Exit offer request has valid product(s)")
            }
            
            guard let product = response.products.first else {
                print("   ❌ No valid product found in response")
                // Product not found - show error
                self.hasProductLoadError = true
                self.productLoadErrorMessage = "Unable to load product information. Please try again later."
                
                // Stop loading for current index
                self.updateLoadingState(for: self.productIDIndex, isLoading: false)
                self.productIDIndex += 1
                if self.productIDIndex < self.productIDs.count {
                    self.callAPI(index: self.productIDIndex)
                } else {
                    self.enableButtons(true)
                }
                return
            }
            
            print("   ✅ Product loaded: \(product.productIdentifier)")
            print("   → Price: \(product.price)")
            print("   → Price locale: \(product.priceLocale.identifier)")
            
            // Product loaded successfully
            self.hasProductLoadError = false
            
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = product.priceLocale
            let priceString = numberFormatter.string(from: product.price) ?? ""
            print("   → Formatted price: '\(priceString)'")
            
            // FIXED: If this is an exit offer request, handle it directly
            if isExitOfferRequest {
                print("   ✅ Processing exit offer product from dedicated request")
                print("   → Product identifier: \(product.productIdentifier)")
                
                // Update SUBSCRIPTIONID_ExitOffer if it was empty
                if SUBSCRIPTIONID_ExitOffer.isEmpty {
                    SUBSCRIPTIONID_ExitOffer = product.productIdentifier
                    UserDefaults.standard.set(product.productIdentifier, forKey: "sub_identifier_exit_offer")
                    print("   → Updated SUBSCRIPTIONID_ExitOffer: '\(SUBSCRIPTIONID_ExitOffer)'")
                }
                
                self.exitOfferProduct = product
                self.exitOfferPrice = priceString
                self.exitOfferOriginalPrice = self.price3.isEmpty ? priceString : self.price3
                self.isExitOfferProductLoaded = true
                print("   → Set exitOfferPrice: '\(priceString)'")
                print("   → Set exitOfferOriginalPrice: '\(self.exitOfferOriginalPrice)'")
                print("   ✅ Exit offer product loaded - ready to show")
                
                // Also update shared instance
                if StoreManager.shared !== self {
                    StoreManager.shared.exitOfferProduct = product
                    StoreManager.shared.exitOfferPrice = priceString
                    StoreManager.shared.exitOfferOriginalPrice = self.price3.isEmpty ? priceString : self.price3
                    StoreManager.shared.isExitOfferProductLoaded = true
                    print("   → Also updated shared instance")
                }
                
                // Don't continue to switch statement for exit offer requests
                return
            }
            
            // FIXED: Match by product identifier instead of sequential empty checks
            switch product.productIdentifier {
            case SUBSCRIPTIONID_Six_month:
                print("   ✅ Matched: SUBSCRIPTIONID_Six_month")
                self.iapProducts = [product]
                self.price1 = priceString
                UserDefaults.standard.set(priceString, forKey: "PriceTag1")
                self.isLoading1 = false
                print("   → Set price1: '\(priceString)'")
                
            case SUBSCRIPTIONID_OneYear:
                print("   ✅ Matched: SUBSCRIPTIONID_OneYear")
                self.iapProducts1 = [product]
                self.price2 = priceString
                UserDefaults.standard.set(priceString, forKey: "PriceTag2")
                self.isLoading2 = false
                print("   → Set price2: '\(priceString)'")
                
            case SUBSCRIPTIONID_LifeTime:
                print("   ✅ Matched: SUBSCRIPTIONID_LifeTime")
                self.iapProducts2 = [product]
                self.price3 = priceString
                UserDefaults.standard.set(priceString, forKey: "PriceTag3")
                self.isLoading3 = false
                print("   → Set price3: '\(priceString)'")
                // Update exit offer original price to use regular lifetime price
                if !self.exitOfferPrice.isEmpty {
                    self.exitOfferOriginalPrice = priceString
                    print("   → Updated exitOfferOriginalPrice: '\(priceString)'")
                }
                
            case self.exitOfferProductID:
                print("   ✅ Matched: Exit Offer Product (via case statement)")
                print("   → Product identifier: \(product.productIdentifier)")
                print("   → Expected identifier: \(self.exitOfferProductID)")
                self.exitOfferProduct = product
                // Price from API - use it directly, no calculation
                self.exitOfferPrice = priceString
                print("   → Set exitOfferPrice: '\(priceString)'")
                // Original price is the regular lifetime price (₹1,299), not calculated
                self.exitOfferOriginalPrice = self.price3
                print("   → Set exitOfferOriginalPrice: '\(self.exitOfferOriginalPrice)'")
                // NEW: Mark as loaded immediately
                self.isExitOfferProductLoaded = true
                print("   ✅ Exit offer product loaded - ready to show")
                print("   → exitOfferProduct is now set: \(self.exitOfferProduct != nil)")
                
                // FIXED: Also update shared instance if this is not the shared instance
                if StoreManager.shared !== self {
                    StoreManager.shared.exitOfferProduct = product
                    StoreManager.shared.exitOfferPrice = priceString
                    StoreManager.shared.exitOfferOriginalPrice = self.price3
                    StoreManager.shared.isExitOfferProductLoaded = true
                    print("   → Also updated shared instance")
                }
                
            default:
                // FIXED: Check if this is the exit offer product by comparing identifiers
                // Check multiple possible identifiers since SUBSCRIPTIONID_ExitOffer might be empty
                let knownExitOfferIDs = [
                    self.exitOfferProductID,
                    SUBSCRIPTIONID_ExitOffer,
                    "com.bmrbibles.biblenewlivingtranslation.lifetime.offer",  // Fallback constant
                    UserDefaults.standard.string(forKey: "sub_identifier_exit_offer") ?? ""
                ].filter { !$0.isEmpty }
                
                let isExitOfferProduct = knownExitOfferIDs.contains(product.productIdentifier) ||
                                       product.productIdentifier.hasSuffix(".lifetime.offer")
                
                if isExitOfferProduct {
                    print("   ✅ Matched: Exit Offer Product (via default case fallback)")
                    print("   → Product identifier: \(product.productIdentifier)")
                    print("   → Known exit offer IDs: \(knownExitOfferIDs)")
                    
                    // FIXED: Update SUBSCRIPTIONID_ExitOffer if it was empty
                    if SUBSCRIPTIONID_ExitOffer.isEmpty {
                        SUBSCRIPTIONID_ExitOffer = product.productIdentifier
                        UserDefaults.standard.set(product.productIdentifier, forKey: "sub_identifier_exit_offer")
                        print("   → Updated SUBSCRIPTIONID_ExitOffer: '\(SUBSCRIPTIONID_ExitOffer)'")
                    }
                    
                    self.exitOfferProduct = product
                    self.exitOfferPrice = priceString
                    self.exitOfferOriginalPrice = self.price3
                    self.isExitOfferProductLoaded = true
                    print("   → Set exitOfferPrice: '\(priceString)'")
                    print("   → Set exitOfferOriginalPrice: '\(self.exitOfferOriginalPrice)'")
                    print("   ✅ Exit offer product loaded via fallback - ready to show")
                    
                    // Also update shared instance
                    if StoreManager.shared !== self {
                        StoreManager.shared.exitOfferProduct = product
                        StoreManager.shared.exitOfferPrice = priceString
                        StoreManager.shared.exitOfferOriginalPrice = self.price3
                        StoreManager.shared.isExitOfferProductLoaded = true
                        print("   → Also updated shared instance")
                    }
                } else {
                    print("   ⚠️ Unknown product: \(product.productIdentifier)")
                }
            }
            
            // Stop loading for current product
            self.updateLoadingState(for: self.productIDIndex, isLoading: false)
            
            // Load next product
            self.productIDIndex += 1
            if self.productIDIndex < self.productIDs.count {
                print("   → Moving to next product (index: \(self.productIDIndex))")
                self.callAPI(index: self.productIDIndex)
            } else {
                print("   ✅ All regular products loaded")
                self.enableButtons(true)
            }
            
            self.calculateOriginalPrices()
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            print("❌ [StoreManager] SKRequest failed with error: \(error.localizedDescription)")
            
            // NEW: Check if this is exit offer request
            if request == self.exitOfferRequest {
                print("   ❌ Exit offer product request failed - will not show exit offer")
                self.isExitOfferProductLoaded = false
                return  // Exit early, don't process further
            }
            
            self.hasProductLoadError = true
            self.productLoadErrorMessage = "Failed to load products: \(error.localizedDescription)"
            
            // Stop loading for current product
            self.updateLoadingState(for: self.productIDIndex, isLoading: false)
            
            // Try next product
            self.productIDIndex += 1
            if self.productIDIndex < self.productIDs.count {
                print("   → Retrying with next product (index: \(self.productIDIndex))")
                self.callAPI(index: self.productIDIndex)
            } else {
                print("   ⚠️ All products failed to load")
                self.enableButtons(true)
            }
        }
    }

    
    // MARK: - SKPaymentTransactionObserver
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // FIXED: Match UIKit - finish transaction first
                SKPaymentQueue.default().finishTransaction(transaction)
                
                // FIXED: Match UIKit - check productID == PRODUCT_ID
                if productID == PRODUCT_ID {
                    // Store transaction details
                    self.transId = transaction.transactionIdentifier ?? ""
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .full
                    dateFormatter.timeStyle = .none
                    dateFormatter.locale = Locale.current
                    self.transDate = dateFormatter.string(from: transaction.transactionDate ?? Date())
                    
                    // FIXED: Match UIKit - call SetPaymentDAte (which calls Getpayment)
                    self.SetPaymentDAte()
                    
                    // Set purchased flag
                    UserDefaults.standard.set(true, forKey: "isPurchased")
                    
                    // Stop loading
                    self.isLoading = false
                    
                    // Call RestoreClass
                    RestoreClass.shared.paidResult(productID: productID, transId: self.transId)
                }
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                isLoading = false
                
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        let errorMessage = error.localizedDescription
                        showAlert(title: "Purchase Failed", message: errorMessage)
                        onPurchaseFailure?(errorMessage)
                    } else {
                        onPurchaseFailure?("Cancelled")
                    }
                }
                
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                hasRestoredTransactions = true
                self.SetPaymentDAte()
                isLoading = false
                
            case .deferred, .purchasing:
                break
                
            @unknown default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        isLoading = false
        
        if hasRestoredTransactions {
            showAlert(title: "Restore Successful", message: "Your purchases have been restored successfully!")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.onRestoreSuccess?()
            }
        } else {
            showAlert(title: "No Purchases Found", message: "No previous purchases were found to restore.")
            onRestoreFailed?()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        isLoading = false
        RestoreClass.shared.restoreData(NavigateStatus: false)
        
        let nsError = error as NSError
        if nsError.code != SKError.paymentCancelled.rawValue {
            showAlert(title: "Restore Failed", message: error.localizedDescription)
        }
        
        onRestoreFailed?()
    }
    
    // MARK: - SetPaymentDAte (Match UIKit)
    
    func SetPaymentDAte() {
        PaymentHistory.sharedInstance.Getpayment(completion: {
            // BUG FIX 5 & 6: OLD CODE - UI updates not on main thread, causing delays
            /*
            App_Protocol.delegateReader?.paymentStatus()
            App_Protocol.DelegateSlideCard?.paymentStatus()
            ImageAppProtocol.ImageTxtEditDelegate?.CheckPay()
            */
            // Problem: Updates happened in background thread, icon didn't update immediately
            
            // BUG FIX 5 & 6: NEW CODE - Wrapped in main thread for immediate UI updates
            DispatchQueue.main.async {
                App_Protocol.delegateReader?.paymentStatus()
                App_Protocol.DelegateSlideCard?.paymentStatus()
                ImageAppProtocol.ImageTxtEditDelegate?.CheckPay()
            }
            self.onPurchaseSuccess?()
        })
    }
    
    // MARK: - Helper Methods
    
    private func calculateOriginalPrices() {
        if offer_enabled == "1" {
            if !price1.isEmpty, let discount = Float(sub_identifier_six_month_value) {
                originalPrice1 = calculateOriginalPrice(price: price1, discount: discount)
            }
            
            if !price2.isEmpty, let discount = Float(sub_identifier_oneyear_value) {
                originalPrice2 = calculateOriginalPrice(price: price2, discount: discount)
            }
            
            if !price3.isEmpty, let discount = Float(sub_identifier_lifetime_value) {
                originalPrice3 = calculateOriginalPrice(price: price3, discount: discount)
            }
            
            // Exit offer original price is the regular lifetime price, not calculated
            if !price3.isEmpty {
                exitOfferOriginalPrice = price3
            }
        }
    }
    
    private func calculateOriginalPrice(price: String, discount: Float) -> String {
        // Extract numeric value - remove commas and other formatting
        let strippedNumeric = price.strippedtext.replacingOccurrences(of: ",", with: "")
        guard let numericValue = Float(strippedNumeric), numericValue > 0 else {
            print("⚠️ [StoreManager] Failed to parse price for calculation: '\(price)' -> stripped: '\(price.strippedtext)' -> numeric: '\(strippedNumeric)'")
            return ""
        }
        
        // Calculate original price: if discounted price = original * (100 - discount) / 100
        // Then original = discounted * 100 / (100 - discount)
        let originalValue = Int((numericValue / (100 - discount)) * 100)
        
        // Extract currency symbol by removing the numeric part
        let symbol = price.replacingOccurrences(of: price.strippedtext, with: "").trimmingCharacters(in: .whitespaces)
        
        print("💰 [StoreManager] Price calculation: price=\(price), discount=\(discount)%, numeric=\(numericValue), original=\(originalValue)")
        
        return "\(symbol)\(originalValue).00"
    }
    
    private func updateLoadingState(for index: Int, isLoading: Bool) {
        switch index {
        case 0: isLoading1 = isLoading
        case 1: isLoading2 = isLoading
        case 2: isLoading3 = isLoading
        default: break
        }
    }
    
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    func openTerms() {
        if let url = URL(string: TermsURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func openPrivacy() {
        if let url = URL(string: PrivacyURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}








//// Extension for string stripping (from your original code)
//extension String {
//    var strippedtext: String {
//        return self.components(separatedBy: CharacterSet.decimalDigits.inverted)
//            .joined()
//    }
//}
