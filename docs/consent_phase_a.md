# Consent / ATT Phase A — Read-only findings

**App:** ALKITAB Native iOS (IronSource / LevelPlay **8.1.0.0**, StoreKit IAP, no AdMob ads SDK)  
**Date:** 2026-11-24  
**Scope:** Investigation only. No source files edited in Phase A.

---

## A1. Launch sequence (to first ironSource init / load)

Ordered path with file:line. Parallel work is noted.

| # | Step | File:line | Notes |
|---|------|-----------|--------|
| 1 | `application(_:didFinishLaunchingWithOptions:)` | `AppDelegate.swift:43` | Firebase, IQKeyboard, first-open defaults. |
| 2 | First-open / returning branch | `AppDelegate.swift:89–173` | If `AppOpenFirst == "0"` or onboarding in progress → async `app_INfo()` at `:120`. If `AppOpenFirst == "1"` → `app_INfo()` at `:169–172`. |
| 3 | Scene connect | `SceneDelegate.swift:17–21` | Storyboard window only; **no ads / ATT / consent**. |
| 4 | Splash `viewDidLoad` | `SplashVc.swift:33–114` | Sets `DelegateSplash`, IAP preload, book data. Fresh: empty `BookChapter` → `OnboardingProgress.markStarted()` (`:55`) + `defaultAppSelection()`. Returning: may `presentOnboarding()` or `OpenAd()` (`:74–78`). |
| 5 | Splash first-open data hook | `SplashVc.swift:212–218` (`LoadData`) | Called from AppDelegate when `LoadData` false (`AppDelegate.swift:115–117`). Presents onboarding after min splash. |
| 6 | Present onboarding | `SplashVc.swift:255–264` | `Onboarding1` or `BeforeOnboarding1` (same ATT on Continue). |
| 7 | ATT prompt (user tap Continue) | `Onboarding1.swift:120–129` and `Onboarding1.swift:249–258` | Only when user taps Continue. Callback ignores status (`_`). |
| 8 | `app_INfo()` network | `AppDelegate.swift:481–531` | POST `GET_APP_INFO`. |
| 9 | On success + `API_Switch == "1"` | `AppDelegate.swift:493–507` | `SaveAppinfo` / `CallParams` (`:495–496`), then **`DispatchQueue.main.asyncAfter(+3.5s)`** → Unity init + **`AdmobManager.shared.IronSource_Interstitial_AdLoad()`** (`:501–503`), then **`+2.5s`** → **`IronSource_Reward_AdLoad()`** (`:504–505`). |
| 10 | First ironSource init + interstitial load | `AdmobManager.swift:41–48` | `setLevelPlayInterstitialDelegate` → `initWithAppKey` (×2) → `loadInterstitial()`. |
| 11 | First rewarded init + load | `AdmobManager.swift` (~224–229) | Same pattern for rewarded, scheduled +2.5s after interstitial block. |

**Airplane / API fail:** `AppDelegate.swift:512–530` loads fallback and may init Unity; **does not** call `IronSource_*_AdLoad` on that path.

**SceneDelegate:** no ATT, consent, or ironSource (`SceneDelegate.swift:31+` is music / rate prompt only).

### Can ironSource init run before the ATT prompt?

| Case | Answer |
|------|--------|
| **(a) Fresh install** | **Yes.** `app_INfo()` starts at launch; interstitial init is scheduled **3.5s after GetAppInfo returns**. ATT only runs when the user taps **Continue** on `Onboarding1` / `BeforeOnboarding1`, which is usually **after** splash (≥1.2s) and can be many seconds later. There is **no** gate tying ATT completion to `IronSource_Interstitial_AdLoad`. |
| **(b) Existing user who already passed onboarding** | **ATT prompt is not shown again** in normal flow (onboarding skipped; `OpenAd()` → Reader). ironSource still inits ~3.5s after GetAppInfo with **no** ATT/consent wait. If ATT was never answered (`notDetermined`), this app **never re-requests** it on return launches. |

---

## A2. ATT — every `ATTrackingManager` call

| Location | Live? | Behavior |
|----------|-------|----------|
| `Onboarding1.requestTrackingThenContinue` `Onboarding1.swift:122` | **Yes** | `requestTrackingAuthorization { _ in … navigateToNext = true }` — **status ignored**. |
| `BeforeOnboarding1.requestTrackingThenContinue` `Onboarding1.swift:251` | **Yes** (old onboarding) | Same as above. |
| `SplashVc.swift:271` (commented) | **No** | Old commented popup path. |
| `AppDelegate.swift` | Import only (`:14`); **no** `ATTrackingManager` call. | |

