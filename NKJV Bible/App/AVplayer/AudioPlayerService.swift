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
    
    private var seekGeneration = 0

    func setupNowPlaying(elapsed: Double? = nil) {
        guard let item = playerItem else { return }
        let position = elapsed ?? item.currentTime().seconds
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = Titel
        nowPlayingInfo[MPMediaItemPropertyArtist] = Name
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position.isFinite ? position : 0
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
        let rate = player?.rate ?? 0
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = rate > 0 ? .playing : .paused
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
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget {event in
            self.seekBackward(time: 10)
            return .success
        }
    }
    
    
// MARK: - Forward & Backword 10 seconds
    
    
    func seekForward(time: Double) {
        guard let player = player else { return }
        let now = CMTimeGetSeconds(player.currentTime())
        guard now.isFinite else { return }
        seek(toSeconds: now + time) {}
    }

    func seekBackward(time: Double) {
        guard let player = player else { return }
        let now = CMTimeGetSeconds(player.currentTime())
        guard now.isFinite else { return }
        seek(toSeconds: max(0, now - time)) {}
    }

    /// Seek to `seconds`. Completion runs on the main queue once this seek is the latest one.
    func seek(toSeconds seconds: Double, completion: @escaping () -> Void) {
        guard let player = player else {
            DispatchQueue.main.async { completion() }
            return
        }
        let duration = player.currentItem?.duration.seconds ?? playerItem?.asset.duration.seconds ?? 0
        var target = max(0, seconds)
        if duration.isFinite, duration > 1 {
            target = min(target, duration - 0.05)
        }
        seekGeneration += 1
        let generation = seekGeneration
        let wasPlaying = player.rate > 0
        // A zero-tolerance seek on these files returns to the start. Use the normal seek,
        // and publish the new time first so the old clock cannot pull playback backward.
        player.pause()
        setupNowPlaying(elapsed: target)
        let time = CMTime(seconds: target, preferredTimescale: 600)
        let slack = CMTime(seconds: 0.25, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: slack, toleranceAfter: slack) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self, generation == self.seekGeneration else { return }
                let landed = player.currentTime().seconds
                let shown = (landed.isFinite && abs(landed - target) < 3) ? landed : target
                if wasPlaying {
                    player.play()
                }
                self.setupNowPlaying(elapsed: shown)
                completion()
            }
        }
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

