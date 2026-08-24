//
//  Speaker.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 20/01/21.
//

import UIKit
import AVFoundation

class Speaker: NSObject,AVSpeechSynthesizerDelegate {
    let synth = AVSpeechSynthesizer()
    var utteranceRate = 0.4
    var myUtterance:AVSpeechUtterance?

        override init() {
            super.init()
            synth.delegate = self
        }

        func speak(_ string: String) {
            
            self.myUtterance = AVSpeechUtterance(string: string)
            
            let speeches = CoreDataModel.sharedInstance.GetSavedSpeechSettings(entity: CDSpeechSetting)
            let speechSettings = speeches.components(separatedBy: "/")
            
            // DEVICE COMPATIBILITY FIX: Validate voice availability before using
            let requestedVoiceID = speechSettings[0]
            
            // Try to create the voice with the requested identifier
            if let requestedVoice = AVSpeechSynthesisVoice(identifier: requestedVoiceID) {
                // Voice is available on this device
                self.myUtterance!.voice = requestedVoice
                print("✅ [Speaker] Using voice: \(requestedVoiceID)")
            } else {
                // Voice not available - find a suitable fallback
                print("⚠️ [Speaker] Voice '\(requestedVoiceID)' not available, finding fallback...")
                
                // Extract language code from the identifier
                let languageCode = extractLanguageCode(from: requestedVoiceID)
                
                // Try to find an available voice for the same language
                let availableVoices = AVSpeechSynthesisVoice.speechVoices()
                
                // First, try to find a voice with similar name
                let voiceNameLower = requestedVoiceID.lowercased()
                let similarVoice = availableVoices.first { voice in
                    voice.language == languageCode && (
                        voiceNameLower.contains(voice.name.lowercased()) ||
                        voice.name.lowercased().contains(voiceNameLower) ||
                        voice.identifier.lowercased().contains(voiceNameLower)
                    )
                }
                
                if let similarVoice = similarVoice {
                    self.myUtterance!.voice = similarVoice
                    print("   → Using similar voice: \(similarVoice.identifier) (\(similarVoice.name))")
                } else {
                    // Try any voice for the same language
                    let fallbackVoice = availableVoices.first { voice in
                        voice.language == languageCode
                    }
                    
                    if let fallbackVoice = fallbackVoice {
                        self.myUtterance!.voice = fallbackVoice
                        print("   → Using fallback voice: \(fallbackVoice.identifier) for language: \(languageCode)")
                    } else {
                        // Last resort: use default voice for current locale
                        let defaultVoice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
                        self.myUtterance!.voice = defaultVoice
                        print("   → Using default system voice: \(defaultVoice?.identifier ?? "system default")")
                    }
                }
            }
            
            self.myUtterance!.rate = Float(speechSettings[3]) ?? AVSpeechUtteranceDefaultSpeechRate
            self.myUtterance!.pitchMultiplier = Float(speechSettings[2]) ?? 1.0
            
            synth.speak(self.myUtterance!)
        }
    
        // Helper function to extract language code from voice identifier
        private func extractLanguageCode(from identifier: String) -> String {
            // Voice identifiers typically contain language codes like "en-US", "es-MX", etc.
            // Examples:
            // "com.apple.ttsbundle.Samantha-compact" -> look for pattern
            // "com.apple.ttsbundle.siri_female_en-US_compact" -> "en-US"
            
            let pattern = "[a-z]{2}-[A-Z]{2}"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: identifier, range: NSRange(identifier.startIndex..., in: identifier)),
               let range = Range(match.range, in: identifier) {
                return String(identifier[range])
            }
            
            // If we can't extract language code, default to English
            return "en-US"
        }
}