`NSUserTrackingUsageDescription` is set via build setting `INFOPLIST_KEY_NSUserTrackingUsageDescription` in `project.pbxproj` (not in `NKJV Bible/Info.plist` body).

### Status handling (what the **app** does today)

| Status | App behavior |
|--------|----------------|
| `notDetermined` | System shows ATT dialog (on Continue). Completion always continues onboarding; **no** ironSource flag update. |
| `authorized` | Completion continues; **no** IDFA / consent wiring to ironSource. |
| `denied` | Same — continue onboarding; **no** restrictive ad flags. |
| `restricted` | Same as denied from app’s perspective (ignored `_`). |
| Already answered (return launch) | Onboarding skipped → **no call**. System would no-op a re-request; app never calls it. |

---

## A3. IronSource 8.1.0.0 consent / privacy APIs (from installed headers)

Source: `Pods/IronSourceSDK/.../IronSource.framework/Headers/IronSource.h` and `ISMetaDataConstants.h`.

### Methods (quoted names)

```objc
+ (void)setMetaDataWithKey:(NSString *)key value:(NSString *)value;
+ (void)setMetaDataWithKey:(NSString *)key values:(NSMutableArray *)values;
+ (void)setConsent:(BOOL)consent;
+ (void)setConsentViewWithDelegate:(id<ISConsentViewDelegate>)delegate;
+ (void)loadConsentViewWithType:(NSString *)consentViewType;
+ (void)showConsentViewWithViewController:(UIViewController *)viewController
                                  andType:(NSString *)consentViewType;
```

Also on adapters: `ISAdapterConsentProtocol` / `ISBaseAdapter` `- (void)setConsent:(BOOL)consent;` (SDK-internal).

`LevelPlay.h` in this pod only exposes `initWithRequest:completion:` — **no** `LevelPlayPrivacySettings` in **8.1.0.0**.

### MetaData keys (from `ISMetaDataConstants.h`)

| Define | String key | Role |
|--------|------------|------|
| `kMetaDataCCPAKey` | `@"do_not_sell"` | CCPA / do-not-sell |
| `kMetaDataISCOPPAKey` | `@"is_child_directed"` | Child-directed / COPPA |
| `kMetaDataTrueValue` / `kMetaDataFalseValue` | `@"true"` / `@"false"` | Values |

**GDPR:** headers expose **`setConsent:`** — **no** separate GDPR meta key in `ISMetaDataConstants.h`.

**App Swift today:** zero calls to `setConsent` / `setMetaData*` / consent view APIs.

---

## A4. UMP (`GoogleUserMessagingPlatform`)

| Check | Finding |
|-------|---------|
| Pod | `Podfile` includes `pod 'GoogleUserMessagingPlatform'`. **No** `Google-Mobile-Ads-SDK`. |
| App usage | **No** Swift/`UMP*` / `UserMessagingPlatform` imports or calls. |
| `GADApplicationIdentifier` in `NKJV Bible/Info.plist` | **Absent**. |
| Privacy messages | UMP loads messages configured under an **AdMob / Ad Manager** app’s Privacy & messaging; Google docs require **`GADApplicationIdentifier`** in Info.plist. |

**Can a UMP consent message work without an AdMob app ID?**  
**No (for a working Privacy & messaging form).** Without `GADApplicationIdentifier` and a configured AdMob (or Ad Manager) privacy message, UMP has nothing to fetch. Adding only the pod is not enough.

**Alternatives LevelPlay / ironSource support for this SDK version (8.1.0.0):**

1. **Manual flags before init:** `IronSource.setConsent(_:)` + `setMetaDataWithKey:value:` for `do_not_sell` / `is_child_directed` (values from a CMP or self-collected UI).  
2. **Another TCF-compatible CMP** that can feed consent; still pass `setConsent` if needed for non-TCF networks.  
3. **ironSource Consent View API** (`loadConsentViewWithType` / `showConsentViewWithViewController:andType:`) — SDK-hosted UI; **UNKNOWN - needs human check** whether enabled for this app key / still recommended.  
4. **UMP later** only if Praba adds a real AdMob app ID + Privacy & messaging config (would need Info.plist / project setting — Phase B must **ask** before Podfile/Info.plist changes).

LevelPlay docs note UMP auto-share into LevelPlay from SDK **7.7.0+** when UMP is used correctly; this app still must set flags (or use a working CMP) because UMP is unused.

---

## A5. Where is region known? (EEA/UK vs other)

