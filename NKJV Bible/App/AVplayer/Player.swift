//
//  Player.swift
//  Audio B
//
//  Created by Axeraan Technologies on 25/01/21.
//

import UIKit
import Alamofire
import AVFoundation
import MediaPlayer

/// Keeps a forward/back jump on screen until playback has actually reached it.
enum ForwardSeekHold {
    static var pinnedTime: Double?
    static var pinUntil: Date?
    /// True while code is moving the slider. That must not seek the audio.
    static var isApplying = false
}

@available(iOS 13.4, *)
extension ReaderViewController: AVplayerProtocol {
    
    
    func ViewInit() {
        ForwardSeekHold.pinnedTime = nil
        ForwardSeekHold.pinUntil = nil
        self.changeStatus()
        self.AVswitch.value = 0
        self.AVTimeRemain.text = "0:0"
        self.AVstartTime.text = "0:0"
        self.AVswitch.maximumValue = 0.0
        self.playStatus = false
        self.currentTime = 1
        self.currentTimeacu = 0
        self.PlayPause(ImageName: "Play")
        self.AVTitleText.text = String(format: "\(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName)-%02i", self.Pageindex)
        progressConfig()
        App_Protocol.delegateAVplayerProtocol = self
        self.updateNavButtons()
    }
    
