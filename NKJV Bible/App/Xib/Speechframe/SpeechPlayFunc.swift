//
//  SpeechPlayFunc.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 22/10/21.
//

import UIKit
import MediaPlayer

class SpeechPlayFunc: NSObject {

    
     static var Shared = SpeechPlayFunc()
     
    func playAudios() {
         setupAudioSession()
         setupNowPlaying()
         setupRemoteCommandCenter()
     
     }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .allowAirPlay)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
    }
    
    func setupNowPlaying() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = UserDefaults.standard.string(forKey: "BookName")

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    

    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            App_Protocol.delegate!.playAction()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            App_Protocol.delegate!.playAction()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget {event in
            App_Protocol.delegate!.NextString()
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget {event in 
            App_Protocol.delegate!.PreviousString()
            return .success
        }
      }
    
}
