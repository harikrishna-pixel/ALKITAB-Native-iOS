//
//  ReaderViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 08/12/22.
//

import UIKit
import CoreMedia
import StoreKit
import SwiftUI

class ReaderViewController: UIViewController, ReaderDelegate, ProgressViewDelegate, UIGestureRecognizerDelegate {
   
    
    
    weak var NoteVu: SaveNotes?
    weak var MenuView: VersesMenu?
    weak var WallpaperVU:WallpaperView?
    weak var SubscriptionVu: SubscriptionPopup?
    var PopupMenuView: PopupMenu?
    
    var myView:UIView?
    var VerseView:UIView?
    var MenuFrame:UIView?
    var MenuItems = ["Home", "Daily Verse", "My Library", "More"]
    lazy var BibleSavedVerses:Array<String> = []
    lazy var BookFilter:Array<String> = []
    var Themecolor:UIColor?
    
    
    
    @IBOutlet weak var OfferScreen: UIView!
    @IBOutlet weak var BacKGroundImg: UIImageView!
    @IBOutlet weak var OfferMsgTxt: UILabel!
    @IBOutlet weak var OfferMsgTitleTxt: UILabel!
    @IBOutlet weak var ActivateBtn: UIButton!
    
    
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var TabVu: UIView!
    
    @IBOutlet weak var ContainerView: UIView!
    
//    @IBOutlet weak var PlayerView: UIView!
//    @IBOutlet weak var PlayerImage:UIImageView!
    
    @IBOutlet weak var HomeBtnView: UIView!
    @IBOutlet weak var DailyVerseBtnView: UIView!
    @IBOutlet weak var LibraryBtnView: UIView!
//    @IBOutlet weak var MoreBtnView: UIView!
    
    
    @IBOutlet weak var HomeImg:UIImageView!
    @IBOutlet weak var DailyVerseImg:UIImageView!
    @IBOutlet weak var LibraryImg:UIImageView!
    @IBOutlet weak var MoreImg:UIImageView!
    @IBOutlet weak var HomeSubImg:UIImageView!
    
    @IBOutlet weak var NightModeBtn:UIButton!
    @IBOutlet weak var AdInfo:UIButton!
    @IBOutlet weak var DailyVerseSubImg:UIImageView!
    @IBOutlet weak var LibrarySubImg:UIImageView!
//    @IBOutlet weak var MoreSubImg:UIImageView!
    
    @IBOutlet weak var HomeTxt:UILabel!
    @IBOutlet weak var DailyVerseTxt:UILabel!
    @IBOutlet weak var LibraryTxt:UILabel!
//    @IBOutlet weak var MoreTxt:UILabel!
    
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    @IBOutlet weak var BottomMenyConstrain: NSLayoutConstraint!
    @IBOutlet weak var VeresViewBottom: NSLayoutConstraint!
        
    @IBOutlet weak var Navigateframe: UIView!
    @IBOutlet weak var SwipeDisable: UIView!
        
    @IBOutlet weak var ChapterTxt:UILabel!
    @IBOutlet weak var BookTxt:UILabel!

    private var prayerWallTabInstalled = false
    private weak var prayerWallTabIcon: UIImageView?
    private weak var prayerTabContainer: UIView?
    private weak var quizTabContainer: UIView?
    private weak var moreTabContainer: UIView?
    private weak var quizTabIcon: UIImageView?
    private weak var moreTabIcon: UIImageView?
    private weak var prayerTabPill: UIView?
    private weak var quizTabPill: UIView?
    private weak var moreTabPill: UIView?
    private var prayerTabWidthConstraint: NSLayoutConstraint?
    private var quizTabWidthConstraint: NSLayoutConstraint?
    private var moreTabWidthConstraint: NSLayoutConstraint?
    private var bottomTabHighlightsReady = false

    private enum BottomTabHighlight {
        case home, read, library, prayer, quiz, more
    }

    
    
    
    var ChapterVc: ChapterView?
    var VerseListVc: VerseListView?
    
    weak var SpeechView :SpeechVu?
    weak var SlideCard :SlideCardView?
    
    
//    @IBOutlet weak var PlayerButton: UIButton!
    
    
    @IBOutlet weak var AVMainView: UIView!
    @IBOutlet weak var AVPSlidervu: UIView!
    @IBOutlet weak var AVstartTime: UILabel!
    @IBOutlet weak var AVTimeRemain: UILabel!
    @IBOutlet weak var AVTitleText: UILabel!
    @IBOutlet weak var AVswitch: UISlider!
    
    
    @IBOutlet var progressView: ProgressView!
    weak var timer: Timer?
    @IBOutlet var LoaderImg: UIView!
    @IBOutlet weak var PLayerConstrain: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var SpeakConstrain: NSLayoutConstraint!
    @IBOutlet weak var AudioConstrain: NSLayoutConstraint!
    @IBOutlet weak var MenuConstrain: NSLayoutConstraint!
    
    
    @IBOutlet weak var SpeakVu: UIView!
    @IBOutlet weak var AudioVu: UIView!
    @IBOutlet weak var MenuVu: UIView!
    
    @IBOutlet weak var SpeakImg: UIImageView!
    @IBOutlet weak var AudioImg: UIImageView!
    @IBOutlet weak var MenuImg: UIImageView!
    
    
    
    
    @IBOutlet weak var RepeatView: UIView!
    @IBOutlet weak var PreviousView: UIView!
    @IBOutlet weak var Playview: UIView!
    @IBOutlet weak var NextView: UIView!
    @IBOutlet weak var StopView: UIView!
    
    
    
    @IBOutlet weak var AVplayIcon: UIImageView!
    @IBOutlet var AVRepeat: UIImageView!
    @IBOutlet var AVPrevious: UIImageView!
    @IBOutlet var AVNext: UIImageView!
    @IBOutlet var AVStop: UIImageView!
    
    
    @IBOutlet weak var topBannerConstant: NSLayoutConstraint!
    
    
    var imageView:UIImageView!
    lazy var DownloadesArray:Array<String> = []
    var currentTime:Int = 0
    lazy var currentTimeacu: Double = 0.0
    lazy var SwitchStatus:String = "Play"
    lazy var playStatus:Bool = false
    var isUserInteractingWithSlider:Bool = false
    var Pageindex:Int = 0
    var BookName:String = ""
    var pagecount:Int = 0
    lazy var UrlFilter:String = ""
    lazy var SelectedTab:String = "0"
    lazy var Downloadfilename:String = "Mp3"
    var AdShow:Bool = false
    
    lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        App_Protocol.delegateReader = self
        
        
        self.SelectedTab = "0"
        Navigateframe.isHidden = true
        HomePageCall(Status: false)
        self.CallHomeView()
         
        
        
//        self.PlayerSubViewHeight.constant = (isIpad ? 44:36)
//        self.playerSubMenuFrame.layer.cornerRadius = (isIpad ? 22:18)
//        self.playerSubMenuFrame.layer.masksToBounds = true
        
//        PlayerView.ViewShadow((isIpad ? 30:25), color: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
        
