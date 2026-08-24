# Exit Offer & TTS Porting Guide

Use this as a reference to implement the same behavior in another app. File names below match the current project.

## 1) Exit Offer – Product Load at Splash
- **File:** `NewOnboarding/StoreManager.swift`
- **Entry:** `static func preloadProducts()`
- **Call from splash:** invoke `StoreManager.preloadProducts()` during splash to load API params and IAP products early.

```swift
// In splash (pseudo):
StoreManager.preloadProducts()
```

Key parts:
```swift
// StoreManager.swift
static func preloadProducts() {
    // pulls params via GetAppInfo, then setupProducts
    if NetworkManager.sharedInstance.isConnectedToInternet() {
        GetAppInfo.shared.CallParams()
    } else {
        GetAppInfo.shared.loadFallbackOrCachedData()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        if IS_SUBSCRIPTION_ENABLE == 1 {
            shared.setupProducts()
        }
    }
}
```

## 2) Exit Offer – IDs and Config
- **File:** `NKJV Bible/App/App Settings/AppConstants.swift`
  - `var SUBSCRIPTIONID_ExitOffer = ""`
- **File:** `NKJV Bible/App/Support/GetAppInfo.swift`
  - Populates `SUBSCRIPTIONID_ExitOffer = UserDefaults["sub_identifier_exit_offer"] ?? FallbackIAPConstants.exitOfferProductID`
- **File:** `NewOnboarding/StoreManager.swift`
  - `private var exitOfferProductID: String { SUBSCRIPTIONID_ExitOffer }`
  - `fetchExitOfferProduct()` issues `SKProductsRequest` for that ID
  - Texts for the sheet loaded via `loadExitOfferText()` using API fields `sub_identifier_exit_offer_value/item1/item2`

## 3) Exit Offer – UI & Timer Logic
- **File:** `NewOnboarding/BibleSubscriptionView.swift`
- Manual first show (X tap in header): saves start time, shows sheet, starts timer.
- Auto show on re-entering IAP: only if start time exists AND time remaining > 0; never after expiry.
- Timer: `exitOfferTimerTask` recomputes remaining time from `ExitOfferStartTime`; on expiry sets `ExitOfferExpired = true` and clears start.
- Keys: `ExitOfferStartTime`, `ExitOfferTimeRemaining`, `ExitOfferExpired`, `ExitOfferFirstInstallShown`.
- Duration: `exitOfferTimerDuration = 600` seconds.

## 4) TTS Voice Change Fixes

### a) Core speaker fallback
- **File:** `NKJV Bible/App/Controller/Text To Speach/Speaker.swift`
- Validates requested voice, matches by similarity if needed, then falls back to same-language or default.
```swift
// Speaker.swift (speak)
let requestedVoiceID = speechSettings[0]
if let requested = AVSpeechSynthesisVoice(identifier: requestedVoiceID) {
    utterance.voice = requested
} else {
    let languageCode = extractLanguageCode(from: requestedVoiceID)
    let voices = AVSpeechSynthesisVoice.speechVoices()
    let similar = voices.first { v in
        v.language == languageCode && (
            requestedVoiceID.lowercased().contains(v.name.lowercased()) ||
            v.identifier.lowercased().contains(requestedVoiceID.lowercased()) ||
            v.name.lowercased().contains(requestedVoiceID.lowercased())
        )
    }
    if let similar = similar {
        utterance.voice = similar
    } else if let fallback = voices.first(where: { $0.language == languageCode }) {
        utterance.voice = fallback
    } else {
        utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
    }
}
```

### b) Voice list filtering & display labels
- **File:** `NKJV Bible/App/Xib/Speechframe/SpeechVu.swift`
- Filters/matches configured voices to device voices; if few matches, adds a small set of same-language device voices as fallback.
- English labels normalized (e.g., "English" + "United States [Samantha]").
- Prevents verse auto-advance when changing voice (flags `isChangingVoice`, `voiceChangeStartIndex`).
- Validates selection; replays current verse with new voice without skipping.

Key snippets:
```swift
// Matching to device voices (languageFilter)
if let match = findMatchingVoice(languageCode: languageCode,
                                configuredID: configuredID,
                                configuredName: configuredName) {
    langID.append(match.identifier)    // actual device identifier
    lang.append(configuredName)        // configured display name (or English-friendly label)
}
// If very few matches, add a handful of same-language device voices as fallback (capped)
```

```swift
// Prevent verse advance on voice change (SpeechVu)
if isChangingVoice {
    if Index == voiceChangeStartIndex {
        isChangingVoice = false
        voiceChangeStartIndex = -1
        ReloadPlayerIcons()
        return
    } else { ReloadPlayerIcons(); return }
}
```

```swift
// On voice select
self.isChangingVoice = true
self.voiceChangeStartIndex = self.Index
synth.synth.stopSpeaking(at: .immediate)
DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
    self.PlayTS(self.Verse.text!) // replay current verse with new voice
}
```

## 5) What to copy to the new app
- IAP/Exit Offer:
  - `AppConstants.swift`: declare `SUBSCRIPTIONID_ExitOffer`
  - `GetAppInfo.swift`: load `sub_identifier_exit_offer` into `SUBSCRIPTIONID_ExitOffer`
  - `StoreManager.swift`: `preloadProducts()`, `setupProducts()`, `fetchExitOfferProduct()`, `loadExitOfferText()`, `exitOffer*` published props
  - `BibleSubscriptionView.swift`: exit-offer UI, timers, UserDefaults keys, show/hide rules
- TTS:
  - `Speaker.swift`: safe voice selection with similarity + fallback
  - `SpeechVu.swift`: device voice matching, English-friendly labels, voice-change no-skip flags

## 6) Splash preload reminder
Call `StoreManager.preloadProducts()` from your splash/launch sequence to preload IAP (including exit offer) before showing IAP UI.


