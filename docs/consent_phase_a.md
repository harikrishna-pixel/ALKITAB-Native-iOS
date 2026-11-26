# Consent / ATT Phase A — Read-only findings

**App:** ALKITAB Native iOS (IronSource / LevelPlay **8.1.0.0**, StoreKit IAP, no AdMob ads SDK)  
**Date:** 2026-11-26 (re-verified against current tree)  
**Scope:** Investigation only. **No source files edited in Phase A.**

---

## A1. Launch sequence (to first ironSource init / load)

Ordered path with file:line. Parallel work is noted.

| # | Step | File:line | Notes |
|---|------|-----------|--------|
| 1 | `application(_:didFinishLaunchingWithOptions:)` | `AppDelegate.swift:43` | Welcome coins, Firebase (if enabled), IQKeyboard, first-open defaults. |
| 2 | First-open / returning branch | `AppDelegate.swift:89–173` | If first open (`AppOpenFirst == "0"`) or onboarding in progress → may call `app_INfo()` at `:120` (or `:161` after notification auth). If `AppOpenFirst == "1"` → `app_INfo()` at `:169–172`. |
| 3 | Scene connect | `SceneDelegate.swift:17–21` | Storyboard window only; **no ads / ATT / consent**. |
| 4 | Splash `viewDidLoad` | `SplashVc.swift:33–81` | Branding, optional dual splash, IAP preload, book unzip / returning path. Fresh empty `BookChapter` → `OnboardingProgress.markStarted()` (`:56`) + `defaultAppSelection()`. Returning: after min splash → `presentOnboarding()` or `OpenAd()` (`:77–80`). |
| 5 | Splash first-open data hook | `SplashVc.swift:215–221` (`LoadData`) | From AppDelegate when `LoadData` is false (`AppDelegate.swift:115–117`). Marks onboarding started → `presentOnboarding()`. |
| 6 | Present onboarding | `SplashVc.swift:269–282` | Dual → `DualOnboardingRoot`; else `BeforeOnboarding1` (old) or `Onboarding1` (pro). |
| 7 | ATT prompt (user tap Continue) | `Onboarding1.swift:120–129` (`Onboarding1`) and `Onboarding1.swift:249–258` (`BeforeOnboarding1`) | Only on Continue. Callback ignores status (`_`). **Dual onboarding does not call ATT** (no matches in `DualOnboarding.swift`). |
| 8 | `app_INfo()` network | `AppDelegate.swift:481–545` | POST `GET_APP_INFO` when online; else fallback. |
| 9 | Success + `API_Switch == "1"` | `AppDelegate.swift:493–507` | `SaveAppinfo` / `CallParams` (`:495–496`), then **`asyncAfter(+3.5s)`** → Unity init + **`AdmobManager.shared.IronSource_Interstitial_AdLoad()`** (`:501–503`), then **`+2.5s`** → **`IronSource_Reward_AdLoad()`** (`:504–505`). |
| 10 | API fail + `API_Switch == "1"` | `AppDelegate.swift:512–526` | Fallback data, then **same +3.5s / +2.5s IronSource loads**. |
| 11 | No internet + `API_Switch == "1"` | `AppDelegate.swift:530–543` | Fallback, Unity init, then **same +3.5s / +2.5s IronSource loads**. |
| 12 | First ironSource interstitial init + load | `AdmobManager.swift:54–61` | `setLevelPlayInterstitialDelegate` → `initWithAppKey` (×2) → `loadInterstitial()`. |
| 13 | First rewarded init + load | `AdmobManager.swift:238–245` | Same pattern for rewarded (+2.5s after interstitial block). |

**Also later:** `ReaderViewController` can call `prepareAdsForAppSession()` (`AdmobManager.swift:34–43`) which may call those load methods again if empty — still **no** consent/ATT gate.

**SceneDelegate:** no ATT, consent, or ironSource at connect (`SceneDelegate.swift:17–21`). Active scene only handles music / rate UI later.

### Can ironSource init run before the ATT prompt?

| Case | Answer |
|------|--------|
| **(a) Fresh install** | **Yes.** `app_INfo()` starts at launch; interstitial init is scheduled **3.5s after GetAppInfo returns** (or after fallback path starts the same delay). ATT only runs when the user taps **Continue** on `Onboarding1` / `BeforeOnboarding1`, which is after splash and can be many seconds later. There is **no** gate tying ATT completion to `IronSource_*_AdLoad`. Dual fresh installs using `DualOnboardingRoot` **never** hit those ATT call sites. |
| **(b) Existing user who already passed onboarding** | **ATT prompt is not shown** in normal flow (onboarding skipped → `OpenAd()` → Reader). ironSource still inits ~3.5s after GetAppInfo with **no** ATT/consent wait. If ATT was never answered (`notDetermined`), this app **does not re-request** it on return launches. |

---

## A2. ATT — every `ATTrackingManager` call

