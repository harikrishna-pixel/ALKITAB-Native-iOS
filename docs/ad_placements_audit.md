# Ad placements audit — ALKITAB Native iOS (Blue Reading Bible)

**Scope:** Read-only audit of ironSource / Unity LevelPlay (and related) ad code.  
**Date:** 2026-11-23  
**Note:** There is **no Google AdMob SDK** in the Podfile. The class is named `AdmobManager` but it wraps **IronSource**. `GoogleUserMessagingPlatform` is in Pods; **no app Swift code** calls UMP consent APIs.

---

## Summary

### Totals by format

| Format | Live show/load placements (approx.) |
|--------|-------------------------------------|
| Interstitial (IronSource) | **9** user-facing show paths (+ preload) |
| Rewarded video (IronSource) | **10** show paths (9 app `RewardAd` tags + subscription loading VC) |
| Banner (IronSource) | **5** load/show screens |
| Offerwall | **0** |
| Unity Ads (direct SDK) | **0** shows (init only; show APIs unused) |

### Flat list: Screen → format → trigger

1. **Reader (chapter swipe)** → interstitial → every `show_interstitial_row` (default **10**) chapter finishes this session  
2. **Reader / Verse Image browse** → interstitial → every **10th** wallpaper tap/swipe this session  
3. **Reader / verse actions** → interstitial → every **5th** `CallAds` (from reader source) via `LastClickCount`  
4. **Reader / Verse Image Save** → interstitial → **once per app session** on save  
5. **Quiz Alert (“Mark as Read”)** → interstitial → tap Read / Yes / Dismiss when `MARK_US_READ`  
6. **Quiz Main** → interstitial → confirm “give up” / back  
7. **Quiz Scoreboard** → interstitial → scoreboard appear path (when ads on)  
8. **Image Share result** → interstitial → share screen load (when ads on)  
9. **Slide Card Save** → interstitial → **1st** save this session, then every **10th** save  
10. **Quiz Main** → banner → quiz screen open (when ads on)  
11. **Quiz Alert** → banner → alert screen open (when ads on + online)  
12. **Shared / social share sheet** → banner → sheet open (when ads on)  
13. **Image Share** → banner → share screen open (when ads on)  
14. **Ad Toast alert** → banner → toast VC open (when ads on)  
15. **Quiz Result → Try Again** → rewarded → Try Again button  
16. **Quiz Wallet** → rewarded → watch-ad free credits  
17. **Quiz Main free credits** → rewarded → free-credits / watch-ad  
18. **Subscription (SubscrbViewController)** → rewarded → Watch Ad / `unityAdOpen`  
19. **Subscription (legacy SubscriptionViewController)** → rewarded via **InterstitialViewController** → Watch Ad  
20. **Gift Card open** → rewarded → skip/open card with ad  
21. **Gift Card claim (scratch)** → rewarded → double credits  
22. **Image editor watermark** → rewarded → remove watermark  
23. **Paywall trigger sheets** → rewarded → watch for credits / watch for more images  

**Preload (no UI by itself):** App launch after GetAppInfo → interstitial + rewarded load (`AppDelegate`). Wallpaper open → interstitial load. Slide Card appear → interstitial load.

### Risks