| Signal | Exists in app? | Usable for EEA/UK? |
|--------|----------------|--------------------|
| `Locale.current.regionCode` as `Country_code` | **Yes** — `AppConstants.swift:276`; sent in some API payloads (`AppDelegate` notification params `:429`) | **Best local signal today** — compare against an EEA/UK ISO list (not implemented). |
| `Locale.current.languageCode` | **Yes** (`language`) | Language ≠ jurisdiction; weak alone. |
| StoreKit `priceLocale` / storefront | Used for **IAP price formatting only**; **no** `SKStorefront` / country used for ads consent. | Possible later; **not wired**. |
| GetAppInfo / API field for user country or “is_eea” | **Not found** — GetAppInfo stores language/TTS/config keys, not geo-consent. | **No**. |
| UMP `consentStatus` / geography | Unused | Would classify if UMP + AdMob messaging were configured. |
| Hardcoded EEA list | **None** | Would need to be added if self-collecting. |

**Verdict:** Only practical built-in signal today is **`Locale.current.regionCode` (`Country_code`)**. No authoritative “EEA/UK user” flag from backend.

---

## A6. Proposal — one `AdConsentManager`

**Goal:** One new file `AdConsentManager.swift`. Order on **every launch**:

1. **ATT** — If `trackingAuthorizationStatus == .notDetermined`, request once (prefer coordinating with Onboarding1 so the prompt is not shown twice). If already authorized/denied/restricted, skip prompt, record status.  
2. **Consent (only where required)** — Per Praba decision: EEA/UK-only or always; mechanism = manual restrictive default, custom UI, ironSource consent view, or UMP+AdMob ID if approved.  
3. **Set ironSource flags before any init** — `setConsent` from real result only (**never** hardcode `true`). Unknown / denied / failed → **`setConsent(false)`**. Set `do_not_sell` / `is_child_directed` per decisions (restrictive on unknown).  
4. **Then** invoke completion → **existing** AppDelegate `+3.5s` interstitial preload and nested `+2.5s` rewarded preload (**timing after callback, not before**).

### Edge handling

| Case | Proposed behavior |
|------|-------------------|
| Consent form fails / times out | Treat as **no consent** → restrictive flags → still complete callback so ads can init non-personalized / limited path. Timeout value: **decide in Decisions**. |
| Airplane mode / GetAppInfo fails | Run ATT+consent flags **before** relying on API. Today IronSource preload is **only** on GetAppInfo success — keep that; consent manager still runs so a later init/show path gets flags. Fallback keys remain as today. |
| ATT already answered | No second prompt; read status and continue. |
| Onboarding1 Continue | Keep existing ATT call; `AdConsentManager` must detect “already requested this session / not notDetermined” so returning users and post-onboarding don’t double-prompt. Fresh install: either Onboarding1 owns the prompt and manager waits/polls status, **or** manager owns ATT and Onboarding1 only navigates if already determined — **decide in Decisions**. |

**Out of scope for Phase B (per task):** placements, frequencies, 120s gate, paywall, Unity behavior changes, Podfile versions, UI redesign beyond consent/ATT ordering.

---

## Decisions needed from Praba:

1. **Consent mechanism:** (A) Manual `setConsent` / meta only with **no** CMP UI (restrictive unless you later add UI), (B) Custom in-app consent UI (new UI — confirm allowed), (C) ironSource Consent View API, or (D) Enable UMP (requires AdMob app ID + Privacy & messaging + Info.plist `GADApplicationIdentifier` — confirm and provide ID)?
2. **Who must see a consent UI:** EEA/UK only (via `Locale.regionCode` list), or all users, or UMP-decided geography only?
3. **If (2) uses locale list:** approve using `Country_code` / `Locale.current.regionCode`, and confirm UK + EEA set (or provide the list).
4. **Denied / unknown / timeout consent:** confirm **init ironSource anyway** with `setConsent(false)` (recommended for this task), or **block init entirely** until consent obtained?
5. **Consent timeout seconds** (e.g. 5 / 10 / 15) before restrictive fallback?
6. **CCPA `do_not_sell`:** always `"false"`, always `"true"` until opt-out UI exists, set only for US `regionCode`, or skip meta key for now?
7. **COPPA `is_child_directed`:** always `"false"` (adult Bible app), or skip setting it?
8. **ATT ownership:** (A) Keep prompt in Onboarding1; AdConsentManager only requests if still `notDetermined` after onboarding / on return launches, or (B) Move ATT fully into AdConsentManager and make Onboarding1 Continue a no-op if already determined?
9. **Return launch:** confirm consent flags are re-applied every launch (no re-prompt if already answered) before the 3.5s ironSource schedule — yes/no?
10. **Phase B go-ahead:** reply **`go`** with answers to 1–9 (short form is fine).

---

**Phase A complete. STOP — no source edits until `go` + decisions.**
