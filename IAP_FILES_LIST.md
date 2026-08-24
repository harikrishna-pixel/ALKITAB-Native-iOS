# IAP Files List - Exit Offer & Other Products

This document lists all files related to In-App Purchase (IAP) logic, including exit offers and other subscription products.

---

## 📁 Core IAP Management Files

### 1. **StoreManager.swift** (Main IAP Manager)
**Location:** `NewOnboarding/StoreManager.swift`
- **Purpose:** Main IAP manager handling product loading, purchases, and StoreKit integration
- **Key Features:**
  - Product preloading at splash screen
  - Purchase handling for all products (Lifetime, Yearly, 6-month, Exit Offer)
  - Restore purchases functionality
  - SKPaymentTransactionObserver implementation
  - Exit offer product loading and management
  - Product price management and caching

### 2. **BibleSubscriptionView.swift** (SwiftUI IAP UI)
**Location:** `NewOnboarding/BibleSubscriptionView.swift`
- **Purpose:** SwiftUI view for subscription/IAP screen
- **Key Features:**
  - Exit offer modal display
  - Exit offer timer logic (10-minute countdown)
  - Purchase action handling
  - Restore purchases UI
  - Exit offer first-install logic
  - UserDefaults keys for exit offer state management

### 3. **AppConstants.swift** (IAP Configuration)
**Location:** `NKJV Bible/App/App Settings/AppConstants.swift`
- **Purpose:** Contains IAP product IDs, fallback constants, and configuration
- **Key Features:**
  - Product identifiers (Lifetime, Yearly, 6-month, Exit Offer)
  - `FallbackIAPConstants` struct with fallback product IDs
  - Exit offer configuration constants
  - Receipt verification URLs
  - Subscription API endpoints

### 4. **GetAppInfo.swift** (API & Configuration Loader)
**Location:** `NKJV Bible/App/Support/GetAppInfo.swift`
- **Purpose:** Loads IAP configuration from API with fallback support
- **Key Features:**
  - API data fetching for product IDs
  - Fallback constants loading when API unavailable
  - Cache management for API data
  - Exit offer data parsing from API
  - `CallParams()` method to populate global IAP variables

---

## 🔄 Purchase & Restore Files

### 5. **RestoreClass.swift** (Restore Logic)
**Location:** `RestoreClass.swift`
- **Purpose:** Handles purchase restoration and transaction processing
- **Key Features:**
  - `paidResult()` - Processes successful purchases (including exit offer)
  - `restoreData()` - Handles restore purchases flow
  - Transaction date calculation for different subscription types
  - Exit offer purchase handling (treats as lifetime)

### 6. **PaymentHistory.swift** (Receipt Management)
**Location:** `NKJV Bible/App/Controller/Payment/PaymentHistory.swift`
- **Purpose:** Manages payment history, receipt validation, and subscription status
- **Key Features:**
  - `InsertSubscription_Recept()` - Saves purchase receipt to server
  - `GetSubscription_Recept()` - Retrieves subscription data from server
  - Payment status verification
  - Receipt data handling

### 7. **GetReceptKey.swift** (Receipt Extraction)
**Location:** `NKJV Bible/App/Controller/Payment/GetReceptKey/GetReceptKey.swift`
- **Purpose:** Extracts and processes App Store receipts
- **Key Features:**
  - `ReceptId()` - Extracts base64-encoded receipt from app bundle
  - Date conversion utilities for receipt validation

---

## 🌐 Network & API Files

### 8. **NetworkManager.swift** (API Communication)
**Location:** `NKJV Bible/App/Support/NetworkManager.swift`
- **Purpose:** Handles network requests for IAP-related API calls
- **Key Features:**
  - `GetPay_History()` - Verifies receipt with Apple
  - `SubscriptionGetReceipt()` - Gets subscription receipt from server
  - `SubscriptionInsertReceipt()` - Posts receipt data to server

---

## 🎨 UI View Controllers (Legacy UIKit)

### 9. **SubscrbViewController.swift** (UIKit IAP Screen)
**Location:** `NKJV Bible/App/SubscrbViewController.swift`
- **Purpose:** Legacy UIKit subscription view controller
- **Key Features:**
  - Product display and purchase handling
  - Restore purchases functionality
  - SKPaymentTransactionObserver implementation

### 10. **SubscriptionViewController.swift** (Alternative IAP Screen)
**Location:** `NKJV Bible/App/Controller/Payment/SubscriptionViewController.swift`
- **Purpose:** Alternative UIKit subscription view controller
- **Key Features:**
  - Purchase flow implementation
  - Restore functionality

### 11. **PaymentPopupVC.swift** (Payment Popup)
**Location:** `NKJV Bible/App/Controller/Payment/PaymentPopupVC.swift`
- **Purpose:** Payment popup view controller
- **Key Features:**
  - IAP product display
  - Purchase handling
  - Restore purchases

### 12. **NewPaymentViewController.swift** (New Payment Screen)
**Location:** `NewPaymentViewController.swift`
- **Purpose:** New payment view controller implementation
- **Key Features:**
  - IAP product management
  - Purchase and restore flows

### 13. **PaymentFeatureCell.swift** (Payment UI Component)
**Location:** `NKJV Bible/App/PaymentFeatureCell.swift`
- **Purpose:** UI cell component for payment features display

