//
//  MusicBgFile.swift
//  General Quiz
//
//  Created by ajayprasanth on 01/09/23.
//

import UIKit
import AVFoundation



class MusicBgFile: NSObject, AVAudioPlayerDelegate {

     static let sharedInstance = MusicBgFile()
    
    var player: AVAudioPlayer?
    var MusicName:[String] = ["The Thinking Time"]
    
    func playSound() {
        let url = Bundle.main.url(forResource: MusicName[0], withExtension: "wav")!

        do {
            player = try AVAudioPlayer(contentsOf: url)
            self.player!.delegate = self
            guard let player = player else { return }
            player.prepareToPlay()
            if UserDefaults.standard.bool(forKey: "MusicSwitch") {
                player.play()
            }
            player.volume = 0.2

        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playSound()
    }
    
    
    
    
    func stop() {
        player?.pause()
    }
    
    
    
}









class HomeBgFile: NSObject, AVAudioPlayerDelegate {

     static let sharedInstance = HomeBgFile()
     var player: AVAudioPlayer?
    
    func playSound() {
        let url = Bundle.main.url(forResource: "happy", withExtension: "mp3")!

        do {
            player = try AVAudioPlayer(contentsOf: url)
            self.player!.delegate = self
            guard let player = player else { return }
            player.prepareToPlay()
            if UserDefaults.standard.bool(forKey: "MusicSwitch") {
                player.play()
            }
            player.volume = 0.2

        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playSound()
    }
    
    
    
    
    func stop() {
        player?.pause()
    }
    
    
    
}
