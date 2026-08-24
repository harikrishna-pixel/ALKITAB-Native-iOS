# Text-to-Speech Voice Change Fix for iPhone SE and iPad

## Problem Summary
Two critical issues were identified and fixed:

1. **Voice Not Changing**: The TTS voice was not changing on certain devices like iPhone SE and iPad. When users selected a different voice from the voice picker, the app would continue using the default system voice instead of the selected one.

2. **Verse Auto-Advancing**: When changing the voice during playback, the app would automatically skip to the next verse instead of replaying the current verse with the new voice.

## Root Cause Analysis

### Issue 1: Voice Not Changing
The issue was caused by **missing voice availability validation**. The code was attempting to use voice identifiers that may not be available on all iOS devices:

1. **In `Speaker.swift`**: The code directly assigned a voice using `AVSpeechSynthesisVoice(identifier:)` without checking if the voice was available on the device.
2. **In `SpeechVu.swift`**: The voice list showed all configured voices regardless of device availability.
3. When `AVSpeechSynthesisVoice(identifier:)` receives an unavailable identifier, it returns `nil`, causing the system to fall back to the default voice silently.

### Issue 2: Verse Auto-Advancing
When changing voice during playback, the code would:
1. Stop the current speech (triggering `speechSynthesizer(_:didFinish:)`)
2. The delegate method had an old `ChangeVoice` flag that would increment the verse index
3. The new voice would play the NEXT verse instead of replaying the current one
4. This was inconsistent and confusing for users

## Solution Implemented

### 1. **Speaker.swift - Voice Validation with Fallback**
Added comprehensive voice availability checking with intelligent fallback logic:

```swift
// Before (Line 30):
self.myUtterance!.voice = AVSpeechSynthesisVoice(identifier: speechSettings[0])

// After:
if let requestedVoice = AVSpeechSynthesisVoice(identifier: requestedVoiceID) {
    // Voice is available on this device
    self.myUtterance!.voice = requestedVoice
} else {
    // Voice not available - find a suitable fallback
    // 1. Try to find another voice for the same language
    // 2. Fall back to default system voice if needed
}
```

**Key Features:**
- Validates voice availability before use
- Extracts language code from voice identifier
- Finds fallback voice in the same language
- Logs all voice changes for debugging
- Gracefully handles missing voices

### 2. **SpeechVu.swift - Filter Unavailable Voices**
Modified `languageFilter()` to only show voices that are actually available on the device:

```swift
// Get all available voices on this device
let availableVoiceIdentifiers = Set(AVSpeechSynthesisVoice.speechVoices().map { $0.identifier })

// Only add voices that are available
if availableVoiceIdentifiers.contains(voiceID) {
    // Add to list
} else {
    // Skip unavailable voice
}
```

**Key Features:**
- Filters voice list based on device availability
- Prevents users from selecting unavailable voices
- Provides fallback if no voices available for a language
- Logs filtered voices for debugging

### 3. **Voice Selection Validation & Verse Lock**
Added safety check and verse index locking in `tableView(_:didSelectRowAt:)`:

```swift
// Verify the voice is available before saving
if AVSpeechSynthesisVoice(identifier: selectedVoiceID) != nil {
    // VOICE CHANGE FIX: Set flag to prevent verse advancement
    if self.Playstatus {
        self.isChangingVoice = true
        self.voiceChangeStartIndex = self.Index  // Lock current verse
        
        // Stop and replay with new voice
        synth.synth.stopSpeaking(at: .immediate)
        // ... replay current verse
    }
} else {
    // Show error toast
    self.makeToast("This voice is not available on your device", duration: 2.0, position: .bottom)
}
```

**Key Features:**
- Locks verse index before stopping speech
- Prevents verse advancement during voice change
- Replays the SAME verse with new voice
- Clears flag after replay completes

### 4. **Speech Delegate Enhancement**
Modified `speechSynthesizer(_:didFinish:)` to handle voice changes:

```swift
// Check if speech finished during voice change
if isChangingVoice {
    if self.Index == self.voiceChangeStartIndex {
        // Replay finished at correct verse - clear flag
        self.isChangingVoice = false
        self.voiceChangeStartIndex = -1
        return  // Don't advance to next verse
    }
}
```

