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

@available(iOS 13.4, *)
extension ReaderViewController: AVplayerProtocol {
    
    
    func ViewInit() {
        self.changeStatus()
        self.AVswitch.value = 0
        self.AVTimeRemain.text = "0:0"
        self.AVstartTime.text = "0:0"
        self.AVswitch.maximumValue = 0.0
        self.playStatus = false
        self.currentTime = 1
        self.currentTimeacu = 0
        self.PlayPause(ImageName: "Play")
        self.AVTitleText.text = String(format: "\(self.BookTxt.text!)-%02i", self.Pageindex)
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
        if AudioPlayerService.sharedInstance.player?.timeControlStatus == AVPlayer.TimeControlStatus.playing {
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
        
        // OLD BUGGY CODE - Was not updating time labels properly
        // Only updated when SwitchStatus == "Play", causing labels to show 0:0 initially
        // if SwitchStatus == "Play" {
        //     self.AVstartTime.text = String(format: "%d:%02i",minutes,self.currentTime+1)
        //     AVswitch.value = Float(self.currentTimeacu+1)
        // }
        
        // NEW FIXED CODE - Always update time labels so they show correct times immediately
        // Format: minutes:seconds (e.g., 2:30)
        self.AVstartTime.text = String(format: "%d:%02i",minutes,self.currentTime)
        self.AVTimeRemain.text = String(format: "%d:%02i",Duration_in_minute,Duration_in_Second)
        
        // Only update slider value when not dragging to prevent conflict with user interaction
        if SwitchStatus == "Play" {
            AVswitch.value = Float(self.currentTimeacu)
        }
        // When SwitchStatus == "Moving", slider value is controlled by user drag
        
        if Int(self.AVswitch.value) == Int(self.AVswitch.maximumValue) || Int(self.AVswitch.value) == Int(self.AVswitch.maximumValue) {
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
            self.AVTitleText.text = String(format: "\(self.BookName)-\(self.Pageindex)")
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
                self.AVTitleText.text = String(format: "\(self.BookName)-\(self.Pageindex)")
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
            AudioPlayerService.sharedInstance.seekForward(time: 10)
            self.PLayerInfo()
        }
    }
    
    
    
    @IBAction func AVBackward(_ sender: Any) {
        if AVswitch.value > 0.10 {
            AudioPlayerService.sharedInstance.seekBackward(time: 10)
            self.PLayerInfo()
        }
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