| Location | What happens |
|----------|----------------|
| `Onboarding1.swift:122` | `requestTrackingAuthorization { _ in … navigateToNext = true }`. **Status ignored.** |
| `Onboarding1.swift:251` | Same in `BeforeOnboarding1`. **Status ignored.** |
| `SplashVc.swift:289` (commented) | Old commented path only — **not executed**. |

**No other Swift call sites** for `ATTrackingManager` / `trackingAuthorizationStatus` / `requestTrackingAuthorization`.

### Status behavior (actual app code)

| Status | App behavior |
|--------|----------------|
| `notDetermined` | System prompt shown (only if those Continue handlers run). Then navigation continues regardless of choice. |
| `authorized` | Prompt not shown again by system; handler still fires → navigate. App does **not** branch on status. |
| `denied` | Same — navigate; no restrictive ad flags applied. |
| `restricted` | Same — navigate; no special handling. |

**Info.plist / build setting:** `NSUserTrackingUsageDescription` is set via **`INFOPLIST_KEY_NSUserTrackingUsageDescription`** in `project.pbxproj` (Debug/Release). Not duplicated as a raw key inside `NKJV Bible/Info.plist` body (generated merge). Tracking usage string exists for ATT.

---

## A3. IronSource SDK 8.1.0.0 — consent / privacy APIs (from installed headers)

Source: `Pods/IronSourceSDK/.../IronSource.framework/Headers/IronSource.h` and `ISMetaDataConstants.h`.

### Methods (quoted names)

From **`IronSource.h`:**

- `+ (void)setMetaDataWithKey:(NSString *)key value:(NSString *)value;` (line ~189)
- `+ (void)setMetaDataWithKey:(NSString *)key values:(NSMutableArray *)values;` (line ~199)
- `+ (void)setConsent:(BOOL)consent;` (line ~614)
- `+ (void)setConsentViewWithDelegate:(id<ISConsentViewDelegate>)delegate;` (line ~651)
- `+ (void)loadConsentViewWithType:(NSString *)consentViewType;` (line ~658)
- `+ (void)showConsentViewWithViewController:(UIViewController *)viewController andType:(NSString *)consentViewType;` (line ~665–666)

Related: `ISAdapterConsentProtocol` also declares `- (void)setConsent:(BOOL)consent;`.

`LevelPlay.h` in this pod exposes LevelPlay init APIs; **no** separate `LevelPlayPrivacySettings` type found in **8.1.0.0** headers searched.

### MetaData keys (from `ISMetaDataConstants.h`)

| Define | String key | Role |
|--------|------------|------|
| `kMetaDataCCPAKey` | `@"do_not_sell"` | CCPA / do-not-sell |
| `kMetaDataISCOPPAKey` | `@"is_child_directed"` | Child-directed / COPPA |
| `kMetaDataTrueValue` / `kMetaDataFalseValue` | `@"true"` / `@"false"` | Values |

**GDPR:** headers expose **`setConsent:`** — **no** separate GDPR meta key in `ISMetaDataConstants.h`.

**App Swift today:** **zero** calls to `setConsent` / `setMetaData*` / consent-view APIs (`rg` over `*.swift` = no matches).

---

## A4. UMP (`GoogleUserMessagingPlatform`)

| Check | Finding |
|-------|---------|
| Pod | `Podfile` includes `pod 'GoogleUserMessagingPlatform'`. **No** `Google-Mobile-Ads-SDK`. |
| App usage | **No** Swift `UMP*` / `UserMessagingPlatform` imports or calls. |
| `GADApplicationIdentifier` in `NKJV Bible/Info.plist` | **Absent** (file starts with BGTask / URL types / Firebase / ATS / SKAdNetwork — no GAD key). |
| Privacy messages | UMP loads messages configured under an **AdMob / Ad Manager** app’s Privacy & messaging; Google’s normal setup requires **`GADApplicationIdentifier`** in Info.plist. |

**Can a UMP consent message work without an AdMob app ID?**  
**No (for a working Privacy & messaging form).** Without `GADApplicationIdentifier` and a configured AdMob (or Ad Manager) privacy message, UMP has nothing reliable to fetch. Adding only the pod is not enough.

**Alternatives LevelPlay / ironSource support for this SDK version (8.1.0.0):**

1. **Manual flags before init:** `IronSource.setConsent(_:)` + `setMetaDataWithKey:value:` for `do_not_sell` / `is_child_directed` (values from a CMP or self-collected UI).  
2. **Another TCF-compatible CMP** that can feed consent; still pass `setConsent` if needed for non-TCF networks.  
3. **ironSource Consent View API** (`loadConsentViewWithType` / `showConsentViewWithViewController:andType:`) — SDK-hosted UI; **UNKNOWN - needs human check** whether enabled for this app key / still recommended.  
4. **UMP later** only if Praba adds a real AdMob app ID + Privacy & messaging config (would need Info.plist / project setting — Phase B must **ask** before Podfile/Info.plist changes).

---

## A5. Where is region known? (EEA/UK vs other)