| Risk | Finding |
|------|---------|
| Back-to-back interstitials | Partial mitigation: global **120s** min interval in `AdmobManager`. Reader can still queue multiple triggers (swipe + verse image + mark-as-read) that wait on that gate. |
| Ads on paywall / purchase | **Yes:** rewarded from `PaywallTriggerScreens` and Watch Ad on `SubscrbViewController` / `SubscriptionViewController`. |
| Ads during onboarding | **No IronSource show** on onboarding screens found. ATT is requested in `Onboarding1` before continue; ads preload later from `AppDelegate` after API (~3.5s), which may be **before or after** ATT depending on timing — **UNKNOWN - needs human check** vs real device order. |
| Missing premium check | Most interstitials/banners gate with `PaymentHistory.paymentInfo()`. **Rewarded** paths generally do **not** check subscription (user-initiated rewards). `SubscriptionViewController` Watch Ad → `InterstitialViewController` has **no** `paymentInfo()` guard. |
| Test mode in release | **`UNITY_TEST_MODE = true`** in `AppConstants.swift` (Unity init). IronSource: no `setAdaptersDebug` / `validateIntegration` in app code. `ADS_DISABLED_FOR_TESTING = false`. |
| Ads before consent | No `IronSource.setConsent` / UMP request found in app Swift. ATT exists on onboarding only. |
| Splash interstitial | `Interstitial_ID == "OpenSplash"` handlers exist but **`Interstitial_ID` is never assigned** → dead splash-ad callback path. Splash `OpenAd()` navigates to Reader; does **not** show an ad. |

### SDK / keys (masked)

| Item | Location | Value (masked) |
|------|----------|----------------|
| IronSource app key | Runtime: `IRONSOURCE_KEY` from API `ads_network_1_field_1_ios` or fallback `FallbackADConstants.ironSourceKey` | Fallback ends in **`f9fd`** (`19dd3f9fd`) |
| Unity game ID | `UNITY_KEY` / `FallbackADConstants.unityKey` | Ends in **`8630`** (`5268630`) |
| Ad unit format constants | IronSource SDK macros | `IS_INTERSTITIAL`, `IS_REWARDED_VIDEO`, `IS_BANNER` (not dashboard placement names) |
| ironSource **placementName** in show APIs | App calls `showInterstitial(with:)` / `showRewardedVideo(with:)` **without** a placement string | Dashboard default / UNKNOWN placement name |

App-internal `RewardAd` strings (`"Tryagain"`, `"FreeCoins"`, …) are **callback tags**, not IronSource `placementName` arguments.

### Suppression model (`PaymentHistory`)

- `paymentInfo() == true` → **show ads** (free / ads enabled).  
- Returns **false** (suppress) if: active subscription / lifetime, **or** `ADS_TYPE == 0`, **or** legacy paid-app user.  
- `paymentInfoVerify()` ignores `ADS_TYPE` (subscription/legacy only) — used for watermark UI, not as the main interstitial gate.

---

## Placement table

