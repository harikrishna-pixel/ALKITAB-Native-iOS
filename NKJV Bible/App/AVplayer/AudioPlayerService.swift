//
//  AudioPlayerService.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 21/01/21.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayerService  {
    
    static let sharedInstance = AudioPlayerService()
    var looper: AVPlayerLooper?
    var playerLayer:AVPlayerLayer!
    
    var player: AVPlayer?
    var playerItem:AVPlayerItem? = nil
    var Urlstring:String = ""
    var Name:String = ""
    var Titel:String = ""
    var currentTime:Float = 0.0
    var remainingTime:Float = 0.0
    
    
    func RunPlayer() {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name:      NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
    }
    
    
    // MARK: - Start Streaming
    func startStreaming(url:NSURL,name:String,title:String) {
        
        self.player?.pause()
        let dispatchQueue = DispatchQueue.global()
        dispatchQueue.async(execute: { [self] in
                            do{
                                self.Urlstring = String(format: "%@", url as NSURL)
                                self.playerItem = AVPlayerItem(url: url as URL)
                                player = AVPlayer(playerItem: self.playerItem)
                                
                                let playerLayer = AVPlayerLayer(player: player)
                                playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                                Name = name
                                Titel = title
                                playAudios()
                                setupAudioSession()                                
                            }
                            catch{
                                print("\(error)")
                            }
                    });
    }
    
     
    func playAudios() {  
        player!.play()
        setupNowPlaying()
        setupRemoteCommandCenter()
    }
    
    
    
    // MARK: - Audio session
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .allowAirPlay)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
    }

    
    
   // MARK: - init Player info
    
    func setupNowPlaying() {
        
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = Titel
        nowPlayingInfo[MPMediaItemPropertyArtist] = Name
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.playerItem!.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.playerItem!.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    
    // MARK: - Remote command Media player
    
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            App_Protocol.delegateAVplayerProtocol!.PlayControl()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            App_Protocol.delegateAVplayerProtocol!.PlayControl()
            return .success
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget {event in
            self.seekForward(time: 10)
            self.setupNowPlaying()
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget {event in
            self.seekBackward(time: 10)
            self.setupNowPlaying()
            return .success
        }
    }
    
    
// MARK: - Forward & Backword 10 seconds
    
    
    func seekForward(time:Double) {
       guard let duration  = player?.currentItem?.duration else {
           return
       }
        if currentTime < remainingTime+0.05 {
            
            let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
            let newTime = playerCurrentTime + time
          
           let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
           player!.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
           AudioPlayerService.sharedInstance.setupNowPlaying()
       }
        TimeRemainAndCurrentTime()
   }

   func seekBackward(time:Double) {
       let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
           var newTime = playerCurrentTime - 10
                
           if newTime < 0 {
               newTime = 0
           }
       let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
       player!.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
       AudioPlayerService.sharedInstance.setupNowPlaying()
   }
    
    
    func TimeRemainAndCurrentTime() {
        let Duration_in_Second = Int(AudioPlayerService.sharedInstance.playerItem!.asset.duration.seconds)%60
        let Duration_in_minute:Int = Int(AudioPlayerService.sharedInstance.playerItem!.asset.duration.seconds / 60) % 60
                
        let minutes:Int = Int(AudioPlayerService.sharedInstance.playerItem!.currentTime().seconds / 60) % 60
        let currentTime = Int(AudioPlayerService.sharedInstance.playerItem!.currentTime().seconds)%60
        
        self.currentTime = Float(String(format: "%d.%02i",minutes,currentTime))!
        self.remainingTime = Float(String(format: "%d.%02i",Duration_in_minute,Duration_in_Second))!
    
    }
    
}

