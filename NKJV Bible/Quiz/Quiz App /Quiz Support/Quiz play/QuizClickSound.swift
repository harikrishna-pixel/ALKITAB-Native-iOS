//
//  QuizClickSound.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 24/02/23.
//

import UIKit
import AVFoundation

class QuizClickSound: NSObject {
    
    var player: AVAudioPlayer?
    
    static let shared = QuizClickSound()
    var MusicName:[String] = ["SelectMusic", "DeSelectMusic", "GameClick", "Answer", "wrongAnswer", "CoinCollect", "CardSound", "Card Open"]
    var record:Int = 0
      
    func playSound() {
        let url = Bundle.main.url(forResource: MusicName[record], withExtension: "wav")!

        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.prepareToPlay()
            player.play()
            player.volume = 0.6

        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func SelectMusic() {
        if UserDefaults.standard.bool(forKey: "ToneSwitch") {
            self.record = 0
            self.playSound()
        }
    }
    
    func DeSelectMusic() {
        if UserDefaults.standard.bool(forKey: "ToneSwitch") {
            self.record = 1
            self.playSound()
        }
    }
    
    func ClickSound() {
        if UserDefaults.standard.bool(forKey: "ToneSwitch") {
            self.record = 2
            self.playSound()
        }
    }
    
    
    func CorrectSound() {
        if UserDefaults.standard.bool(forKey: "ToneSwitch") {
            self.record = 3
            self.playSound()
        }
    }
    
    func WrongSound() {
        if UserDefaults.standard.bool(forKey: "ToneSwitch") {
            self.record = 4
            self.playSound()
        }
    }
    
    
    func CoinCollectSound() {
        if UserDefaults.standard.bool(forKey: "ToneSwitch") {
            self.record = 5
            self.playSound()
        }
    }
    
    func CardCollectSound() {
        if UserDefaults.standard.bool(forKey: "ToneSwitch") {
            self.record = 7
            self.playSound()
        }
    }
    
    
    
}