| # | Screen / feature | Format | Trigger | Frequency | Position | ironSource placement | File:line (show/load) | Suppression |
|---|------------------|--------|---------|-----------|----------|----------------------|------------------------|-------------|
| 1 | Reader – chapter swipe | Interstitial | Finished chapter swipe (`noteChapterSwipe`) | Every N swipes this session; N = `show_interstitial_row` (fallback **10**). Plus global **120s** between shows | Full screen | No placement arg (default) | `ReaderViewController.swift` **936–958** (`IndestrialAd` → `IronSource_Interstitial_ShowAds`) | `paymentInfo()` |
| 2 | Reader – Verse Image browse | Interstitial | Wallpaper tap/swipe (`CallWallpaperAds`) | Every **10th** this session + 120s gate | Full screen | Default | `ReaderViewController.swift` **947–958**; callers `WallpaperView.swift` ~454, ~532 | `paymentInfo()` |
| 3 | Reader – verse UI actions | Interstitial | `CallAds` from reader source | Every **5th** action (`LastClickCount`) + 120s | Full screen | Default | `ReaderViewController.swift` **919–932**; caller `ReaderSourceViewController.swift` **260** | `paymentInfo()` |
| 4 | Reader – Verse Image Save | Interstitial | Save from wallpaper | **Once per app session** + 120s | Full screen | Default | `ReaderViewController.swift` **2468–2473**; caller `WallpaperView.swift` **262** | `paymentInfo()` |
| 5 | Quiz Alert (Mark as Read) | Interstitial | Read / Yes / Dismiss | Once per alert session while `MARK_US_READ` (+ 120s) | Full screen | Default | `QuizAlertVC.swift` **88–90**, **114–117**, **135–139** | `paymentInfo() && MARK_US_READ` |
| 6 | Quiz Main – quit | Interstitial | Alert “Yes” give up | On confirm (+ 120s) | Full screen | Default | `QuizMainPageVC.swift` **603–604** | `paymentInfo()` |
| 7 | Quiz Scoreboard | Interstitial | Scoreboard flow when ads on | On that path (+ 120s) | Full screen | Default | `ScoreBoardVC.swift` **62–64** | `paymentInfo()` |
| 8 | Image Share result | Interstitial | Share VC load | On appear when ads on (+ 120s) | Full screen | Default | `ShareViewController.swift` **43–44** | `paymentInfo()` |
| 9 | Slide Card – Save | Interstitial | Save verse image card | **1st** save this session; then saves **10, 20, 30…** (+ 120s) | Full screen | Default | `SlideCardVC.swift` **700–716** | `paymentInfo()` |
| 10 | Quiz Main | Banner | `viewDidLoad`-ish setup | Persistent while on screen | Bottom / `AdsView` (inline) | Banner unit; no placement string | `QuizMainPageVC.swift` **188–192**; attach `IronSourceBanner.swift` **71–74** | `paymentInfo()`; else hide `AdsView` |
| 11 | Quiz Alert | Banner | `viewDidLoad` if online | Persistent | `AdBannerView` | Banner unit | `QuizAlertVC.swift` **74–82**; attach **76–78** | `paymentInfo()` + network |
| 12 | SharedViewController (share UI) | Banner | Screen open | Persistent | `BannerView` | Banner unit | `SharedViewController.swift` **59–66** | `paymentInfo()` |
| 13 | Image Share | Banner | Screen open | Persistent | `ADView` | Banner unit | `ShareViewController.swift` **70–75** | `paymentInfo()` |
| 14 | Ad Toast controller | Banner | Toast VC open | Persistent | `AdView` (square-ish) | Banner unit | `Ad_ToastController.swift` **34–39** | `paymentInfo()` |
| 15 | Quiz Result – Try Again | Rewarded | Try Again button | User tap; waits up to ~15s for load | Full screen | Default show API; app tag `"Tryagain"` | `ResultPopupVC.swift` **171–175**; reward `AdmobManager.swift` **254–255** | Network only (no `paymentInfo`) |
| 16 | Quiz Wallet – free credits | Rewarded | Watch-ad button | User tap | Full screen | Tag `"FreeCoins"` | `WalletViewController.swift` **216–219**; reward **256–257** | Network; not subscription-gated |
| 17 | Quiz Main – free credits ad | Rewarded | Free-credits / watch ad | User tap | Full screen | Tag `"MainFreeCoins"` | `QuizMainPageVC.swift` **643**; reward **258–259** | Network |
| 18 | SubscrbViewController – Watch Ad | Rewarded | Watch Ad button | User tap | Full screen | Tag `"WatchAd"` | `SubscrbViewController.swift` **403–407**; reward → `AdDidClosed` path **260–261** / **444–452** (grants next-day ad-free via end date insert) | Network; on paywall |
| 19 | SubscrbViewController – unityAdOpen | Rewarded | `unityAdOpen()` | Caller-driven | Full screen | Tag `"SubscrbViewController"` | `SubscrbViewController.swift` **421–427** | Same reward close path as WatchAd |
| 20 | SubscriptionViewController – Watch Ad | Rewarded (via loading VC) | Watch Ad | Presents `InterstitialViewController` `LoadAdCatagory = "REWARDED"` | Full screen over paywall | Default; **no** app `RewardAd` tag wired to `AdmobManager` | `SubscriptionViewController.swift` **119–125**; show `InterstitialViewController.swift` **51–54**, **141–149** | **No `paymentInfo()` check** |
| 21 | Gift Card – open with ad | Rewarded | Open card when ad required | User path | Full screen | Tag `"OpenCard"` | `GiftCardVC.swift` **236–239**; reward **266–267** → `cardNavigate` | User path; sets `CardAdTime` |
| 22 | Gift Card claim – double | Rewarded | Ad click on claim | User tap | Full screen | Tag `"Scratch"` | `GiftCardClaimVC.swift` **165–171**; reward **262–263** → double credits | Network |
| 23 | Image editor – watermark | Rewarded | Remove watermark | User tap | Full screen | Tag `"ImageWatermark"` | `IMageEditingPageVc.swift` **181–185**; reward **264–265** → hide watermark | Network; watermark shown via `paymentInfoVerify()` |
| 24 | Paywall trigger – credits | Rewarded | “Watch” for credits | User tap on trigger sheet | Full screen | Tag `"PaywallTrigger"` | `PaywallTriggerScreens.swift` **632–643**; reward **270–271** → wallet credits | On paywall trigger UI |
| 25 | Paywall trigger – images | Rewarded | Watch for 3 more images | User tap | Full screen | Tag `"PaywallTrigger"` | `PaywallTriggerScreens.swift` **717–724** | On paywall trigger UI |
| — | App launch preload | Interstitial + Rewarded load | After GetAppInfo success (~3.5s / +2.5s) | N/A (load only) | N/A | Init + load | `AppDelegate.swift` **501–506** | `ADS_DISABLED_FOR_TESTING`; not gated by `paymentInfo` |
| — | Wallpaper open | Interstitial load | Open wallpaper nib | Load only | N/A | — | `ReaderViewController.swift` **2152–2153** | `paymentInfo()` |
| — | Slide Card appear | Interstitial load | Screen setup | Load only | N/A | — | `SlideCardVC.swift` **119–120** | `paymentInfo()` |