        // OLD BUGGY CODE - Slider setup
        // AVswitch.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        // NEW FIXED CODE - Slider setup (ReaderViewController.swift - line 192-194)
        // Add multiple touch events for better compatibility with iPad and SE devices
        AVswitch.isContinuous = true
        AVswitch.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: [.valueChanged, .touchDragInside, .touchDragOutside, .touchUpInside, .touchUpOutside])
        
        self.PageConfig()
        self.BannerConstrain.constant = FrameConstrains // (StatusbarHeight > 30 ? 90:70)
        self.BottomMenyConstrain.constant = StatusbarHeight
        
        
        self.SpeakVu.ViewShadow(20, color: .gray)
        self.AudioVu.ViewShadow(20, color: .gray)
        self.MenuVu.ViewShadow(20, color: .gray)
        
        
        
        self.OfferScreen.isHidden = true
        self.OfferMsgTitleTxt.text = "\(sub_identifier_lifetime_value)% Off"
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.BacKGroundImg!, colorVu: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
        self.OfferMsgTxt.text = "You are a valuable user! \nWe offer you a special offer on premium purchase for a life-time access. \nEnjoy!"
        self.ActivateBtn.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        
    
        
        if AUDIO_ENABLE == "0" && SPEECH_ENABLE == "0" {
            self.SpeakVu.isHidden = true
            self.AudioVu.isHidden = true
            self.MenuVu.isHidden = true
        } else {
            self.SpeakVu.isHidden = false
            self.AudioVu.isHidden = false
            self.MenuVu.isHidden = false
        }
        
        
        self.mainContainer()
        self.installPrayerWallBottomTabIfNeeded()
        self.installBottomTabHighlightsIfNeeded()
        self.selectBottomTabHighlight(.home)
         
        if IS_SUBSCRIPTION_ENABLE == 0 {
            self.AdInfo.isHidden = true
        }
        
                
        if IS_SUBSCRIPTION_ENABLE == 1  && (NetworkManager.sharedInstance.isConnectedToInternet() || UserDefaults.standard.string(forKey: "PriceTag3") ?? "" != "") {
            if PaymentHistory.sharedInstance.paymentInfo() {
                var Paydate = UserDefaults.standard.string(forKey: "PayCallDate") ?? ""
                
                if Paydate == "" {
                    Paydate = Date().string(format: "dd-MM-yyyy")
                }
                
                let showDate1 = GetReceptKey.shared.convertData(date: Paydate)
                let diff = showDate1.interval(ofComponent: .day, fromDate: Date())
                
                if diff < 0 && UserDefaults.standard.string(forKey: "AppOpenFirst")  ?? "" == "1" {
                    self.CallPaymentPopup()
                }
            }
        }
    }
    
            
    

    
    
    
    func IndsAdLoad(Show: Bool) {
        self.AdShow = Show
    }
     
    
    override func viewWillAppear(_ animated: Bool) {
        self.paymentStatus()
        // Pushed screens (Prayer Wall, etc.) hide the bottom bar; restore when Reader is visible again.
        if navigationController?.topViewController === self {
            hideBottomMenu(Status: false)
            reapplyBottomTabHighlightForSelectedTab()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

        
        if PaymentHistory.sharedInstance.paymentInfo() && self.AdShow {
            self.AdShow.toggle()
        }
        
        
        if UserDefaults.standard.string(forKey: "AppOpenFirst") ?? "0" == "1" {
            if PaymentHistory.sharedInstance.paymentInfo() && OpenAdLoaded {                
                OpenAdLoaded = false
            }
        }
        

        if AUDIO_ENABLE == "0" && SPEECH_ENABLE == "0" {
            //            PlayerView.isHidden = true
            self.SpeakVu.isHidden = true
            self.AudioVu.isHidden = true
            self.MenuVu.isHidden = true
        }
        
        if  self.Themecolor!.toHexString() == BGNightMode.toHexString() {
            self.NightModeBtn.setImage(UIImage(named: "night-mode-on"), for: .normal)
        } else {
            self.NightModeBtn.setImage(UIImage(named: "night-mode-off"), for: .normal)
        }
        
        self.VeresViewBottom.constant = -72
        
        // IAP is now shown after onboarding, not here in Reader
        // Removed automatic IAP presentation code
        
        if UserDefaults.standard.string(forKey: "Rate5") ?? "" == "RateNotShared" {
            
            let rateus = rateus1.fromNib(named: "rateus1")
            rateus.frame = self.view.bounds
            rateus.SourceVu = self
            rateus.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(rateus)

        } else if UserDefaults.standard.string(forKey: "RateAction") ?? "" != "" {

            let showDate1 = GetReceptKey.shared.convertData(date: UserDefaults.standard.string(forKey: "RateAction")!)

            if !showDate1.isGreaterThan(Date()) {
                let rateus = rateus2.fromNib(named: "rateus2")
                rateus.frame = self.view.bounds
                rateus.SourceVu = self
                rateus.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.view.addSubview(rateus)
            }
        }
    }
    
    
    func NavigateToQuiz() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.0) {
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func openRatePopup() {
        let rateus = rateus3.fromNib(named: "rateus3")
        rateus.frame = self.view.bounds
        rateus.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(rateus)
    }
    
    func paymentStatus() {
        
        DispatchQueue.main.async {
            if PaymentHistory.sharedInstance.paymentInfo() {
                self.AdInfo.setImage(UIImage(named: "ad-free"), for: .normal)
            } else {
                if PaymentHistory.sharedInstance.paymentInfoVerify() {
                    self.AdInfo.setImage(UIImage(named: "ad-free"), for: .normal)
                } else {
                    self.AdInfo.setImage(UIImage(named: "AdInfo"), for: .normal)
                }
            }
        }
    }
    
    
    func CallRate(RateContent: String) {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "RateUsViewController") as! RateUsViewController
        vc.RateContent = RateContent
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    func CallRate() {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "RateUsViewController") as! RateUsViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    func ImageEditor(Verse:String,Book:String,Image:UIImage) {
        
        FileManager.default.clearTmpDirectory()
        let vc = kStoryboardImageIphone.instantiateViewController(withIdentifier: "IMageEditingPageVc") as! IMageEditingPageVc
        vc.verseTxt = Verse
        vc.titceTxt = Book
        vc.GetImage = Image
        self.navigationController?.pushViewController(vc, animated: true)
    }    
    
    
    func CallPaymentPopup() {
        
//        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "NewPaymentViewController") as! NewPaymentViewController
//        vc.modalPresentationStyle = .overCurrentContext
//        vc.modalTransitionStyle = .crossDissolve
//        self.present(vc, animated: true, completion: nil)
    }
    
    
    func mainContainer() {
        
        if AUDIO_ENABLE == "0" && SPEECH_ENABLE == "0" {
            self.SpeakVu.isHidden = true
            self.AudioVu.isHidden = true
            self.MenuVu.isHidden = true
        }
        
        for view in self.ContainerView.subviews {
            view.removeFromSuperview()
        }
        
        self.topBannerConstant.constant = 0.0
        self.BottomMenyConstrain.constant = StatusbarHeight
        self.VeresViewBottom.constant = -72.0
        
        
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "PageSwipeVc") as! PageSwipeVc
        self.ContainerView.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: self.ContainerView.topAnchor).isActive = true
        vc.view.leftAnchor.constraint(equalTo: self.ContainerView.leftAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: self.ContainerView.bottomAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: self.ContainerView.rightAnchor).isActive = true
        
        UserDefaults.standard.set(BookURL.sharedInstance.bookURL(BookNo: String(self.Pageindex)), forKey: "Bookurl")
        
        let fileName = String(format: "%@_%@", UserDefaults.standard.string(forKey: "SelectedLanguage")!,UserDefaults.standard.string(forKey: "BookurlForAudio")!.replacingOccurrences(of: "/", with: ":"))
        
        self.ViewInit()
        self.StopAv()
        
        
    }
    
    
    
    func hideBottomMenu(Status:Bool)  {
        self.BottomMenyConstrain.constant =  Status ? -70:StatusbarHeight
    }
    
    func PageConfig() {
        
        BookTxt.text = UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
        ChapterTxt.text = "Ch-\(UserDefaults.standard.integer(forKey: "BookChapter"))"
        
        self.Pageindex = UserDefaults.standard.integer(forKey: "BookChapter")
        self.Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        self.view.backgroundColor = (self.Themecolor == BGNightMode ? BGNightMode:UIColor.white)
        BannerVu.backgroundColor = (self.Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        TabVu.backgroundColor = (self.Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        AVMainView.backgroundColor = (self.Themecolor == BGNightMode ? DarkModeColor:Themecolor) // self.Themecolor
        
        self.pagecount = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: UserDefaults.standard.string(forKey: "BookName") ?? "Kejadian")
        
        
        self.HomeTxt.textColor = (self.Themecolor == BGNightMode ? .black:Themecolor)
        self.DailyVerseTxt.textColor = (self.Themecolor == BGNightMode ? .black:Themecolor)
        self.LibraryTxt.textColor = (self.Themecolor == BGNightMode ? .black:Themecolor)
//        self.MoreTxt.textColor = (self.Themecolor == BGNightMode ? .black:Themecolor)
        
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.HomeImg!, colorVu: .white)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.DailyVerseImg!, colorVu: .white)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.LibraryImg!, colorVu: .white)
//        ImageTint.sharedInstance.imageTintcolorMethod(img: self.MoreImg!, colorVu: .white)
        if let prayerIcon = self.prayerWallTabIcon {
            ImageTint.sharedInstance.imageTintcolorMethod(img: prayerIcon, colorVu: .white)
        }
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.HomeSubImg!, colorVu: self.Themecolor!)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.DailyVerseSubImg!, colorVu: self.Themecolor!)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.LibrarySubImg!, colorVu: self.Themecolor!)
//        ImageTint.sharedInstance.imageTintcolorMethod(img: self.MoreSubImg!, colorVu: self.Themecolor!)
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVRepeat!, colorVu: .white)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVPrevious!, colorVu: .white)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVNext!, colorVu: .white)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVStop!, colorVu: .white)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVplayIcon!, colorVu: .white)
        
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.SpeakImg!, colorVu: Themecolor!)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.AudioImg!, colorVu: Themecolor!)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.MenuImg!, colorVu: Themecolor!)
        

        if UserDefaults.standard.string(forKey: "Shuffle") == "true" {
            self.RepeatView.backgroundColor = .white
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVRepeat! , colorVu: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
        } else {
            self.RepeatView.backgroundColor = UIColor.clear
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.AVRepeat! , colorVu: .white)
        }
        
    }
    
    
    
    

    
    
    
    // OLD BUGGY CODE - Slider handler (ReaderViewController.swift - lines 594-652)
    /*
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                // User started touching slider - prevent automatic updates
                isUserInteractingWithSlider = true
                SwitchStatus = "Moving"
                break
            case .moved:
                SwitchStatus = "Moving"
                // Update time label as user drags
                let seconds : Int64 = Int64(AVswitch.value)
                let minutes:Int = Int(seconds / 60) % 60
                let second:Int = Int(seconds) % 60
                self.AVstartTime.text = String(format: "%d:%02i",minutes,second)
                if playStatus == true {
                    AudioPlayerService.sharedInstance.setupNowPlaying()
                }
                break
            case .ended:
                // User finished dragging - seek to new position
                let seconds : Int64 = Int64(AVswitch.value)
                // let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1) // old: low precision, caused snap-back
                let targetTime: CMTime = CMTime(seconds: Double(AVswitch.value),
                                                preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                AudioPlayerService.sharedInstance.player?.seek(to: targetTime,
                                                               toleranceBefore: .zero,
                                                               toleranceAfter: .zero) { [weak self] finished in
                    guard let self = self else { return }
                    if finished {
                        // Seek complete - allow automatic updates again
                        self.SwitchStatus = "Play"
                        self.isUserInteractingWithSlider = false
                        // Update the visible time immediately so UI reflects the scrubbed position
                        let minutes = Int(seconds / 60) % 60
                        let second = Int(seconds) % 60
                        self.AVstartTime.text = String(format: "%d:%02i", minutes, second)
                        if Int(self.AVswitch.value) == Int(self.AVswitch.maximumValue) {
                            self.timer?.invalidate()
                            self.ViewInit()
                        }
                    }
                }
                break
            case .cancelled:
                // User cancelled drag - allow automatic updates again
                isUserInteractingWithSlider = false
                SwitchStatus = "Play"
                break
            default:
                break
            }
        }
    }
    */
    
    // NEW FIXED CODE - Audio progress bar now works properly with real-time seeking
    // Enhanced to work on all devices including iPad and SE
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        // Handle touch events for better compatibility with iPad and SE devices
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                SwitchStatus = "Moving"
                break
            case .moved:
                SwitchStatus = "Moving"
                // Update time label immediately during drag to show real-time position
                let seconds : Int64 = Int64(AVswitch.value)
                let minutes:Int = Int(seconds / 60) % 60
                let second:Int = Int(seconds) % 60
                self.AVstartTime.text = String(format: "%d:%02i",minutes,second)
                // Don't seek during move, only update the display
                // Seeking will happen on .ended
                break
            case .ended, .cancelled:
                // OLD BUGGY CODE - Was setting SwitchStatus only in completion handler
                // This caused timer to not resume until seek completed
                // let seconds : Int64 = Int64(AVswitch.value)
                // let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
                // AudioPlayerService.sharedInstance.player?.seek(to: targetTime) { [weak self] finished in
                //     self.SwitchStatus = "Play"
                // }
                
                // NEW FIXED CODE - Reset status immediately, then seek
                SwitchStatus = "Play"
                
                let seconds : Int64 = Int64(AVswitch.value)
                let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
                
                // Store play status before seeking
                let wasPlaying = playStatus && (AudioPlayerService.sharedInstance.player?.timeControlStatus == .playing)
                
                // Seek to new position
                AudioPlayerService.sharedInstance.player?.seek(to: targetTime) { [weak self] finished in
                    guard let self = self else { return }
                    if finished {
                        // If was playing, ensure it continues playing after seek
                        if wasPlaying {
                            DispatchQueue.main.async {
                                if AudioPlayerService.sharedInstance.player?.timeControlStatus != .playing {
                                    AudioPlayerService.sharedInstance.player?.play()
                                }
                            }
                        }
                    }
                }
                
                if Int(self.AVswitch.value) == Int(self.AVswitch.maximumValue) {
                    timer?.invalidate()
                    ViewInit()
                }
                break
            default:
                // For .valueChanged events without touch phase, still update time
                if playStatus == true {
                    let seconds : Int64 = Int64(AVswitch.value)
                    let minutes:Int = Int(seconds / 60) % 60
                    let second:Int = Int(seconds) % 60
                    self.AVstartTime.text = String(format: "%d:%02i",minutes,second)
                }
                break
            }
        } else {
            // Handle programmatic value changes or events without touch info
            // This ensures the slider works even when allTouches is empty
            // This is important for iPad and SE devices where touch handling can be different
            if playStatus == true {
                let seconds : Int64 = Int64(AVswitch.value)
                let minutes:Int = Int(seconds / 60) % 60
                let second:Int = Int(seconds) % 60
                self.AVstartTime.text = String(format: "%d:%02i",minutes,second)
                
                // Seek to the new position
                let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
                AudioPlayerService.sharedInstance.player?.seek(to: targetTime)
                
                if Int(self.AVswitch.value) == Int(self.AVswitch.maximumValue) {
                    timer?.invalidate()
                    ViewInit()
                }
            }
        }
    }
    
    
    
    
    
    
    
    @IBAction func ChapterSelectionAction(_ sender: Any) {
        
        if self.myView?.superview == nil {
            self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            self.view.addSubview(self.myView!)
            self.ChapterVc = ChapterView.fromNib(named: "ChapterView")
            self.ChapterVc!.SelectedBook = (UserDefaults.standard.string(forKey: "BookChapter") ?? "0")
            self.ChapterVc!.frame = self.myView!.bounds
            self.ChapterVc!.BookName.text = UserDefaults.standard.string(forKey: "BookName")
            self.ChapterVc!.ScreenName = "Home"
            self.ChapterVc!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.myView!.addSubview(self.ChapterVc!)
        }
        
    }
    
    
    
    func VerseSelectionAction(Chapter:Int) {
        
        if self.VerseView?.superview == nil {
            self.VerseView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            self.view.addSubview(self.VerseView!)
            self.VerseListVc = VerseListView.fromNib(named: "VerseListView")
            self.VerseListVc!.SelectedBook = (UserDefaults.standard.string(forKey: "BookChapter") ?? "0")
            self.VerseListVc!.SelectedBookName = UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
            self.VerseListVc!.frame = self.VerseView!.bounds
            self.VerseListVc!.BookName.text = "\(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName) Ch-\(Chapter)"
            self.VerseListVc!.chapter = Chapter
            self.VerseListVc!.ScreenName = "Home"
            self.VerseListVc!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.VerseView!.addSubview(self.VerseListVc!)
        }
        
    }
    
    
    
    
    
    
    
    
    func CallAds() {
        
        if PaymentHistory.sharedInstance.paymentInfo() {
            if  LastClickCount  == 5 {
                LastClickCount = 0
                UserDefaults.standard.set(LastClickCount, forKey: "LastClickCount")
                self.IndestrialAd()
            }
            else {
                LastClickCount = LastClickCount+1
                UserDefaults.standard.set(LastClickCount, forKey: "LastClickCount")
            }
        }
        
    }
    
    
    func CallWallpaperAds() {
        
        if PaymentHistory.sharedInstance.paymentInfo() {
            if  WallpaperAds  == 5 {
                WallpaperAds = 0
                UserDefaults.standard.set(WallpaperAds, forKey: "WallpaperAds")
                self.IndestrialAd()
            }
            else {
                WallpaperAds = WallpaperAds+1
                UserDefaults.standard.set(WallpaperAds, forKey: "WallpaperAds")
            }
        }
        
    }
    
    
    func IndestrialAd() {
        
    }
    
    
    
    
    @IBAction func playerMenuAction(_ sender: Any) {
//        self.PlayerButton.isEnabled = false
        if AUDIO_ENABLE == "1" && SPEECH_ENABLE == "0" {
            self.playerAnimationAction()
        } else if SPEECH_ENABLE == "1" && AUDIO_ENABLE == "0" {
            self.TextToSpeech()
        } else if SPEECH_ENABLE == "1" && AUDIO_ENABLE == "1" {
//            self.playerMenuAnimationAction()
        }
    }
    
    @IBAction func SpeechFrameXibAction(_ sender: Any) {
        self.TextToSpeech()
//        self.playerMenuAnimationAction()
    }
    
    
    func TextToSpeech() {
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        //        self.myView?.backgroundColor = self.Themecolor
        self.view.addSubview(self.myView!)
        let TextInfo = App_Protocol.delegateReaderSource?.GetTSData()
        
        self.SpeechView = SpeechVu.fromNib(named: "SpeechVu")
        self.SpeechView!.frame = self.myView!.bounds
        self.SpeechView!.AudioBibleList = TextInfo!.AudioBibleList
        self.SpeechView!.BookIndex = UserDefaults.standard.integer(forKey: "BookChapter")
        self.SpeechView!.BookName = TextInfo!.BookName
        self.SpeechView!.BookIndexCount = TextInfo!.pagecount
        self.SpeechView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView!.addSubview(self.SpeechView!)
//        self.PlayerButton.isEnabled = true
    }
    
    
    @IBAction func PlayerAction(_ sender: Any) {
        
        self.playerAnimationAction()
//        self.playerMenuAnimationAction()
    }
    
    
    @IBAction func CloseAVPlayerAction(_ sender: Any) {
        self.playerAnimationAction()
    }
    
    
    @IBAction func ActiveOfferScreen(_ sender: Any) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            // Redirect to latest/updated IAP screen - BibleSubscriptionView
            if #available(iOS 15.0, *) {
                var swiftUIView = BibleSubscriptionView(isPresentedFromOnboarding: false)
                swiftUIView.dismissHandler = { [weak self] in
                    // Handle dismiss if needed
                }
                let hostingController = UIHostingController(rootView: swiftUIView)
                hostingController.modalPresentationStyle = .fullScreen
                self.present(hostingController, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SubscrbViewController") as! SubscrbViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
            UserDefaults.standard.setValue(0, forKey: "OfferClick")
            self.OfferScreen.isHidden = true
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    @IBAction func CloseOfferScreen(_ sender: Any) {
        UserDefaults.standard.setValue(0, forKey: "OfferClick")
        self.OfferScreen.isHidden = true
    }
    
    
    
    
    
    @objc func playerAnimationAction() {
        self.StopAv()
        if PLayerConstrain.constant == -200 {
            UIView.animate(withDuration: 0.4, animations: {
                self.PLayerConstrain.constant = 10
                self.SwipeDisable.isHidden = false
                self.view.layoutIfNeeded()
            }, completion: { finished in
//                self.PlayerButton.isEnabled = true
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.PLayerConstrain.constant = -200
                self.SwipeDisable.isHidden = true
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    
    func playerONOFFCheck() {
//        if self.PlayerSuvViewBottom.constant == 25 {
//            self.playerMenuAnimationAction()
//        }
    }
    
    
//    @objc func playerMenuAnimationAction() {
//
//        if self.PlayerSuvViewBottom.constant == -23 {
//            UIView.animate(withDuration: 0.4, animations: {
//                self.PlayerSuvViewBottom.constant = PlayerSuvViewConstrain
//                self.PlayerImage.image = UIImage(named: "close popup")
//                ImageTint.sharedInstance.imageTintcolorMethod(img: self.PlayerImage!, colorVu: self.Themecolor!)
//                self.view.layoutIfNeeded()
//            }, completion: { finished in
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.4) {
//                    UIView.animate(withDuration: 0.4) {
//                        self.playerIcon.isHidden = true
//                        self.PlayerSuvViewWidth.constant = (isIpad ? 340:240) // PlayerSuvVuWidth
//                        self.PlayerButton.isEnabled = true
//                        self.view.layoutIfNeeded()
//                    }
//                }
//            })
//        } else {
//            UIView.animate(withDuration: 0.4, animations: {
//                self.playerIcon.isHidden = false
//                self.PlayerSuvViewWidth.constant = (isIpad ? 44:36)
//                self.view.layoutIfNeeded()
//            }, completion: { finished in
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.4) {
//                    UIView.animate(withDuration: 0.4) {
//                        self.PlayerSuvViewBottom.constant = -23
//                        self.PlayerImage.image = UIImage(named: "headphone")
//                        ImageTint.sharedInstance.imageTintcolorMethod(img: self.PlayerImage!, colorVu: self.Themecolor!)
//                        self.PlayerButton.isEnabled = true
//                        self.view.layoutIfNeeded()
//                    }
//                }
//            })
//        }
//    }
    
    
    
    func ClosePlayerPopup() {
        self.MenuImg.image = UIImage(named: "headphone")
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.MenuImg!, colorVu: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
        UIView.animate(withDuration: 0.4, animations: {
            self.SpeakConstrain.constant = -40
            self.view.layoutIfNeeded()
        }, completion: { finished in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                UIView.animate(withDuration: 0.4) {
                    self.AudioConstrain.constant = -40
                     self.view.layoutIfNeeded()
                }
            }
        })
        
        
//        UIView.animate(withDuration: 0.4, animations: {
//            self.playerIcon.isHidden = false
//            self.PlayerSuvViewWidth.constant = (isIpad ? 44:36)
//            self.view.layoutIfNeeded()
//        }, completion: { finished in
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.4) {
//                UIView.animate(withDuration: 0.4) {
//                    self.PlayerSuvViewBottom.constant = -23
//                    self.PlayerImage.image = UIImage(named: "headphone")
//                    ImageTint.sharedInstance.imageTintcolorMethod(img: self.PlayerImage!, colorVu: self.Themecolor!)
//                    self.PlayerButton.isEnabled = true
//                    self.view.layoutIfNeeded()
//                }
//            }
//        })
    }
    
    
    
        // MARK: - NEW PLAYER
    @IBAction func PlayBtn_Action(_ sender: Any) {
        
        if AUDIO_ENABLE == "1" && SPEECH_ENABLE == "0" {
            self.playerAnimationAction()
        } else if SPEECH_ENABLE == "1" && AUDIO_ENABLE == "0" {
            self.TextToSpeech()
        } else if SPEECH_ENABLE == "1" && AUDIO_ENABLE == "1" {
            self.OpenClosePLayAnimation()
        } else if AUDIO_ENABLE == "" && SPEECH_ENABLE == "" {
            self.view.makeToast("Please try after sometime", duration: 2.0, position: .center)
        }
    }
    
    func OpenClosePLayAnimation() {

        if self.SpeakConstrain.constant == 20 || self.AudioConstrain.constant == 20 {
            self.MenuImg.image = UIImage(named: "headphone")
        } else {
            self.MenuImg.image = UIImage(named: "close popup")
        }
        
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.MenuImg!, colorVu: Themecolor!)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.SpeakConstrain.constant = (self.SpeakConstrain.constant == 20 ? -40:20)
            self.view.layoutIfNeeded()
        }, completion: { finished in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                UIView.animate(withDuration: 0.4) {
                    self.AudioConstrain.constant = (self.AudioConstrain.constant == 20 ? -40:20)
                     self.view.layoutIfNeeded()
                }
            }
        })
        
    }
    
    
    @IBAction func AudioPlayer_Action(_ sender: Any) {
        self.playerAnimationAction()
        self.OpenClosePLayAnimation()
    }
    
    @IBAction func TextPlayer_Action(_ sender: Any) {
        self.TextToSpeech()
        self.OpenClosePLayAnimation()
    }
    
    
    
    
    
    
    @IBAction func SliderCardNibAction(_ sender: Any) {
        
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SlideCardVC") as! SlideCardVC
        let ChapterNo = UserDefaults.standard.integer(forKey: "BookChapter")
        vc.Bookname =  "\(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName)-\(ChapterNo):0"
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func BookSelectionAction(_ sender: Any) {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "BookListViewController") as! BookListViewController
        vc.ChapterNo = UserDefaults.standard.string(forKey: "BookChapter") ?? "0"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func SearchNavigation(_ sender: Any) {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    func Quiz(Go:Bool) {
        
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
            vc.ChapterString = (Go ? UserDefaults.standard.string(forKey: "BookChapter") ?? "0":"")
            vc.BookString = (Go ? UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName:"")
            vc.ChapterCount = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
 
    
        
    func FeedbackNavigate() {
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    
    
    @IBAction func HomeAction(_ sender: Any) {
        
        self.CallHomeView()
    }
    
    func CallHomeView() {
        
            self.playerONOFFCheck()
            self.SelectedTab = "0"
        ClosePlayerPopup()
                self.SpeakVu.isHidden = true
                self.AudioVu.isHidden = true
                self.MenuVu.isHidden = true
        
                self.Buttonfram()
                self.selectBottomTabHighlight(.home)
                self.Navigateframe.isHidden = false
                let vc = DailyJourneyHomeViewController()
                self.showEmbeddedTab(vc)
    }
    
    func HomePageCall(Status:Bool) {
        

        
        
        if Status {
            self.SelectedTab = "1"
            Navigateframe.isHidden = true
            
            self.Buttonfram()
            self.selectBottomTabHighlight(.read)
        }
        
        if AUDIO_ENABLE == "0" && SPEECH_ENABLE == "0" {
//            PlayerView.isHidden = true
            self.SpeakVu.isHidden = true
            self.AudioVu.isHidden = true
            self.MenuVu.isHidden = true
        } else {
//            PlayerView.isHidden = false
            self.SpeakVu.isHidden = false
            self.AudioVu.isHidden = false
            self.MenuVu.isHidden = false
        }
        
        if PaymentHistory.sharedInstance.paymentInfo() {
            DispatchQueue.main.async {
                if UserDefaults.standard.integer(forKey: "OfferClick") > Int(offer_count)! {
                    if IS_SUBSCRIPTION_ENABLE == 1 {
                        self.OfferScreen.isHidden = false
                    }
                }
            }
        }
        
        
        
        
        if UserDefaults.standard.integer(forKey: "RateUSoneTime") >= 1 && !UserDefaults.standard.bool(forKey: "rateViewed") {
            if self.SelectedTab == "1" {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    SKStoreReviewController.requestReviewInCurrentScene()
                    UserDefaults.standard.setValue(true, forKey: "rateViewed")
                }
            }
        }
        
        
    }
    
    @IBAction func DailyVereseAction(_ sender: Any) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            if Date().string(format: "dd-MM-yyyy") == UserDefaults.standard.string(forKey: "RateDate") ?? "" && !UserDefaults.standard.bool(forKey: "RateViewed") && self.SelectedTab == "1" {
                self.CallRate()
                UserDefaults.standard.setValue(true, forKey: "RateViewed")
            }
        }
        
        
        
        App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
        
        if self.SelectedTab != "1" {
            self.SelectedTab = "1"
            Navigateframe.isHidden = true
            self.Buttonfram()
            self.selectBottomTabHighlight(.read)
            
            HomePageCall(Status: false)
        }
    }
    
    
    @IBAction func MylibraryAction(_ sender: Any) {
        if self.SelectedTab != "2" {
            self.playerONOFFCheck()
            self.SelectedTab = "2"
            ClosePlayerPopup()
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+(self.PlayerSuvViewBottom.constant == 25 ? 1:0.0)) {
//                self.PlayerView.isHidden = true
                self.SpeakVu.isHidden = true
                self.AudioVu.isHidden = true
                self.MenuVu.isHidden = true
                self.Buttonfram()
                self.selectBottomTabHighlight(.library)
                self.Navigateframe.isHidden = false
                
                let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "MyLibraryViewController") as! MyLibraryViewController
                self.showEmbeddedTab(vc)
//            }
        }
    }
    
    
    
    func AboutusCall() {
//        DispatchQueue.main.async {
//            self.MoreCall()
//        }
        
//        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func More_Action(_ sender: Any) {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Quiz_Action(_ sender: Any) {
        if self.SelectedTab != "4" {
            self.playerONOFFCheck()
            self.SelectedTab = "4"
            ClosePlayerPopup()
            self.SpeakVu.isHidden = true
            self.AudioVu.isHidden = true
            self.MenuVu.isHidden = true
            self.Buttonfram()
            self.selectBottomTabHighlight(.quiz)
            self.Navigateframe.isHidden = false
            let vc = ChallengeHubViewController()
            vc.isEmbeddedTab = true
            self.showEmbeddedTab(vc)
        }
    }

    @objc func PrayerWall_Action(_ sender: Any) {
        if self.SelectedTab != "3" {
            self.playerONOFFCheck()
            self.SelectedTab = "3"
            ClosePlayerPopup()
            self.SpeakVu.isHidden = true
            self.AudioVu.isHidden = true
            self.MenuVu.isHidden = true
            self.Buttonfram()
            self.selectBottomTabHighlight(.prayer)
            if NetworkManager.sharedInstance.isConnectedToInternet() {
                self.Navigateframe.isHidden = false
                let vc = PrayerWallViewController()
                vc.isEmbeddedTab = true
                self.showEmbeddedTab(vc)
            } else {
                self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
            }
        }
    }

    private func clearNavigateframeTabChildren() {
        for child in children {
            if child is DailyJourneyHomeViewController || child is HomeController || child is MyLibraryViewController || child is PrayerWallViewController || child is ChallengeHubViewController {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
        Navigateframe.subviews.forEach { $0.removeFromSuperview() }
    }

    private func showEmbeddedTab(_ viewController: UIViewController) {
        clearNavigateframeTabChildren()
        addChild(viewController)
        viewController.view.frame = Navigateframe.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        Navigateframe.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        Navigateframe.layer.masksToBounds = true
    }

    private func installPrayerWallBottomTabIfNeeded() {
        guard !prayerWallTabInstalled else { return }
        guard let stack = TabVu.subviews.compactMap({ $0 as? UIStackView }).first else { return }
        prayerWallTabInstalled = true

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        prayerTabContainer = container

        let width = container.widthAnchor.constraint(equalToConstant: 46)
        prayerTabWidthConstraint = width

        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        if #available(iOS 15.0, *) {
            icon.image = UIImage(systemName: "hands.sparkles.fill")
        } else {
            icon.image = UIImage(systemName: "heart.fill")
        }
        icon.tintColor = .white
        prayerWallTabIcon = icon

        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(PrayerWall_Action(_:)), for: .touchUpInside)
        button.accessibilityLabel = "Prayer Wall"

        container.addSubview(icon)
        container.addSubview(button)

        NSLayoutConstraint.activate([
            width,
            container.heightAnchor.constraint(equalToConstant: 34),
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Home, Read, Library, [Prayer], Quiz, More
        let insertIndex = min(3, stack.arrangedSubviews.count)
        stack.insertArrangedSubview(container, at: insertIndex)
    }

    private func installBottomTabHighlightsIfNeeded() {
        guard !bottomTabHighlightsReady else { return }
        guard let stack = TabVu.subviews.compactMap({ $0 as? UIStackView }).first,
              stack.arrangedSubviews.count >= 6 else { return }
        bottomTabHighlightsReady = true

        let prayerContainer = stack.arrangedSubviews[3]
        let quizContainer = stack.arrangedSubviews[4]
        let moreContainer = stack.arrangedSubviews[5]
        prayerTabContainer = prayerContainer
        quizTabContainer = quizContainer
        moreTabContainer = moreContainer

        if quizTabIcon == nil {
            quizTabIcon = quizContainer.subviews.compactMap { $0 as? UIImageView }.first
        }
        if moreTabIcon == nil {
            moreTabIcon = moreContainer.subviews.compactMap { $0 as? UIImageView }.first
        }

        // Capture fixed widths from storyboard so we can restore after pill highlight.
        if quizTabWidthConstraint == nil {
            for c in quizContainer.constraints where c.firstAttribute == .width && c.firstItem as? UIView == quizContainer {
                quizTabWidthConstraint = c
                break
            }
            if quizTabWidthConstraint == nil {
                let width = quizContainer.widthAnchor.constraint(equalToConstant: 46)
                width.isActive = true
                quizTabWidthConstraint = width
            }
        }
        if moreTabWidthConstraint == nil {
            for c in moreContainer.constraints where c.firstAttribute == .width && c.firstItem as? UIView == moreContainer {
                moreTabWidthConstraint = c
                break
            }
            if moreTabWidthConstraint == nil {
                let width = moreContainer.widthAnchor.constraint(equalToConstant: 46)
                width.isActive = true
                moreTabWidthConstraint = width
            }
        }

        let theme = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        if prayerTabPill == nil, let prayerContainer = prayerTabContainer {
            prayerTabPill = makeBottomTabPill(
                title: "Prayer",
                iconImage: prayerWallTabIcon?.image,
                usesTemplate: true,
                theme: theme,
                in: prayerContainer
            )
        }
        if quizTabPill == nil {
            quizTabPill = makeBottomTabPill(
                title: "Quiz",
                iconImage: quizTabIcon?.image,
                usesTemplate: true,
                theme: theme,
                in: quizContainer
            )
        }
        if moreTabPill == nil {
            moreTabPill = makeBottomTabPill(
                title: "More",
                iconImage: moreTabIcon?.image,
                usesTemplate: true,
                theme: theme,
                in: moreContainer
            )
        }
    }

    private func makeBottomTabPill(
        title: String,
        iconImage: UIImage?,
        usesTemplate: Bool,
        theme: UIColor,
        in container: UIView
    ) -> UIView {
        let pill = UIView()
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = .white
        pill.layer.cornerRadius = 17
        pill.isHidden = true
        pill.isUserInteractionEnabled = false

        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        if usesTemplate {
            icon.image = iconImage?.withRenderingMode(.alwaysTemplate)
            icon.tintColor = theme
        } else {
            icon.image = iconImage
            icon.tintColor = theme
        }

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        label.textColor = theme

        pill.addSubview(icon)
        pill.addSubview(label)
        if let button = container.subviews.compactMap({ $0 as? UIButton }).first {
            container.insertSubview(pill, belowSubview: button)
        } else {
            container.addSubview(pill)
        }

        NSLayoutConstraint.activate([
            pill.topAnchor.constraint(equalTo: container.topAnchor),
            pill.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            pill.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            pill.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            icon.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 8),
            icon.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 14),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
        ])
        return pill
    }

    private func selectBottomTabHighlight(_ tab: BottomTabHighlight) {
        installBottomTabHighlightsIfNeeded()

        HomeBtnView.isHidden = true
        DailyVerseBtnView.isHidden = true
        LibraryBtnView.isHidden = true
        prayerTabPill?.isHidden = true
        quizTabPill?.isHidden = true
        moreTabPill?.isHidden = true
        prayerWallTabIcon?.isHidden = false
        quizTabIcon?.isHidden = false
        moreTabIcon?.isHidden = false
        prayerTabWidthConstraint?.constant = 46
        quizTabWidthConstraint?.constant = 46
        moreTabWidthConstraint?.constant = 46

        let theme = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        switch tab {
        case .home:
            HomeBtnView.isHidden = false
        case .read:
            DailyVerseBtnView.isHidden = false
        case .library:
            LibraryBtnView.isHidden = false
        case .prayer:
            prayerWallTabIcon?.isHidden = true
            prayerTabPill?.isHidden = false
            prayerTabWidthConstraint?.constant = 78
            (prayerTabPill?.subviews.compactMap { $0 as? UIImageView }.first)?.tintColor = theme
            (prayerTabPill?.subviews.compactMap { $0 as? UILabel }.first)?.textColor = theme
        case .quiz:
            quizTabIcon?.isHidden = true
            quizTabPill?.isHidden = false
            quizTabWidthConstraint?.constant = 70
            (quizTabPill?.subviews.compactMap { $0 as? UIImageView }.first)?.tintColor = theme
            (quizTabPill?.subviews.compactMap { $0 as? UILabel }.first)?.textColor = theme
        case .more:
            moreTabIcon?.isHidden = true
            moreTabPill?.isHidden = false
            moreTabWidthConstraint?.constant = 72
            (moreTabPill?.subviews.compactMap { $0 as? UIImageView }.first)?.tintColor = theme
            (moreTabPill?.subviews.compactMap { $0 as? UILabel }.first)?.textColor = theme
        }
        TabVu.layoutIfNeeded()
    }

    private func reapplyBottomTabHighlightForSelectedTab() {
        switch SelectedTab {
        case "0": selectBottomTabHighlight(.home)
        case "1": selectBottomTabHighlight(.read)
        case "2": selectBottomTabHighlight(.library)
        case "3": selectBottomTabHighlight(.prayer)
        case "4": selectBottomTabHighlight(.quiz)
        case "5": selectBottomTabHighlight(.more)
        default: break
        }
    }
    
    @IBAction func MoreAction(_ sender: Any) {
        self.SelectedTab = "5"
        self.Buttonfram()
        self.selectBottomTabHighlight(.more)
        
        //        let alert = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)

                let alert: UIAlertController
                
                
                if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
                    alert = UIAlertController(title: "More", message: nil , preferredStyle: .alert)
                } else {
                    alert = UIAlertController(title: "More", message: nil , preferredStyle: .actionSheet)
                }
                
                alert.view.tintColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
                
                
                    let area = UIAlertAction(title: "Recent Arrivals", style: .default, handler: { action in
                        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "BookAdListViewController") as! BookAdListViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                    })
                   
                   let project = UIAlertAction(title: "More Apps", style: .default, handler: { action in
                       if CoreDataModel.sharedInstance.GetAppImageSave(entity: CDMoreAppApi).count > 0 {
                           let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "MoreAppsViewController") as! MoreAppsViewController
                           self.navigationController?.pushViewController(vc, animated: true)
                       } else {
                           
                           if NetworkManager.sharedInstance.isConnectedToInternet() {
                                      if let url = URL(string: moreLink), UIApplication.shared.canOpenURL(url) {
                                          UIApplication.shared.open(url, options: [:]) { success in
                                              print(success ? "URL was opened successfully." : "Failed to open URL.")
                                          }
                                      } else {
                                          self.view.makeToast("Invalid URL or cannot open.", duration: 2.0, position: .bottom)
                                      }
                                      
                                  } else {
                                      self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                                  }
                       }
                    })
                
                
                    let Setting = UIAlertAction(title: "Settings", style: .default, handler: { action in
                        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                
                
                    if PaymentHistory.sharedInstance.paymentInfo() && book_ads_status > 0 && CoreDataModel.sharedInstance.GetMoreBookShare(entity: CDMoreBookApi).count > 0 {
                        let image = UIImage(named: "New")
                        let imageView = UIImageView()
                        imageView.image = image
                        imageView.frame =  CGRect(x: alert.view.frame.width-100, y: 65, width: 24, height: 24)
                        alert.view.addSubview(imageView)
                    
                        let areaImage = UIImage(named: "BookIcon")
                        area.setValue(areaImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)), forKey: "image")
                        
                        
                        alert.addAction(area)
                    }
                
                    let projectImage = UIImage(named: "More icon")
                    project.setValue(projectImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)), forKey: "image")
                    let SettingImage = UIImage(named: "Setting")
                    Setting.setValue(SettingImage?.imageWithSize(scaledToSize: CGSize(width: 32, height: 32)), forKey: "image")
                
                   
                   alert.addAction(project)
                   alert.addAction(Setting)
                
                   alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                   alert.popoverPresentationController?.sourceView = self.view
                   self.present(alert, animated: true, completion: nil)
                
                
            }
    
    
    
    @IBAction func PaymentAction(_ sender: Any) {
        
        if CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI) != "" {
                var date = CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI)

                if date == "" {
                    date = Date().string(format: "dd-MM-yyyy")
                }
                let showDate1 = GetReceptKey.shared.convertData(date: date)

                if showDate1.isGreaterThan(Date()) {
                    self.SubscriptionVucall()
                } else {
                    // BUG FIX 3 (OFFLINE IAP NAVIGATION): OLD CODE - Used OR (||) allowing navigation with cached prices
                    // if NetworkManager.sharedInstance.isConnectedToInternet() || UserDefaults.standard.string(forKey: "PriceTag3") ?? "" != ""
                    // Problem: If prices cached, navigates to IAP even offline, causing errors
                    
                    // BUG FIX 3 (OFFLINE IAP NAVIGATION): NEW CODE - Require internet connection
                    if NetworkManager.sharedInstance.isConnectedToInternet() {
                        if #available(iOS 15.0, *) {
                            // OLD CODE: Presented IAP without specifying it's from within the app
                            // This caused flicker when dismissing as it tried to navigate instead of dismiss
                            // let swiftUIView = BibleSubscriptionView()
                            
                            // NEW CODE: Pass isPresentedFromOnboarding = false to enable smooth dismiss
                            var swiftUIView = BibleSubscriptionView(isPresentedFromOnboarding: false)
                            swiftUIView.dismissHandler = { [weak self] in
                                self?.navigationController?.popViewController(animated: true)
                            }
                            let hostingController = UIHostingController(rootView: swiftUIView)
                            self.navigationController?.pushViewController(hostingController, animated: true)
                        } else {
                            // Fallback on earlier versions
                            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SubscrbViewController") as! SubscrbViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                    }
                }
            } else {
                // BUG FIX 3 (OFFLINE IAP NAVIGATION): OLD CODE - Used OR (||) allowing navigation with cached prices
                // if NetworkManager.sharedInstance.isConnectedToInternet() || UserDefaults.standard.string(forKey: "PriceTag3") ?? "" != ""
                
                // BUG FIX 3 (OFFLINE IAP NAVIGATION): NEW CODE - Require internet connection
                if NetworkManager.sharedInstance.isConnectedToInternet() {
                    if #available(iOS 15.0, *) {
                        // OLD CODE: Presented IAP without specifying it's from within the app
                        // let swiftUIView = BibleSubscriptionView()
                        
                        // NEW CODE: Pass isPresentedFromOnboarding = false to enable smooth dismiss
                        var swiftUIView = BibleSubscriptionView(isPresentedFromOnboarding: false)
                        swiftUIView.dismissHandler = { [weak self] in
                            self?.navigationController?.popViewController(animated: true)
                        }
                        let hostingController = UIHostingController(rootView: swiftUIView)
                        self.navigationController?.pushViewController(hostingController, animated: true)
                    } else {
                        // Fallback on earlier versions
                        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SubscrbViewController") as! SubscrbViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                }
            }
        
        
//        if CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI) != "" {
//            var date = CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI)
//
//
//            if date == "" {
//                date = Date().string(format: "dd-MM-yyyy")
//            }
//            let showDate1 = GetReceptKey.shared.convertData(date: date)
//
//            if showDate1.isGreaterThan(Date()) {
//                self.SubscriptionVucall()
//            } else {
//                if NetworkManager.sharedInstance.isConnectedToInternet() || UserDefaults.standard.string(forKey: "PriceTag3") ?? "" != "" {
//                    let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SubscrbViewController") as! SubscrbViewController
//                    self.navigationController?.pushViewController(vc, animated: true)
//                } else {
//                    self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
//                }
//            }
//        } else {
//            if NetworkManager.sharedInstance.isConnectedToInternet() || UserDefaults.standard.string(forKey: "PriceTag3") ?? "" != "" {
//                let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SubscrbViewController") as! SubscrbViewController
//                self.navigationController?.pushViewController(vc, animated: true)
//            } else {
//                self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
//            }
//        }
    }
    

    
    func Buttonfram() {
        self.HomeBtnView.isHidden = true
        self.DailyVerseBtnView.isHidden = true
        self.LibraryBtnView.isHidden = true
        prayerTabPill?.isHidden = true
        quizTabPill?.isHidden = true
        moreTabPill?.isHidden = true
        prayerWallTabIcon?.isHidden = false
        quizTabIcon?.isHidden = false
        moreTabIcon?.isHidden = false
        prayerTabWidthConstraint?.constant = 46
        quizTabWidthConstraint?.constant = 46
        moreTabWidthConstraint?.constant = 46
//        self.MoreBtnView.isHidden = true
    }
    
       

    func NoteNib(VersePosition: Int, BookName: String, Pageindex:Int, BookVerse:Array<String>, note:String) {
        
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.myView!)
        self.NoteVu = SaveNotes.fromNib(named: "SaveNotes")
        self.NoteVu!.VerseStr = BookVerse[VersePosition-1]
        self.NoteVu!.Note = note
        self.NoteVu!.Bookname = BookName
        self.NoteVu!.ChapterNo = "\(Pageindex-1):\(VersePosition)"
        self.NoteVu!.frame = self.myView!.bounds
        self.NoteVu!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView!.addSubview(self.NoteVu!)
        
    }

    func ExplanationNib(VersePosition: Int, BookName: String, Pageindex: Int, BookVerse: Array<String>) {
        self.CloseMenu()
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.myView!)

        let explanationView = VerseExplanationView(frame: self.myView!.bounds)
        explanationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        explanationView.displayMode = .fetchNew
        explanationView.verseReference = "\(BookName)-\(Pageindex-1):\(VersePosition)"
        explanationView.verseText = BookVerse[VersePosition - 1]
        explanationView.bibleVersion = APPNAME
        explanationView.onDismiss = { [weak self] in
            self?.CloseView()
        }
        self.myView!.addSubview(explanationView)
    }

    func ChapterSummaryNib(BookName: String, Pageindex: Int, BookVerse: Array<String>) {
        self.CloseMenu()
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.myView!)

        let numberedVerses = BookVerse.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        let explanationView = VerseExplanationView(frame: self.myView!.bounds)
        explanationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        explanationView.displayMode = .chapterSummary
        explanationView.verseReference = "\(BookName)-\(Pageindex):1"
        explanationView.screenTitle = "\(BookName) \(Pageindex) Summary"
        explanationView.verseText = numberedVerses
        explanationView.bibleVersion = APPNAME
        explanationView.onDismiss = { [weak self] in
            self?.CloseView()
        }
        self.myView!.addSubview(explanationView)
    }

    func ShowSavedExplanation(dataString: String) {
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.myView!)

        let explanationView = VerseExplanationView(frame: self.myView!.bounds)
        explanationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        explanationView.displayMode = .saved
        explanationView.savedRecordString = dataString
        explanationView.onDismiss = { [weak self] in
            self?.CloseView()
        }
        self.myView!.addSubview(explanationView)
    }

    
    
    func MenuNib(VersePosition: Int, BookName: String, Pageindex:Int, BookVerse:Array<String>, Bookmark:String, ColorCode:String, UnderlineStatus:String, note:String) {
        self.ClosePlayerPopup()
        
        self.MenuFrame = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.MenuFrame!)
        self.MenuView = VersesMenu.fromNib(named: "VersesMenu")
        self.MenuView!.VersePosition = VersePosition
        self.MenuView!.BookName = BookName
        self.MenuView!.BookmarkStatus = Bookmark
        self.MenuView!.ColorCode = ColorCode
        self.MenuView!.Pageindex = Pageindex
        self.MenuView!.BookVerse = BookVerse
        self.MenuView!.Notetxt = note
        self.MenuView!.UnderlineStatus = UnderlineStatus
        self.MenuView!.frame = self.MenuFrame!.bounds
        self.MenuView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.MenuFrame!.addSubview(self.MenuView!)
    }
    

    func CallMenu(getString: String, VCSelection: String, TagSelection:String) {
        
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.myView!)
        self.PopupMenuView = PopupMenu.fromNib(named: "PopupMenu")
        self.PopupMenuView!.getString = getString
        self.PopupMenuView!.VCSelection = VCSelection
        self.PopupMenuView!.TagSelection = TagSelection
        self.PopupMenuView!.frame = self.myView!.bounds
        self.PopupMenuView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView!.addSubview(self.PopupMenuView!)
    }
    

    
    func WallpaperNib(VersePosition: Int, BookName: String, Pageindex:Int, BookVerse:Array<String>) {
        
        self.CloseMenu()
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.myView!)
        self.WallpaperVU = WallpaperView.fromNib(named: "WallpaperView")
        self.WallpaperVU!.VerseStr = BookVerse[VersePosition-1]
        self.WallpaperVU!.Bookname = BookName
        self.WallpaperVU!.BooknameTxt = UserDefaults.standard.string(forKey: "BookName")
        self.WallpaperVU!.VerseArray = BookVerse
        self.WallpaperVU!.SourceView = self
        self.WallpaperVU!.frame = self.myView!.bounds
        self.WallpaperVU!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView!.addSubview(self.WallpaperVU!)
    }
    
    
    func CallInterstitialAd() {
        
        if UserDefaults.standard.string(forKey: "AdTime") == nil {
            let date = Date().addingTimeInterval(5 * 60)
            UserDefaults.standard.setValue(date.string(format: "HH:mm"), forKey: "AdTime")
        } else {
            var adtime = UserDefaults.standard.string(forKey: "AdTime") ?? ""
            if adtime != "" {
                let f = DateFormatter()
                f.dateFormat = "HH:mm"
                
                if  f.date(from: Date().string(format: "HH:mm"))! >=  f.date(from: adtime)! {
                    UserDefaults.standard.setValue("", forKey: "AdTime")
                }
            }
        }

    }
    
    
    
    
    func CloseView() {
        if self.myView! != nil {
            self.myView!.removeFromSuperview()
        }
    }
    
    func CloseChapterView() {
        
        if self.VerseView! != nil {
            self.VerseView!.removeFromSuperview()
        }
    }
    
    
    func CloseMenu() {
        if let menuFrame = self.MenuFrame {
            menuFrame.removeFromSuperview()
            self.MenuFrame = nil
        }
    }
    
    
    
    func ReloadCoredata() -> Array<String> {
        let book_name  = UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
        
            self.BookTxt.text = book_name
        
            self.BibleSavedVerses.removeAll()
            self.BookFilter.removeAll()
            self.BibleSavedVerses = CoreDataModel.sharedInstance.AudioBibleVerse(entity: CDBookSavedInfo, bookname: book_name)
        
            for items in self.BibleSavedVerses {
                let srt = CoreDataModel.sharedInstance.seperateByArrayBook(SeperateValue: items)
                self.BookFilter.append(srt)
            }
        
        return self.BookFilter
    }
    
    
    
    
    func AlertFrame(AlertNote:String,Vers:String,Title:String) {

        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "Ad_ToastController") as! Ad_ToastController
        vc.AlertTxt = AlertNote
        vc.VText = Vers
        vc.VTitle = Title
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    func OpenPreview(SavedImage:UIImage, FrameHeight:CGFloat) {
//        self.view.makeToast("Image Saved Successfully!", duration: 2.0, position: .bottom)
        
//        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ImageSavedVC") as! ImageSavedVC
//        vc.SavedImage = SavedImage
//        vc.FrameHeight = FrameHeight
//        vc.modalPresentationStyle = .overCurrentContext
//        vc.modalTransitionStyle = .crossDissolve
//        present(vc, animated: true, completion: nil)
    }
    
    
    
    func shared(VerseStr:String,Bookname:String) {
        
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SharedViewController") as! SharedViewController
        vc.VerseStr = VerseStr
        vc.Bookname = Bookname
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
        
        
//        let text = "\(VerseStr) \n\n      \(Bookname)"
//        let textShare = [ text ]
//        let activityViewController = UIActivityViewController(activityItems: textShare as [Any] , applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view
//        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
//        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
//        self.present(activityViewController, animated: true, completion: nil)
    }
        
    
    func shared(Link:String) {
        let text = "App Link : \(Link)"
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func ConstrainChange(Top: CGFloat, bottom: CGFloat) {
            self.VeresViewBottom.constant = (Top < 0.0 ? 0.0:-72.0)
        
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
                self!.topBannerConstant.constant = Top
                self!.BottomMenyConstrain.constant = bottom
                self!.MenuConstrain.constant = bottom >= 20 ? 20:0
                self!.view.layoutIfNeeded()
         }, completion: { finished in
            })
    }
     
    
    
    func sharedImage(shared:UIImage) {
        
        let activityViewController = UIActivityViewController(activityItems: [shared], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func sharedImage(sharedUrl:URL, VerseStr:String,Bookname:String) {
        
        
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SharedViewController") as! SharedViewController
        vc.VerseImgData = self.loadImage(fileURL: sharedUrl)
        vc.VerseStr = VerseStr
        vc.Bookname = Bookname
        vc.VerseImgName = Bookname
        vc.ShareVerseImageURL = [sharedUrl]
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
        
        
//        let activityViewController = UIActivityViewController(activityItems: [sharedUrl], applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
//
//        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
//        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
//
//        self.present(activityViewController, animated: true, completion: nil)
//        activityViewController.completionWithItemsHandler = { activity, success, items, error in
//            self.dismiss(animated: true, completion: nil)
//            FileManager.default.clearTmpDirectory()
//        }
    }
    
    
    
    private func loadImage(fileURL: URL) -> Data? {
        do {
            let imageData = try Data(contentsOf: fileURL)
            return imageData
        } catch {
        }
        return nil
    }
    
    
    
    func MarkAsReadPopup() {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "QuizAlertVC") as! QuizAlertVC
        vc.bookname = UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
        vc.Chapter = UserDefaults.standard.string(forKey: "BookChapter") ?? "0"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
        
    func SliderCardPreview(Vereseimage:UIImage) {
        
        SaveImage.sharedInstance.Save(Mainview:self, saveImage: Vereseimage)
        
//        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ImagePreviewVc") as! ImagePreviewVc
//        vc.ImgVerse = Verese
//        vc.ImgVerseTitle = Book
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
    }
    
    
    
//    @objc func SliderCardPreview (notification: NSNotification) {
//        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ImagePreviewVc") as! ImagePreviewVc
//
//        vc.Img = (notification.userInfo!["verseimage"] as! String)
//        vc.ImgVerse = (notification.userInfo!["Verses"] as! String)
//        vc.ImgVerseTitle = (notification.userInfo!["VersesTitle"] as! String)
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
//    }
    
    
    
    
    func SubscriptionVucall() {
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.myView!)
        self.SubscriptionVu = SubscriptionPopup.fromNib(named: "SubscriptionPopup")
        self.SubscriptionVu!.frame = self.myView!.bounds
        self.SubscriptionVu!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView!.addSubview(self.SubscriptionVu!)
        self.myView!.bringSubviewToFront(self.SubscriptionVu!)
    }
    
    
            
    
    
    
    
    @IBAction func NightModeAction(_ sender: Any) {
        self.NightMode()
    }
    
    
    
    
    // MARK: Night Mode
    @objc func NightMode() {
            var SourceColor:UIColor?
            if UserDefaults.standard.color(forKey: "SourceThemecolor") == nil {
                UserDefaults.standard.set(PrimaryColor, forKey: "SourceThemecolor")
            }
            SourceColor = UserDefaults.standard.color(forKey: "SourceThemecolor")!

            if (self.Themecolor!.toHexString() != UIColor.black.toHexString() &&  self.Themecolor!.toHexString() != BGNightMode.toHexString()) || self.Themecolor!.toHexString() == "#000000" {
                UserDefaults.standard.set(BGNightMode, forKey: "AppThemeColor")
                self.NightModeBtn.setImage(UIImage(named: "night-mode-on"), for: .normal)
            } else {
                self.NightModeBtn.setImage(UIImage(named: "night-mode-off"), for: .normal)
                UserDefaults.standard.set(SourceColor, forKey: "AppThemeColor")
            }

        self.PageConfig()
//           App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
        
          DispatchQueue.main.async {
              self.mainContainer()
           }
     }

    
    
    func CallIndustrialAd() {

//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
//                let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "InterstitialViewController") as! InterstitialViewController
//                vc.LoadAdCatagory = "INTERSTITIAL"
//                vc.modalPresentationStyle = .overCurrentContext
//                vc.modalTransitionStyle = .crossDissolve
//                self.present(vc, animated: true, completion: nil)
//        }
    }
    
    
    
    
    
    
    
}

// MARK: - BibleSubscriptionView Presentation Helper
extension ReaderViewController {
    
    // Removed presentBibleSubscriptionImmediately() function
    // IAP is now shown after onboarding flow, not automatically in Reader
}

extension Date {
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
}
 