    func loadGif() {
        LoaderImg.isHidden = false
        AVPSlidervu.isHidden = true
    }
    
    
    func AVstartTimer() {
        // OLD BUGGY CODE - Timer might not be properly invalidated before creating new one
        // timer = Timer.scheduledTimer(timeInterval: 1.0,
        //                                  target: self,
        //                                  selector: #selector(playerTime),
        //                                  userInfo: nil,
        //                                  repeats: true)
        
        // NEW FIXED CODE - Invalidate existing timer before creating new one
        timer?.invalidate()
        timer = nil
        
        let LocalFile = DownloadedFile.shared.DownloadedArray()
        let file_name = UserDefaults.standard.string(forKey: "Bookurl")!
        
        if self.AVTimeRemain.text == "0:0" && !(LocalFile.contains(file_name)) {
            loadGif()
        }
        
        // Create timer - scheduledTimer automatically adds to current run loop
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(playerTime),
                                         userInfo: nil,
                                         repeats: true)
        // Add to common mode to ensure it works during UI interactions
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    @objc func playerTime() {
        // OLD BUGGY CODE - Was checking playStatus which might not be set immediately
        // if AudioPlayerService.sharedInstance.player?.timeControlStatus == AVPlayer.TimeControlStatus.playing && playStatus {
        //     self.PLayerInfo()
        // }
        
        // NEW FIXED CODE - Just check if player is actually playing
        // Don't wait for playStatus flag as it might not be set immediately on first play
        if AudioPlayerService.sharedInstance.player?.timeControlStatus == AVPlayer.TimeControlStatus.playing
            || (AudioPlayerService.sharedInstance.player?.rate ?? 0) > 0 {
            self.PLayerInfo()
        }
    }
    
    
    func PLayerInfo() {
        // OLD BUGGY CODE - This was preventing timer updates
        // Skip automatic updates while user is dragging the scrubber to avoid snapping back
        // if isUserInteractingWithSlider {
        //     return
        // }
        
        // NEW FIXED CODE - Timer is already on main thread, just check player item exists
        // Use SwitchStatus check instead (handled below in the if statement)
        guard let playerItem = AudioPlayerService.sharedInstance.playerItem else { return }
        
        // OLD BUGGY CODE - Was checking AVTimeRemain.text == "0:0" before showing slider
        // This caused delay in showing slider and time labels
        // if self.AVTimeRemain.text != "0:0" {
        //     LoaderImg.isHidden = true
        //     if self.imageView != nil { self.imageView.removeFromSuperview()}
        //     AVPSlidervu.isHidden = false
        // }
        
        // NEW FIXED CODE - Show slider as soon as player item is available
        if playerItem.asset.duration.seconds > 0 {
            LoaderImg.isHidden = true
            if self.imageView != nil { self.imageView.removeFromSuperview()}
            AVPSlidervu.isHidden = false
        }
        
        self.currentTime = Int(playerItem.currentTime().seconds) % 60
        self.currentTimeacu = playerItem.currentTime().seconds
        let minutes:Int = Int(playerItem.currentTime().seconds / 60) % 60
        self.AVswitch.maximumValue = Float(playerItem.asset.duration.seconds)
        
        let Duration_in_Second = Int(playerItem.asset.duration.seconds) % 60
        let Duration_in_minute:Int = Int(playerItem.asset.duration.seconds / 60) % 60

        // The old forward path called this right away and painted the pre-skip time, which sought the audio back.
        if let pinned = ForwardSeekHold.pinnedTime {
            let now = playerItem.currentTime().seconds
            let expired = (ForwardSeekHold.pinUntil ?? .distantPast) < Date()
            if expired || (now.isFinite && now + 1.5 >= pinned) {
                ForwardSeekHold.pinnedTime = nil
                ForwardSeekHold.pinUntil = nil
            } else {
                self.AVTimeRemain.text = String(format: "%d:%02i", Duration_in_minute, Duration_in_Second)
                if abs(Double(AVswitch.value) - pinned) > 0.4 {
                    showSeekPosition(pinned)
                }
                return
            }
        }
        
        // OLD BUGGY CODE - Was not updating time labels properly
        // Only updated when SwitchStatus == "Play", causing labels to show 0:0 initially
        // if SwitchStatus == "Play" {
        //     self.AVstartTime.text = String(format: "%d:%02i",minutes,self.currentTime+1)
        //     AVswitch.value = Float(self.currentTimeacu+1)
        // }
        
        // NEW FIXED CODE - Always update time labels so they show correct times immediately
        // Format: minutes:seconds (e.g., 2:30)
        // While dragging / seeking the label already shows the target time — don't overwrite it.
        // Hold only while the finger is on the slider; a stale seek flag must not freeze the time.
        let holdPosition = isUserInteractingWithSlider && AVswitch.isTracking
        if !holdPosition {
            self.AVstartTime.text = String(format: "%d:%02i",minutes,self.currentTime)
        }
        self.AVTimeRemain.text = String(format: "%d:%02i",Duration_in_minute,Duration_in_Second)
        
        // Move the thumb with playback. Skip only while the user is dragging.
        if !holdPosition, currentTimeacu.isFinite {
            ForwardSeekHold.isApplying = true
            AVswitch.setValue(Float(self.currentTimeacu), animated: false)
            ForwardSeekHold.isApplying = false
        }
        
        let playedSeconds = playerItem.currentTime().seconds
        let trackSeconds = playerItem.asset.duration.seconds
        if trackSeconds.isFinite, trackSeconds > 1, playedSeconds.isFinite, playedSeconds >= trackSeconds - 0.35 {
            timer?.invalidate()
            ViewInit()
            if UserDefaults.standard.string(forKey: "Shuffle")  == "true" {
                AVplayOn()
            } else if UserDefaults.standard.bool(forKey: "Autoplay") {
                self.AutoNext()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                    if self.Pageindex != self.pagecount {
                        self.AVplayOn()
                    }
                }
            }
        }
    }
    
    

    
    
    // Button function
    
    @IBAction func AVplay(_ sender: Any) {
        self.PlayControl()
       }
    
    func PlayControl() {
        self.Playview.zoomIn()
        if playStatus == false { 
            
            let fileName = String(format: "%@_%@", UserDefaults.standard.string(forKey: "SelectedLanguage")!,UserDefaults.standard.string(forKey: "BookurlForAudio")!.replacingOccurrences(of: "/", with: ":"))
            
                if NetworkManager.sharedInstance.isConnectedToInternet() || DownloadedFile.shared.DownloadedArray().contains(fileName) {
                    self.PlayPause(ImageName: "pausePlayer")
                    AVplayOn()
                } else {
                    self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                }
            } else {
                AVpause()
            }
    }
    
    
    @IBAction func AVRepeat(_ sender: Any) {
        if UserDefaults.standard.string(forKey: "Shuffle") == "true" {
            UserDefaults.standard.set("false", forKey: "Shuffle")
            self.RepeatView.backgroundColor = UIColor.clear
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVRepeat! , colorVu: .white)
        } else {
            UserDefaults.standard.set("true", forKey: "Shuffle")
            self.RepeatView.backgroundColor = .white
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVRepeat! , colorVu: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
        }
    }
    
    
    