---

## Edge cases

### Rewarded video — user gets

| App `RewardAd` tag | Reward on `didReceiveReward` |
|--------------------|------------------------------|
| `Tryagain` | Navigate back / try again (`NavigateBack`) |
| `FreeCoins` | Add `rewardCoins` to wallet |
| `MainFreeCoins` | Same as free coins on quiz main |
| `WatchAd` / `SubscrbViewController` | `AdDidClosed` → temporary “ad-free until tomorrow” style end-date insert on subscription VC |
| `Scratch` | **2×** gift-card credits |
| `ImageWatermark` | Hide watermark for that edit |
| `OpenCard` | Unlock gift card navigation; stamp `CardAdTime` |
| `PaywallTrigger` | Credits to wallet **or** +3 image download bonus (closure set before show) |

### App launch / foreground

- **Splash:** `OpenAd()` does **not** show IronSource; pushes Reader.  
- **AppDelegate:** preloads interstitial + rewarded after config; initializes Unity.  
- **SceneDelegate.sceneDidBecomeActive:** resumes quiz music only — **no ads**.  
- **HomeController** foreground observer: not an ad show path (not re-audited as ad).

### Loaded but never shown / dead code

| Item | Notes |
|------|--------|
| `UnityAdClass.loadInterstitial_UnityAds` / `loadRewarded_UnityAds` | **Never called** outside `UnityAdClass.swift`. Only `initializeIfNeeded()` is used. |
| `Interstitial_ID = "OpenSplash"` | Handled in close/fail callbacks; **never assigned** in app. |
| `ReaderViewController.CallInterstitialAd()` | Updates `AdTime` only; **does not show** an ad. Called from `ReaderSourceViewController` **321**. |
| `SaveImage` interstitial | Commented out. |
| `StoreManager` WatchAd | Commented out. |
| `IronSourceBanner` case `ReaderSourceViewController` | Attach path exists; **no** `ViewControl = ReaderSourceViewController` assignment found → effectively unused. |
| `BannerAd` collection cell | UI holder only; no IronSource load in cell. |
| `GoogleUserMessagingPlatform` | In Podfile; **no** app usage of consent form APIs found. |
| Duplicate ad stack | `InterstitialViewController` reimplements IronSource show (parallel to `AdmobManager`). |