**Key Features:**
- Detects when speech finishes during voice change
- Prevents automatic verse advancement
- Validates verse index matches expected position
- Safely clears flags after completion

### 5. **Diagnostic Logging**
Added `logDeviceVoiceCapabilities()` function that logs:
- Device model and iOS version
- Total available voices
- Available languages
- Missing voices from our configured list

### 6. **State Management**
Added new state variables to track voice changes:
- `isChangingVoice`: Flag to indicate voice change in progress
- `voiceChangeStartIndex`: Stores the verse index when voice change started
- Flags are cleared in `StopSpeeking()` to prevent state corruption

## Files Modified

1. **`NKJV Bible/App/Controller/Text To Speach/Speaker.swift`**
   - Added voice availability validation
   - Added intelligent fallback logic
   - Added language code extraction helper
   - Added comprehensive logging

2. **`NKJV Bible/App/Xib/Speechframe/SpeechVu.swift`**
   - Modified `languageFilter()` to filter unavailable voices
   - Added voice validation in `tableView(_:didSelectRowAt:)`
   - Added `logDeviceVoiceCapabilities()` diagnostic function
   - Added device capability logging on initialization

## Testing Recommendations

### On iPhone SE:
1. Open the TTS voice picker
2. Verify only available voices are shown
3. Select different voices and confirm they work
4. **Test verse locking**: Play a verse, change voice mid-playback, verify it replays the SAME verse
5. Check console logs for any missing voices

### On iPad:
1. Same as iPhone SE testing
2. Pay special attention to Siri voices (some may not be available)
3. **Test verse locking**: Change voice multiple times during same verse

### On All Devices:
1. **Voice Change Tests**:
   - Change voice while paused (should stay on same verse)
   - Change voice during playback (should replay current verse with new voice)
   - Change voice at beginning of verse
   - Change voice at end of verse
   - Change voice multiple times in quick succession
2. Test pitch and speed adjustments
3. Verify fallback behavior works correctly
4. Check console logs for diagnostic information

## Console Log Examples

When the fix is working correctly, you'll see logs like:

```
📱 ========== DEVICE VOICE DIAGNOSTICS ==========
   Device Model: iPhone
   iOS Version: 17.0
   Total Available Voices: 45
   Languages Available: ar-SA, en-AU, en-GB, en-US, es-ES, ...
   ⚠️ Missing Voices on This Device: 3
      - Germany [Helena] (com.apple.ttsbundle.siri_female_de-DE_compact)
   ...
================================================

📱 [SpeechVu] Device has 45 available voices
   ℹ️ Filtered out 3 unavailable voices for language 'en'

🎤 [SpeechVu] Voice changed to: United States [Samantha]
   🔒 Voice change locked at verse index: 5
   → Stopping current playback and applying new voice
   → Replaying current verse at index 5: 'For God so loved the world...'
✅ [Speaker] Using voice: com.apple.ttsbundle.Samantha-compact

🚫 Speech finished during voice change (current index: 5, voice change started at: 5)
   ✅ Voice change replay finished at correct verse, clearing flag
```

## Benefits

1. **Device Compatibility**: Works on all iOS devices regardless of available voices
2. **User Experience**: Users only see voices they can actually use
3. **Graceful Degradation**: Automatically falls back to similar voices if preferred voice unavailable
4. **Verse Consistency**: Voice changes replay the current verse instead of skipping to the next one
5. **Predictable Behavior**: Users can change voices without losing their place
6. **Debugging**: Comprehensive logging helps identify voice availability issues
7. **No Silent Failures**: All voice issues are logged and handled properly

## Technical Notes

- Voice availability varies by iOS version and device model
- Siri voices (compact versions) may not be available on older devices
- The fix maintains backward compatibility with existing saved voice preferences
- Language fallback uses regex pattern matching to extract language codes from identifiers

## Future Improvements (Optional)

1. Add UI indicator showing which voices are premium/downloadable
2. Implement voice download prompts for unavailable voices
3. Cache voice availability checks for performance
4. Add user preference for fallback behavior
