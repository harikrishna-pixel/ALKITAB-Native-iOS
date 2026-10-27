//
//  AudioPlayerService.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 21/01/21.
//

import UIKit
import AVFoundation
import MediaPlayer

/// Pauses chapter audio and speech while an ad is on screen, then continues from the same position.
enum PlaybackAdHold {
    static var resumeChapter = false
    private static var heldSeconds: Double?
    private static var resumeToken = 0
    private static var watchingInterruptions = false

    static func pause() {
        watchInterruptions()
        let service = AudioPlayerService.sharedInstance
        let playing = service.chapterWantsPlayback || (service.player?.rate ?? 0) > 0
        if playing {
            if let seconds = service.player?.currentTime().seconds, seconds.isFinite, seconds > 0.5 {
                heldSeconds = seconds
            }
            service.player?.pause()
            resumeChapter = true
        }
        SpeechVu.active?.pauseForAd()
    }

    static func resume() {
        if resumeChapter {
            continueChapter()
        }
        SpeechVu.active?.resumeAfterAd()
    }

    /// Starts chapter audio again from the held position. Used after an ad, and when the pause button is tapped while playback is already stuck.
    static func continueChapter() {
        let service = AudioPlayerService.sharedInstance
        guard service.chapterWantsPlayback, let player = service.player else { return }
        resumeToken += 1
        let token = resumeToken
        service.setupAudioSession()
        player.play()
        let seconds = heldSeconds ?? player.currentTime().seconds
        let now = player.currentTime().seconds
        if seconds.isFinite, seconds > 1, (!now.isFinite || abs(now - seconds) > 1.5) {
            service.seek(toSeconds: seconds) {
                guard token == resumeToken, service.chapterWantsPlayback else { return }
                service.setupAudioSession()
                service.player?.play()
            }
        }
        retryIfStillStopped(token: token, attempt: 0)
    }

    static func cancelResume() {
        resumeChapter = false
        resumeToken += 1
        heldSeconds = nil
    }

    private static func retryIfStillStopped(token: Int, attempt: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            guard token == resumeToken else { return }
            let service = AudioPlayerService.sharedInstance
            guard service.chapterWantsPlayback, let player = service.player else {
                resumeChapter = false
                return
            }
            let playing = player.rate > 0 || player.timeControlStatus == .playing
            if playing {
                resumeChapter = false
                return
            }
            guard attempt < 4 else { return }
            if player.timeControlStatus != .waitingToPlayAtSpecifiedRate {
                service.setupAudioSession()
                player.play()
            }
            retryIfStillStopped(token: token, attempt: attempt + 1)
        }
    }

    private static func watchInterruptions() {
        guard !watchingInterruptions else { return }
        watchingInterruptions = true
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { note in
            guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
            if type == .began {
                pause()
            } else if type == .ended {
                resume()
            }
        }
    }
}

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
    /// Called on the main queue when the current chapter audio reaches the end.
    var onPlaybackEnded: (() -> Void)?
    /// True while the user expects this chapter to keep playing. An ad pause does not clear it.
    var chapterWantsPlayback = false
    private var playbackEndObserver: NSObjectProtocol?
    
    
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
                                self.observePlaybackEnd(of: self.playerItem)
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
        SpeechVu.active?.stopForChapterAudio()
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

    private func observePlaybackEnd(of item: AVPlayerItem?) {
        if let playbackEndObserver {
            NotificationCenter.default.removeObserver(playbackEndObserver)
            self.playbackEndObserver = nil
        }
        guard let item else { return }
        playbackEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] note in
            guard let self = self, note.object as? AVPlayerItem === self.playerItem else { return }
            self.onPlaybackEnded?()
        }
    }

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
        let wasPlaying = player.rate > 0 || player.timeControlStatus == .playing
        // Pausing first, or seeking with a tight tolerance, sends these chapter files back to the start.
        player.currentItem?.cancelPendingSeeks()
        setupNowPlaying(elapsed: target)
        let time = CMTime(seconds: target, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { [weak self] finished in
            DispatchQueue.main.async {
                guard let self = self, generation == self.seekGeneration else { return }
                if wasPlaying {
                    player.play()
                }
                let landed = player.currentTime().seconds
                let shown = (finished && landed.isFinite && abs(landed - target) < 8) ? landed : target
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