### Test mode

| Flag | Value | Risk |
|------|-------|------|
| `ADS_DISABLED_FOR_TESTING` | `false` (`AppConstants.swift` ~67) | Ads on |
| `UNITY_TEST_MODE` | **`true`** (`AppConstants.swift` ~116) | Unity init uses test mode even if shows were wired |
| `validateIntegration` / `setAdaptersDebug` | Not called in app Swift | OK for release |

### Consent / tracking

- **ATT:** `ATTrackingManager.requestTrackingAuthorization` in `Onboarding1.swift` (~122, ~251). Splash ATT code commented.  
- **IronSource `setConsent` / `setMetaData`:** not called in app Swift.  
- **Child-directed:** not found in app ad setup.  
- **Init vs consent:** IronSource init/load from `AppDelegate` after API; ATT on onboarding — order vs first ad show is **UNKNOWN - needs human check**.

### Mediation / Pods

From `Podfile` / `Podfile.lock` (app-relevant):

- `IronSourceSDK` (8.1.0.0)  
- `IronSourceAdQualitySDK` (via UnityAds dependency)  
- `UnityAds` (4.20.0) — direct SDK present; **not** listed as IronSource mediation adapter pods (no ISAdMobAdapter, etc.)  
- `GoogleUserMessagingPlatform`  
- `Flurry-iOS-SDK`, `FBSDKShareKit` (analytics/share — not ad mediation adapters)

**No AdMob mediation adapter pods.**

### StoreKit / premium link

- Active subscription / lifetime / legacy paid → `paymentInfo()` false → interstitial/banner paths that check it are suppressed.  
- Store updates set `isPurchased`, payment Core Data, `HasLifetimePurchase`, etc. (`StoreManager`, payment VCs).  
- **Rewarded** and **paywall Watch Ad** generally still available to free users (and on paywall).  
- `ADS_TYPE == 0` kills ads via `paymentInfo()` even without purchase.

### Onboarding / paywall / purchase screens

- Onboarding: ATT only; no IronSource show found.  
- Paywall triggers: rewarded (`PaywallTrigger`).  
- `SubscrbViewController` / `SubscriptionViewController`: rewarded Watch Ad **on purchase UI**.

---

## Manager / helper map

| File | Role |
|------|------|
| `AdmobManager.swift` | Primary IronSource interstitial + rewarded load/show, 120s interstitial cooldown, reward tags |
| `IronSourceBanner.swift` | Banner init/load/attach by top VC type |
| `UnityAdClass.swift` | Unity init + unused show pipeline |
| `InterstitialViewController.swift` | Alternate full-screen IronSource loader (subscription Watch Ad) |
| `PaymentHistory.swift` | Ad suppression gates |
| `AppConstants.swift` / `AppConfig.swift` / `GetAppInfo.swift` | Keys, `ADS_TYPE`, `show_interstitial_row`, fallbacks |

---

## Verification

Re-searched app Swift (excluding Pods) for:

- `IronSource.` init/load/show/banner  
- `IronSource_Interstitial_ShowAds` / `_AdLoad`  
- `IronSource_Reward_ShowAds` / `_AdLoad`  
- `IronSource_Banner_AdLoad`  
- `showRewardedVideo` / `showInterstitial` / `loadBanner` / `loadInterstitial`  
- `RewardAd:` string tags  
- `UnityAdClass` / `loadInterstitial_UnityAds` / `loadRewarded_UnityAds`  
- `validateIntegration` / `setAdaptersDebug` / `setConsent` (app)  
- `Interstitial_ID` / `OpenSplash`  
- `paymentInfo(` around ad calls  

Each live show/load path is in the table or Summary flat list; unused items are under **Loaded but never shown / dead code**.

**Verification done: 18 search terms checked, 25 table placements (incl. preload rows), 8 unused/dead items.**
