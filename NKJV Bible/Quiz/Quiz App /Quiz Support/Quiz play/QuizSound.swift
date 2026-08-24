//
//  QuizSound.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 24/02/23.
//

import UIKit
import AVFoundation


//class QuizSound: NSObject, AVAudioPlayerDelegate {

//extension QuizMainPageVC {
//    
//    
//     
//    func playSound() {
//        let url = Bundle.main.url(forResource: MusicName[recard], withExtension: "wav")!
//
//        do {
//            player = try AVAudioPlayer(contentsOf: url)
//            self.player!.delegate = self
//            guard let player = player else { return }
////            player.prepareToPlay()
////            player.play()
//            player.volume = 0.1
//
//        } catch let error as NSError {
//            print(error.description)
//        }
//    }
//    
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
////        self.recard = 0 //(self.recard == 0 ? 1:0)
//        self.playSound()
//    }
//    
//    
//    
//    
//    func stop() {
//        player?.pause()
//    }
//    
//    
//}