| Signal | Exists in app? | Usable for EEA/UK? |
|--------|----------------|--------------------|
| `Locale.current.regionCode` as `Country_code` | **Yes** — `AppConstants.swift:307`; sent in some API payloads (`AppDelegate` ~`:429`) | **Best local signal today** — compare against an EEA/UK ISO list (not implemented). |
| `Locale.current.languageCode` | **Yes** (`language` at `:308`) | Language ≠ jurisdiction; weak alone. |
| StoreKit `priceLocale` / storefront | Used for **IAP price formatting only**; **no** `SKStorefront` / country used for ads consent. | Possible later; **not wired**. |
| GetAppInfo / API field for user country or “is_eea” | **Not found** — GetAppInfo stores language/TTS/config keys, not geo-consent. | **No**. |
| UMP `consentStatus` / geography | Unused | Would classify if UMP + AdMob messaging were configured. |
| Hardcoded EEA list | **None** | Would need to be added if self-collecting. |

**Verdict:** Only practical built-in signal today is **`Locale.current.regionCode` (`Country_code`)**. No authoritative “EEA/UK user” flag from backend.

---

## A6. Proposal — one `AdConsentManager`

**Goal:** One new file `AdConsentManager.swift`. Order on **every launch**:

1. **ATT** — If `trackingAuthorizationStatus == .notDetermined`, request once (coordinate with Onboarding1 / `BeforeOnboarding1` so the prompt is not shown twice). If already authorized/denied/restricted, skip prompt, record status. Dual path currently has **no** ATT — manager should cover that gap for dual/returning users.  
2. **Consent (only where required)** — Per Praba decision: EEA/UK-only or always; mechanism = manual restrictive default, custom UI, ironSource consent view, or UMP+AdMob ID if approved.  
3. **Set ironSource flags before any init** — `setConsent` from real result only (**never** hardcode `true`). Unknown / denied / failed → **`setConsent(false)`**. Set `do_not_sell` / `is_child_directed` per decisions (restrictive on unknown).  
4. **Then** invoke completion → **existing** AppDelegate `+3.5s` interstitial preload and nested `+2.5s` rewarded preload (**timing after callback, not before**).

### Edge handling

| Case | Proposed behavior |
|------|-------------------|
| Consent form fails / times out | Treat as **no consent** → restrictive flags → still complete callback so ads can init on limited path. Timeout value: **decide in Decisions**. |
| Airplane mode / GetAppInfo fails | Run ATT+consent flags **before** IronSource init. Today IronSource preload **also** runs on API-fail and offline fallback paths (`AppDelegate.swift:512–543`) — those schedules must wait on the same consent callback. Fallback IAP/app keys remain as today. |
| ATT already answered | No second prompt; read status and continue. |
| Onboarding1 / BeforeOnboarding1 Continue | Keep existing ATT call; `AdConsentManager` must detect “already requested this session / not notDetermined” so returning users and post-onboarding don’t double-prompt. Fresh install: either onboarding owns the prompt and manager waits/polls status, **or** manager owns ATT and onboarding only navigates if already determined — **decide in Decisions**. |

**Out of scope for Phase B (per task):** placements, frequencies, interstitial time gate, paywall, Unity behavior changes, Podfile versions, UI redesign beyond consent/ATT ordering.

---

## Decisions needed from Praba:

1. **Consent mechanism:** (A) Manual `setConsent` / meta only with **no** CMP UI (restrictive unless you later add UI), (B) Custom in-app consent UI (new UI — confirm allowed), (C) ironSource Consent View API, or (D) Enable UMP (requires AdMob app ID + Privacy & messaging + Info.plist `GADApplicationIdentifier` — confirm and provide ID)?
2. **Who must see a consent UI:** EEA/UK only (via `Locale.regionCode` list), or all users, or UMP-decided geography only?
3. **If (2) uses locale list:** approve using `Country_code` / `Locale.current.regionCode`, and confirm UK + EEA set (or provide the list).
4. **Denied / unknown / timeout consent:** confirm **init ironSource anyway** with `setConsent(false)` (recommended for this task), or **block init entirely** until consent obtained?
5. **Consent timeout seconds** (e.g. 5 / 10 / 15) before restrictive fallback?
6. **CCPA `do_not_sell`:** always `"false"`, always `"true"` until opt-out UI exists, set only for US `regionCode`, or skip meta key for now?
7. **COPPA `is_child_directed`:** always `"false"` (adult Bible app), or skip setting it?
8. **ATT ownership:** (A) Keep prompt in Onboarding1 / BeforeOnboarding1; AdConsentManager only requests if still `notDetermined` after onboarding / on return launches, or (B) Move ATT fully into AdConsentManager and make onboarding Continue a no-op if already determined?
9. **Return launch:** confirm consent flags are re-applied every launch (no re-prompt if already answered) before the 3.5s ironSource schedule — yes/no?
10. **Phase B go-ahead:** reply **`go`** with answers to 1–9 (short form is fine).

---

**Phase A complete. STOP — no source edits until `go` + decisions.**