---

## 🎯 Quiz/Wallet Related IAP Files

### 14. **WalletViewController.swift** (Quiz Wallet)
**Location:** `NKJV Bible/Quiz/Wallet/WalletViewController.swift`
- **Purpose:** Wallet/payment view controller for quiz features
- **Key Features:**
  - IAP integration for quiz coins/features
  - Purchase and restore functionality

### 15. **QuizWalletVC.swift** (Quiz Wallet Alternative)
**Location:** `NKJV Bible/Quiz/Quiz App /Quiz Controller/QuizWalletVC/QuizWalletVC.swift`
- **Purpose:** Alternative quiz wallet implementation
- **Key Features:**
  - IAP for quiz-related purchases
  - Payment transaction handling

---

## 🚀 App Lifecycle Integration

### 16. **SplashVc.swift** (Splash Screen)
**Location:** `NKJV Bible/App/Controller/Splash/SplashVc.swift`
- **Purpose:** App launch screen that preloads IAP products
- **Key Features:**
  - Calls `StoreManager.preloadProducts()` at app launch
  - Loads fallback/cached data if no internet
  - Ensures products are ready before IAP screen is shown

---

## 📋 Product Types Handled

### Regular Products:
1. **Lifetime Subscription** (`SUBSCRIPTIONID_LifeTime`)
   - Product ID loaded from API or fallback: `com.bmrbibles.biblenewlivingtranslation.lifetimeadfree`

2. **One Year Subscription** (`SUBSCRIPTIONID_OneYear`)
   - Product ID loaded from API or fallback: `com.bmrbibles.biblenewlivingtranslation.oneyearadfree`

3. **Six Month Subscription** (`SUBSCRIPTIONID_Six_month`)
   - Product ID loaded from API

### Exit Offer:
4. **Exit Offer Product** (`SUBSCRIPTIONID_ExitOffer`)
   - Product ID loaded from API or fallback: `com.bmrbibles.biblenewlivingtranslation.lifetime.offer`
   - Discount percentage: 30% (configurable via API)
   - Plan type: Lifetime
   - Timer duration: 600 seconds (10 minutes)
   - Special handling: Treated as lifetime purchase in `RestoreClass.swift`

---

## 🔑 Key UserDefaults Keys for Exit Offer

- `ExitOfferStartTime` - Timestamp when exit offer was first shown
- `ExitOfferTimeRemaining` - Remaining time in seconds
- `ExitOfferExpired` - Boolean flag if exit offer has expired
- `ExitOfferFirstInstallShown` - Boolean flag if shown on first install
- `sub_identifier_exit_offer` - Exit offer product ID
- `sub_identifier_exit_offer_value` - Discount percentage
- `sub_identifier_exit_offer_item1` - Plan name (e.g., "Lifetime")
- `sub_identifier_exit_offer_item2` - Additional exit offer data

---

## 📝 Documentation Files

### 17. **IAP_FALLBACK_AND_PRELOAD_IMPLEMENTATION.md**
- Comprehensive documentation of IAP fallback system

### 18. **EXIT_OFFER_AND_TTS_PORTING_GUIDE.md**
- Guide for porting exit offer functionality

### 19. **IAP_QUICK_REFERENCE.md**
- Quick reference for IAP implementation

### 20. **EXIT_OFFER_CHANGES_SUMMARY.md**
- Summary of exit offer changes

---

## 🔄 IAP Flow Summary

1. **App Launch (SplashVc.swift)**
   - Loads fallback/cached data via `GetAppInfo.shared.loadFallbackOrCachedData()`
   - Preloads products via `StoreManager.preloadProducts()`

2. **Product Loading (StoreManager.swift)**
   - Fetches product IDs from API or uses fallback constants
   - Loads products from App Store via StoreKit
   - Caches prices and product information

3. **IAP Screen Display (BibleSubscriptionView.swift)**
   - Shows subscription plans
   - Displays exit offer if conditions are met
   - Handles purchase actions

4. **Purchase Processing (StoreManager.swift + RestoreClass.swift)**
   - Processes payment via StoreKit
   - Saves receipt to server via `PaymentHistory`
   - Updates subscription status

5. **Restore Purchases**
   - Restores previous purchases via StoreKit
   - Validates receipts with server
   - Updates subscription status

---

## 🎯 Exit Offer Specific Logic

**Files with Exit Offer Logic:**
1. `StoreManager.swift` - Exit offer product loading, price management
2. `BibleSubscriptionView.swift` - Exit offer UI, timer, display logic
3. `AppConstants.swift` - Exit offer product ID and fallback constants
4. `GetAppInfo.swift` - Exit offer data parsing from API
5. `RestoreClass.swift` - Exit offer purchase processing (treated as lifetime)

---

## 📊 Summary

**Total IAP-Related Files: 20+ files**

**Core Files (Must Understand):**
- StoreManager.swift
- BibleSubscriptionView.swift
- AppConstants.swift
- GetAppInfo.swift
- RestoreClass.swift
- PaymentHistory.swift

**Supporting Files:**
- NetworkManager.swift
- GetReceptKey.swift
- SplashVc.swift
- Various UIKit view controllers (legacy implementations)

**Documentation:**
- Multiple markdown files explaining implementation details