//
//    @IBAction func AutoPlayAction(_ sender: Any) {
//        if UserDefaults.standard.bool(forKey: "Autoplay") == false {
//            UserDefaults.standard.setValue(true, forKey: "Autoplay")
//            self.AutoPlayView.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor")
//            ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVAutoPlay! , colorVu: UIColor.white)
//        } else {
//            UserDefaults.standard.setValue(false, forKey: "Autoplay")
//            self.AutoPlayView.backgroundColor = UIColor.clear
//            ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVAutoPlay! , colorVu: self.Themecolor!)
//        }
//    }
//
    
    

    
            
    func changeStatus() {
        
        let fileName = String(format: "%@_%@", UserDefaults.standard.string(forKey: "SelectedLanguage")!,UserDefaults.standard.string(forKey: "BookurlForAudio")!.replacingOccurrences(of: "/", with: ":"))
    }

    
    @IBAction func AVprevious(_ sender: Any) {
        // Disable back when at first chapter
        if self.Pageindex > 1 {
            self.PreviousView.zoomIn()
            self.PreviousPageMove()
        }
    }
    
    
    
    @IBAction func AVNextBtn(_ sender: Any) {
        self.AutoNext()
    }
    

    
    func AutoNext() {
        if self.Pageindex >= 0 {
            self.NextView.zoomIn()
            // only advance if not at last chapter
            if self.Pageindex < self.pagecount {
                self.nextPreviousconfig()
                self.NextPageMove()
                BookURL.sharedInstance.bookURL(BookNo: String(self.Pageindex))
                self.changeStatus()
                self.StopAv()
                self.updateNavButtons()
            } else {
                self.view.makeToast("Book finished. Choose the next book to play.", duration: 2.0, position: .bottom)
                self.updateNavButtons()
            }
        }
    }
    
    
    
    func NextPageMove() {
        
        print("self.pagecount :",self.pagecount)

        if self.Pageindex >= 0 && self.pagecount > self.Pageindex {
            self.playStatus = false
            self.Pageindex = self.Pageindex+1
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "BookChapter")+1, forKey: "BookChapter")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                App_Protocol.delegateReaderSource?.ReloadFont(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
                App_Protocol.delegateReader?.mainContainer()
            }
            self.AVTitleText.text = String(format: "\(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName)-\(self.Pageindex)")
        } else {
            // at last chapter
            self.view.makeToast("Book finished. Choose the next book to play.", duration: 2.0, position: .bottom)
        }
        self.updateNavButtons()
    }
    
    
    
    func PreviousPageMove() {
            if self.Pageindex > 1 && self.pagecount >= self.Pageindex {
                self.playStatus = false
                self.Pageindex = self.Pageindex-1
                self.AVTitleText.text = String(format: "\(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName)-\(self.Pageindex)")
                BookURL.sharedInstance.bookURL(BookNo: String(self.Pageindex))
                UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "BookChapter")-1, forKey: "BookChapter")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    App_Protocol.delegateReaderSource?.ReloadFont(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
                    App_Protocol.delegateReader?.mainContainer()
                }
                self.changeStatus()
                self.StopAv()
            }
        self.updateNavButtons()
    }
    
    
    
    
    

    func nextPreviousconfig() {
        self.progressView.isHidden = true
        self.UrlFilter = UserDefaults.standard.string(forKey: "Bookurl")! // ?? "01001")!
    }
    
     

    @IBAction func AVForward(_ sender: Any) {
        
        let remain:Float = Float(self.AVTimeRemain.text!.replacingOccurrences(of: ":", with: "."))!
        let startTime:Float = Float(self.AVstartTime.text!.replacingOccurrences(of: ":", with: "."))!
            
        if startTime+0.11 < remain {
            let now = AudioPlayerService.sharedInstance.player?.currentTime().seconds ?? 0
            AudioPlayerService.sharedInstance.seekForward(time: 10)
            if now.isFinite {
                ForwardSeekHold.pinnedTime = now + 10
                ForwardSeekHold.pinUntil = Date().addingTimeInterval(2.5)
                showSeekPosition(now + 10)
            }
        }
    }
    
    
    
    @IBAction func AVBackward(_ sender: Any) {
        if AVswitch.value > 0.10 {
            let now = AudioPlayerService.sharedInstance.player?.currentTime().seconds ?? 0
            AudioPlayerService.sharedInstance.seekBackward(time: 10)
            if now.isFinite {
                ForwardSeekHold.pinnedTime = max(0, now - 10)
                ForwardSeekHold.pinUntil = Date().addingTimeInterval(2.5)
                showSeekPosition(max(0, now - 10))
            }
        }
    }

    /// Shows the target position immediately (also while paused) and blocks the 1s timer
    /// from redrawing the old time until the player has actually reached it.
    func seekAudio(to seconds: Double) {
        guard seconds.isFinite, AudioPlayerService.sharedInstance.player != nil else { return }
        isUserInteractingWithSlider = true
        showSeekPosition(seconds)
        AudioPlayerService.sharedInstance.seek(toSeconds: seconds) { [weak self] in
            guard let self = self else { return }
            self.isUserInteractingWithSlider = false
            AudioPlayerService.sharedInstance.TimeRemainAndCurrentTime()
            if let now = AudioPlayerService.sharedInstance.playerItem?.currentTime().seconds, now.isFinite {
                self.showSeekPosition(now)
            }
        }
    }

    func showSeekPosition(_ seconds: Double) {
        guard seconds.isFinite else { return }
        let duration = AudioPlayerService.sharedInstance.playerItem?.asset.duration.seconds ?? 0
        let clamped = max(0, duration.isFinite && duration > 0 ? min(seconds, duration) : seconds)
        self.currentTimeacu = clamped
        self.currentTime = Int(clamped) % 60
        self.AVstartTime.text = String(format: "%d:%02i", Int(clamped / 60) % 60, Int(clamped) % 60)
        ForwardSeekHold.isApplying = true
        self.AVswitch.setValue(Float(clamped), animated: false)
        ForwardSeekHold.isApplying = false
    }
 
    
    @IBAction func AVstop(_ sender: Any) {
        self.StopView.zoomIn()
        if self.DownloadesArray.count <= 0 {
            self.StopAv()
        }
    }
    
    
    func StopAv() {
        LoaderImg.isHidden = true
        AVPSlidervu.isHidden = false
        ViewInit()
        playStatus = false
        AudioPlayerService.sharedInstance.player?.seek(to: .zero)
        AudioPlayerService.sharedInstance.player?.pause()
    }

    // Disable/enable navigation buttons at bounds
    func updateNavButtons() {
        let atFirst = self.Pageindex <= 1
        let atLast = self.Pageindex >= self.pagecount
        
        self.PreviousView.isUserInteractionEnabled = !atFirst
        self.PreviousView.alpha = atFirst ? 0.5 : 1.0
        
        self.NextView.isUserInteractionEnabled = !atLast
        self.NextView.alpha = atLast ? 0.5 : 1.0
    }
    
    
    @IBAction func Download(_ sender: Any) {
        self.Download_Mp3()
    }
    
    
    
    func Download_Mp3() {
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            
                let playeritem = UserDefaults.standard.string(forKey: "BookurlForAudio")!

                let fileName = String(format: "%@_%@.mp3", UserDefaults.standard.string(forKey: "SelectedLanguage")!,playeritem.replacingOccurrences(of: "/", with: ":"))
                
                self.DownloadesArray.append(fileName)
                
               if self.DownloadesArray.count <= 1 {
                   for items in DownloadesArray {
                       DispatchQueue.main.async {
                        self.Downloadfilename = self.AVTitleText.text!
                       self.progressView.isHidden = false
                         let fileUrl = String(format: "%@%@.mp3",API_MAIN, playeritem)
    //                       App_Protocol.delegateReader?.CallInterstitialAd()
                           let semaphore = DispatchSemaphore(value: 1)
                       let destination: DownloadRequest.Destination = { _, _ in
                           let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                   let fileURL = documentsURL.appendingPathComponent(fileName)
                                   return (fileURL, [.removePreviousFile])
                           }
                           
                     AF.download( fileUrl, method: .get, to: destination)
                                       .downloadProgress{ Alamoprogress in
                                      DispatchQueue.main.async {
                                           self.progressView.value  = CGFloat(Alamoprogress.fractionCompleted * 100)
                                          }
                                           
                                           DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3.0) {
                                               if self.progressView.value <= 30 && self.progressView.value > 0 {
                                                   self.view.makeToast("Poor Network Connection", duration: 2.0, position: .bottom)
                                                   AF.cancelAllRequests()
                                                   self.playStatus = false
                                                   self.LoaderImg.isHidden = true
                                                   self.PlayPause(ImageName: "Play")
                                               }
                                           }
                                       }
                                       .response { response in
                                           semaphore.signal()
//                                        if self.AVTitleText.text == self.Downloadfilename {
//                                            self.CloudImage.image = UIImage(named: "tick")
//                                        }
                                           
                                           self.progressView.isHidden = true
                                           self.progressView.value = 0.0
                                           DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                                               if String(format: "010%02i",self.Pageindex) == items {
                                                   self.DownloadesArray = self.DownloadesArray.filter { !DownloadedFile.shared.DownloadedArray().contains($0) }
                                               }
                                            if self.playStatus == true {
                                                self.view.makeToast("\(self.Downloadfilename) Audio Downloaded", duration: 2.0, position: .bottom)
                                                self.AVplayOn()
                                            } else {
                                                
                                            }
                                            self.Downloadfilename = ""
                                            self.DownloadesArray.removeAll()
                               }
                           }
                       }
                   }
              } else {
                  self.view.makeToast("Downloading is in progress", duration: 2.0, position: .bottom)
              }
         } else {
          self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    
    
    func alertfunc(Msgstr:String) {
        
        let alert = UIAlertController(title: nil, message: Msgstr, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    
    func alertfuncc(Msgstr:String) {
        let alert = UIAlertController(title: nil, message: Msgstr, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    

    
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    
    // Play pause function
    @objc func AVplayOn() {
        playStatus = true
        if self.currentTimeacu <= 1 || AudioPlayerService.sharedInstance.player?.allowsExternalPlayback == false {
            self.PlayPause(ImageName: "pausePlayer")
            self.LocalOROnline()
        } else {
            if NetworkManager.sharedInstance.isConnectedToInternet() && self.DownloadesArray.count == 0 {
                 AudioPlayerService.sharedInstance.player!.play()
                 self.LoaderImg.isHidden = false
                self.PlayPause(ImageName: "pausePlayer")
            } else {
                self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
            }
        }
        // OLD BUGGY CODE - Timer was called here, but LocalOROnline() also starts a timer
        // This could cause issues with timer not starting properly
        // AVstartTimer()
        
        // NEW FIXED CODE - Always ensure timer is running when play is called
        // Invalidate any existing timer first, then start fresh
        timer?.invalidate()
        AVstartTimer()
    }
    
    func AVpause() {
        if AudioPlayerService.sharedInstance.player?.timeControlStatus ==  AVPlayer.TimeControlStatus.playing {
            AudioPlayerService.sharedInstance.player!.pause()
            self.PlayPause(ImageName: "Play")
            playStatus = false
        }   
    }
    
    func LocalOROnline() {
        let LocalFile = DownloadedFile.shared.DownloadedArray()
        let file_name = String(format: "%@_%@", UserDefaults.standard.string(forKey: "SelectedLanguage")!,UserDefaults.standard.string(forKey: "BookurlForAudio")!.replacingOccurrences(of: "/", with: ":"))
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(file_name).mp3")
        
        if (LocalFile.contains(file_name)) {
            let audioURL = NSURL(fileURLWithPath: audioFilename)
            AudioPlayerService.sharedInstance.startStreaming(url: audioURL as NSURL,name: self.BookTxt.text!, title: String(format: "%d", self.Pageindex))
            self.PlayPause(ImageName: "pausePlayer")
            
            // OLD BUGGY CODE - Was using fixed delay which could be too short or too long
            // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) { [weak self] in
            //     guard let self = self else { return }
            //     self.PLayerInfo()
            // }
            
            // NEW FIXED CODE - No delay needed, timer will update when player is ready
            // Remove the delay entirely, let the timer handle updates
        } else {
            if self.DownloadesArray.count == 0 {
                Download_Mp3()
                self.PlayPause(ImageName: "pausePlayer")
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                    self.LoaderImg.isHidden = true
                    self.AVPSlidervu.isHidden = false
                    self.PlayPause(ImageName: "Play")
                }
            }
        }
    }
    
    
    
    func PlayPause(ImageName:String) {
        self.AVplayIcon.image = UIImage(named: ImageName)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVplayIcon! , colorVu: .white)
    }
    
    func progressConfig() {
        progressView.animationStyle = CAMediaTimingFunctionName.linear.rawValue
        progressView.font = UIFont.systemFont(ofSize: 10)
        progressView.delegate = self
        progressView.isUserInteractionEnabled  = true
        progressView.innerCircleWidth = 3
        progressView.innerCircleColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    }
    
    
    //MARK:- ProgressViewDelegate method -
    func finishedProgress(forCircle circle: ProgressView) {
        if circle == progressView{
        }
    }
    
    func startTheProgress() {
        self.progressView.animationStyle = CAMediaTimingFunctionName.linear.rawValue
    }
    
  
}
