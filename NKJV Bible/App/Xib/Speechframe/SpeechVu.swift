//
//  SpeechVu.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 07/10/21.
//

import UIKit
import AVFoundation
import MediaPlayer



class SpeechVu: UIView,UITableViewDelegate, UITableViewDataSource, AVSpeechSynthesizerDelegate, SpeechAction {
    static weak var active: SpeechVu?
    
    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var VerseTitle: UILabel!
    @IBOutlet weak var Verse: UILabel!
    @IBOutlet weak var SettingsVu: UIView!
    @IBOutlet weak var LanguageChangeVU: UIView!
    @IBOutlet var DottedLines: UIView!
    @IBOutlet var ResetVu: UIView!
    
    @IBOutlet weak var TS_Repeat: UIImageView!
    @IBOutlet weak var TS_Previous: UIImageView!
    @IBOutlet weak var TS_Backward: UIImageView!
    @IBOutlet weak var TS_Play: UIImageView!
    @IBOutlet weak var TS_Forward: UIImageView!
    @IBOutlet weak var TS_Next: UIImageView!
    @IBOutlet weak var TS_Stop: UIImageView!
    
    
    @IBOutlet weak var TS_PreviousBtn: UIButton!
    @IBOutlet weak var TS_BackwardBtn: UIButton!
    @IBOutlet weak var TS_ForwardBtn: UIButton!
    @IBOutlet weak var TS_NextBtn: UIButton!
    
    
    @IBOutlet weak var TSRepeatView: UIView!
    @IBOutlet weak var TSPreviousView: UIView!
    @IBOutlet weak var TSBackwardView: UIView!
    @IBOutlet weak var TSPlayview: UIView!
    @IBOutlet weak var TSForwardView: UIView!
    @IBOutlet weak var TSNextView: UIView!
    @IBOutlet weak var TSStopView: UIView!
    
    @IBOutlet weak var TableFrame: UIView!
    
    @IBOutlet weak var Pitchswitch: UISlider!
    @IBOutlet weak var Rateswitch: UISlider!
    
    @IBOutlet weak var LangaugaTable: UITableView!
    
    @IBOutlet weak var MainConsstrain: NSLayoutConstraint!
    @IBOutlet weak var SettingConsstrain: NSLayoutConstraint!
//    @IBOutlet weak var CloseIconConstrain: NSLayoutConstraint!
    @IBOutlet weak var TableConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var SettingsConstrain: NSLayoutConstraint!
    @IBOutlet weak var swipeConstrain: NSLayoutConstraint!
    @IBOutlet weak var MicConstrain: NSLayoutConstraint!
    
//    @IBOutlet weak var AudioIcon: NSLayoutConstraint!
    
     
//    var DlangIDFromServer:Array<String> = []
//    var DLAnguage:Array<String> = []
//    var DlangID:Array<String> = []
//    var Dlang:Array<String> = []
    
   var Selectedlang:String = primaryLanguage
    
    var langIDFromServer:Array<String> = []
    var LAnguage:Array<String> = []
    var langID:Array<String> = []
    var lang:Array<String> = []
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      
    var App_langIDFromServer =  ["ar-SA", "cs-CZ", "da-DK", "de-DE", "de-DE", "de-DE", "el-GR", "en-AU", "en-AU", "en-AU", "en-GB", "en-GB", "en-GB", "en-IE", "en-IN", "en-US", "en-US", "en-US", "en-US", "en-ZA", "es-ES", "es-MX", "fi-FI", "fr-CA", "fr-FR", "fr-FR", "fr-FR", "he-IL", "hi-IN", "hu-HU", "id-ID", "it-IT", "ja-JP", "ja-JP", "ja-JP", "ko-KR", "nl-BE", "nl-NL", "pl-PL", "pt-BR", "pt-PT", "ro-RO", "ru-RU", "sk-SK", "sv-SE", "th-TH", "tr-TR", "zh-CN", "zh-CN", "zh-CN", "zh-HK", "zh-TW", "en-US"]

    var App_LAnguage = ["Arabic","Czech", "Danish", "German", "German", "German", "Greek", "English", "English", "English", "English", "English", "English", "English", "English", "English", "English", "English", "English", "English","Spanish","Spanish","Finnish", "French", "French", "French", "French", "Hebrew","Hindi", "Hungarian", "Indonesian", "Italian", "Japanese", "Japanese", "Japanese", "Korean", "Dutch", "Dutch", "Polish", "Portuguese", "Portuguese", "Romanian", "Russian", "Slovak", "Swedish", "Thai", "Turkish", "Chinese", "Chinese", "Chinese", "Chinese", "Chinese", "English"]

    var App_langID =  ["com.apple.ttsbundle.Maged-compact", "com.apple.ttsbundle.Zuzana-compact", "com.apple.ttsbundle.Sara-compact", "com.apple.ttsbundle.Anna-compact", "com.apple.ttsbundle.siri_female_de-DE_compact", "com.apple.ttsbundle.siri_male_de-DE_compact", "com.apple.ttsbundle.Melina-compact", "com.apple.ttsbundle.siri_female_en-AU_compact", "com.apple.ttsbundle.siri_male_en-AU_compact", "com.apple.ttsbundle.Karen-compact", "com.apple.ttsbundle.siri_male_en-GB_compact", "com.apple.ttsbundle.Daniel-compact", "com.apple.ttsbundle.siri_female_en-GB_compact", "com.apple.ttsbundle.Moira-compact", "com.apple.ttsbundle.Rishi-compact", "com.apple.ttsbundle.siri_male_en-US_compact", "com.apple.speech.synthesis.voice.Fred", "com.apple.ttsbundle.siri_female_en-US_compact", "com.apple.ttsbundle.Samantha-compact", "com.apple.ttsbundle.Tessa-compact", "com.apple.ttsbundle.Monica-compact", "com.apple.ttsbundle.Paulina-compact", "com.apple.ttsbundle.Satu-compact", "com.apple.ttsbundle.Amelie-compact", "com.apple.ttsbundle.siri_male_fr-FR_compact", "com.apple.ttsbundle.siri_female_fr-FR_compact", "com.apple.ttsbundle.Thomas-compact", "com.apple.ttsbundle.Carmit-compact", "com.apple.ttsbundle.Lekha-compact", "com.apple.ttsbundle.Mariska-compact", "com.apple.ttsbundle.Damayanti-compact", "com.apple.ttsbundle.Alice-compact", "com.apple.ttsbundle.siri_male_ja-JP_compact", "com.apple.ttsbundle.Kyoko-compact", "com.apple.ttsbundle.siri_female_ja-JP_compact", "com.apple.ttsbundle.Yuna-compact", "com.apple.ttsbundle.Ellen-compact", "com.apple.ttsbundle.Xander-compact", "com.apple.ttsbundle.Zosia-compact", "com.apple.ttsbundle.Luciana-compact", "com.apple.ttsbundle.Joana-compact", "com.apple.ttsbundle.Ioana-compact", "com.apple.ttsbundle.Milena-compact", "com.apple.ttsbundle.Laura-compact", "com.apple.ttsbundle.Alva-compact", "com.apple.ttsbundle.Kanya-compact", "com.apple.ttsbundle.Yelda-compact", "com.apple.ttsbundle.siri_male_zh-CN_compact", "com.apple.ttsbundle.Ting-Ting-compact", "com.apple.ttsbundle.siri_female_zh-CN_compact", "com.apple.ttsbundle.Sin-Ji-compact", "com.apple.ttsbundle.Mei-Jia-compact", "com.apple.speech.voice.Alex"]
    


    var App_lang = ["Saudi Arabia [Maged]", "Czech Republic [Zuzana]", "Denmark [Sara]", "Germany [Anna]", "Germany [Helena]", "Germany [Martin]", "Greece [Melina]", "Australia [Catherine]", "Australia [Gordon]", "Australia [Karen]", "United Kingdom [Arthur]", "United Kingdom [Daniel]", "United Kingdom [Martha]", "Ireland [Moira]", "India [Rishi]", "United States [Aaron]", "United States [Fred]", "United States [Nicky]", "United States [Samantha]", "South Africa [Tessa]", "Spain [Mónica]", "Mexico [Paulina]", "Finland [Satu]", "Canada [Amélie]", "France [Daniel]", "France [Marie]", "France [Thomas]", "Israel [Carmit]", "India [Lekha]", "Hungary [Mariska]", "Indonesia [Damayanti]", "Italy [Alice]", "Japan [Hattori]", "Japan [Kyoko]", "Japan [O-ren]", "Korea [Yuna]", "Belgium [Ellen]", "Netherlands [Xander]", "Poland [Zosia]", "Brazil [Luciana]", "Portugal [Joana]", "Romania [Ioana]", "Russia [Milena]", "Slovakia [Laura]", "Sweden [Alva]", "Thailand [Kanya]", "Turkey [Yelda]", "China [Li-mu]", "China [Tian-Tian]", "China [Yu-shu]", "Hong Kong [Sin-Ji]", "China [Mei-Jia]", "United States [Alex]"]
    
    
    
  
     var AudioBibleList:Array<String> = []
     var BookIndex:Int?
     var BookIndexCount:Int?
     var BookName:String = ""
     var Index:Int = 0
     var pageOn:Bool = true

     var LanguageCell: SpeechframeCell?
     var CloseStatue: Bool = true
     var Playstatus: Bool = false
     var Settingsstatus: Bool = true
     var TableStatus: Bool = true
     var SliderEnd: Bool = true
     var LanguageFilter = "en"
     var CurrentVerse:String = ""
     var CurrentIntex:Int = 0
     var NextOrprevious:Bool = false
     var ChangeLanguage:Bool = false
     var ChangeVoice:Bool = false
     var isAdjustingSlider: Bool = false // NEW: Prevent verse advance during slider adjustment
     var isStartingNextChapter = false
     private var pausedForAd = false
     var adjustmentStartIndex: Int = -1 // NEW: Track which verse index was playing when adjustment started
     var spokenCharacterIndex: Int = 0
     var speechStartIndex: Int = 0
     var settingsResumeUtterance: AVSpeechUtterance?
     var resumeHasStarted: Bool = false
    
     var StopStatus = false
    
    // VOICE CHANGE FIX: Add flag to prevent verse advancement during voice change
    var isChangingVoice: Bool = false
    var voiceChangeStartIndex: Int = -1
    
    var selectedCell:Int?

     var synth = Speaker()
     var Themecolor:UIColor?
    
    override func draw(_ rect: CGRect) {
        SpeechVu.active = self
        
        if pageOn {
            self.DottedLines.addDashedBorderView()
            
            self.MainView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 20)
            self.TableFrame.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 20)
            self.SettingsVu.roundCorners(corners: [.topLeft, .topRight ], radius: 20)
            App_Protocol.delegate = self
            self.LangaugaTable.delegate = self
            self.LangaugaTable.dataSource = self
            synth.synth.delegate = self
            
            LanguageChangeVU.isHidden = (APP_TYPE == "1" ? true:false)
                        
            self.BookIndexCount = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: self.BookName)
            
            // DEVICE COMPATIBILITY FIX: Log device voice capabilities on first load
            self.logDeviceVoiceCapabilities()
            
            self.languageFilter(Selectedlang: Selectedlang)
            
            self.Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
            self.ResetVu.backgroundColor = self.Themecolor
            self.MainView.backgroundColor = (self.Themecolor == BGNightMode ? DarkModeColor:Themecolor) // self.Themecolor
            
            self.TableFrame.backgroundColor = .white
            
//            self.AudioIcon.constant = (isIpad ? ScreenWidth:286)
            
            self.SettingsConstrain.constant = (isIpad ? 24:18)
            self.swipeConstrain.constant = (isIpad ? 24:18)
            self.MicConstrain.constant = (isIpad ? 24:18)
            
            
        
            self.VerseTitle.font = UIFont.systemFont(ofSize: (isIpad ? 22:15), weight: UIFont.Weight.medium)
            self.Verse.font = UIFont.systemFont(ofSize: (isIpad ? 25:17), weight: UIFont.Weight.bold)
            
            
            self.LoadSettings()
            
            self.LangaugaTable.register(UINib(nibName: "SpeechframeCell", bundle: nil), forCellReuseIdentifier: "SpeechframeCell")
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Repeat! , colorVu: UIColor.white)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Previous! , colorVu: UIColor.white)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Backward! , colorVu: UIColor.white)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Play! , colorVu: UIColor.white)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Forward! , colorVu: UIColor.white)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Next! , colorVu: UIColor.white)
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Stop! , colorVu: UIColor.white)
            
            
            
            if UserDefaults.standard.bool(forKey: "ShuffleVerse") {
                self.TSRepeatView.backgroundColor = .white
                ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Repeat! , colorVu: self.Themecolor!)
            }
                        
            self.ViewAnimation()
            self.ReloadPlayerIcons()
            pageOn = false
        }
    }
    
    
    func languageFilter(Selectedlang:String) {
        
        self.langIDFromServer.removeAll()
        self.LAnguage.removeAll()
        self.langID.removeAll()
        self.lang.removeAll()
        
        self.LanguageFilter = Selectedlang.components(separatedBy: ["-","_"])[0]
        
        // DEVICE-DRIVEN LIST with filtering: use available voices for this language, skip eloquence/duplicates
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        var addedIds = Set<String>()
        var addedNames = Set<String>()
        
        func isFilteredOut(_ voice: AVSpeechSynthesisVoice) -> Bool {
            let id = voice.identifier.lowercased()
            let name = voice.name.lowercased()
            if id.contains("eloquence") { return true } // skip novelty voices
            // skip duplicates by name token
            return false
        }
        
        func englishDisplayName(for voice: AVSpeechSynthesisVoice) -> String {
            switch voice.language {
            case let code where code.hasPrefix("en-US"): return "United States [\(voice.name)]"
            case let code where code.hasPrefix("en-GB"): return "United Kingdom [\(voice.name)]"
            case let code where code.hasPrefix("en-AU"): return "Australia [\(voice.name)]"
            case let code where code.hasPrefix("en-IN"): return "India [\(voice.name)]"
            case let code where code.hasPrefix("en-IE"): return "Ireland [\(voice.name)]"
            case let code where code.hasPrefix("en-ZA"): return "South Africa [\(voice.name)]"
            default: return "English [\(voice.name)]"
            }
        }
        
        // Prefer non-eloquence voices and dedup by name+id
        let filtered = availableVoices
            .filter { $0.language.hasPrefix(self.LanguageFilter) }
            .filter { !isFilteredOut($0) }
        
        for voice in filtered {
            if addedIds.contains(voice.identifier) { continue }
            let display = voice.language.hasPrefix("en") ? englishDisplayName(for: voice) : voice.name
            if addedNames.contains(display) { continue }
            
            self.langIDFromServer.append(voice.language)
            self.LAnguage.append(voice.language.hasPrefix("en") ? "English" : voice.language)
            self.langID.append(voice.identifier)
            self.lang.append(display)
            addedIds.insert(voice.identifier)
            addedNames.insert(display)
        }
        
        // Fallback if none found: take first non-eloquence voice (or any voice)
        if self.langID.isEmpty {
            let fallback = filtered.first ?? availableVoices.first
            if let fb = fallback {
                self.langIDFromServer.append(fb.language)
                self.LAnguage.append(fb.language.hasPrefix("en") ? "English" : fb.language)
                self.langID.append(fb.identifier)
                self.lang.append(fb.language.hasPrefix("en") ? englishDisplayName(for: fb) : fb.name)
            }
        }
        
        if !self.langID.isEmpty {
            CoreDataModel.sharedInstance.coreDataInsertSpeechSettings(CDSpeechSetting,langID:self.langID[0],langName:self.lang[0],langPitch:1.0,langRate:0.5)
        }
        self.BookIndexNo(BookIndexNum: BookIndex!)
        self.LangaugaTable.reloadData()
    }
    
    
    
    
    
    func LoadSettings() {
        
        let speeches = CoreDataModel.sharedInstance.GetSavedSpeechSettings(entity: CDSpeechSetting)
        let speechSettings = speeches.components(separatedBy: "/")
        
        Pitchswitch.value = Float(speechSettings[2]) ?? 1.0
        Rateswitch.value = Float(speechSettings[3]) ?? AVSpeechUtteranceDefaultSpeechRate
        
        Pitchswitch.minimumTrackTintColor = self.Themecolor ?? PrimaryColor
        Rateswitch.minimumTrackTintColor = self.Themecolor ?? PrimaryColor
        
        // BUG FIX 6 (PITCH/SPEED NOT WORKING): Keep existing event-based handlers
        Pitchswitch.addTarget(self, action: #selector(PitchValChanged(slider:event:)), for: .valueChanged)
        Rateswitch.addTarget(self, action: #selector(RateValChanged(slider:event:)), for: .valueChanged)
        
        // BUG FIX 6 (PITCH/SPEED NOT WORKING): NEW CODE - Add simpler handlers as fallback for some devices
        Pitchswitch.addTarget(self, action: #selector(PitchSliderChanged(slider:)), for: .touchUpInside)
        Pitchswitch.addTarget(self, action: #selector(PitchSliderChanged(slider:)), for: .touchUpOutside)
        Rateswitch.addTarget(self, action: #selector(RateSliderChanged(slider:)), for: .touchUpInside)
        Rateswitch.addTarget(self, action: #selector(RateSliderChanged(slider:)), for: .touchUpOutside)
    }
    
    
    func BookIndexNo(BookIndexNum:Int) {
        
        if BookIndex! >= 0 && BookIndex! <= BookIndexCount! {
            DispatchQueue.main.async {
                if self.Selectedlang == primaryLanguage {
                    self.AudioBibleList = BibleContent.sharedInstance.AudioBibleList(selecterBookName: self.BookName, selectedId: (BookIndexNum == 0 ? BookIndexNum:BookIndexNum-1))
                } else {
                    let bookPosition = BibleContent.sharedInstance.BookToPosition(stringBook: self.BookName)
                    self.AudioBibleList = SecondLanguage.shared.AudioBibleList(selectedId: self.BookIndex!-1, bookPosition: bookPosition)
                }
                
                self.Verse.text = String(format: "%@",self.AudioBibleList[0])
                self.VerseTitle.text = "\(self.BookName) \(self.BookIndex! == 0 ? 1:self.BookIndex!) - \((self.ChangeLanguage ? self.Index:self.Index+1))/\(self.AudioBibleList.count)"
                
            }
        }
        self.synth.synth.stopSpeaking(at: .immediate)
    }
    
    
    // MARK:- Button Action
    
    
    @IBAction func Close_Action(_ sender: Any) {
        
        if self.SettingConsstrain.constant == 80 {
            self.ViewAnimation()
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.SettingConsstrain.constant =  80
                 self.layoutIfNeeded()
            }, completion: { finished in
                self.ViewAnimation()
            })
        }
    }
    
    
    
    
    @IBAction func ChangeLanguage_Action(_ sender: Any) {
        
        self.ChangeLanguage = true
        if Selectedlang == primaryLanguage {
            self.languageFilter(Selectedlang: SecondaryLanguage)
            Selectedlang = SecondaryLanguage
        } else {
            Selectedlang = primaryLanguage
            self.languageFilter(Selectedlang: primaryLanguage)
        }
    }
    
    
    
    @IBAction func AudioSettings_Action(_ sender: Any) {
        self.SettingsAnimation()
    }
    
    @IBAction func LanguageChange_Action(_ sender: Any) {
        self.TableAnimation()
    }
    
    @IBAction func LanguageClose_Action(_ sender: Any) {
        self.TableAnimation()
    }
    
    @IBAction func LanguageReset_Action(_ sender: Any) {
        
        let sekectedAudio = (self.selectedCell == nil ? 0:self.selectedCell)
        
        CoreDataModel.sharedInstance.coreDataInsertSpeechSettings(CDSpeechSetting,langID:self.langID[sekectedAudio!],langName:self.lang[sekectedAudio!],langPitch:1.0,langRate:0.5)
        UserDefaults.standard.setValue(self.langID[sekectedAudio!], forKey: "langID")
        self.LoadSettings()
        self.LangaugaTable.reloadData()
        self.makeToast("Reset successful", duration: 2.0, position: .top)
    }
    
    
    @IBAction func Repeat_Action(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "ShuffleVerse") == false {
            UserDefaults.standard.setValue(true, forKey: "ShuffleVerse")
            self.TSRepeatView.backgroundColor = .white
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Repeat! , colorVu: self.Themecolor!)
        } else {
            UserDefaults.standard.setValue(false, forKey: "ShuffleVerse")
            self.TSRepeatView.backgroundColor = .clear
            ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Repeat! , colorVu: .white)
        }
    }
    
     
    
    
    
    
    @IBAction func Previous_Action(_ sender: Any) {
        NextOrprevious = true
        self.BookIndex = self.BookIndex!-1
        
        if self.BookIndex! < 0 {
            self.BookIndex = 0
            self.makeToast("Book finished. Choose the next book to play.", duration: 2.0, position: .top)
        }
        UserDefaults.standard.setValue(self.BookIndex!, forKey: "BookChapter")
        NotificationCenter.default.post(name: Notification.Name("ReloadTable"), object: nil)
        self.BookIndexNo(BookIndexNum: self.BookIndex!)
        self.StopSpeeking()
        self.ReloadPlayerIcons()
        
        App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
    }
    
    @IBAction func Backward_Action(_ sender: Any) {
        self.PreviousString()
        self.ReloadPlayerIcons()
    }
    
    @IBAction func Play_Action(_ sender: Any) {
        self.playAction()
    }
    
    
    @IBAction func Forward_Action(_ sender: Any) {
        self.NextString()
        self.ReloadPlayerIcons()
    }
    
    @IBAction func Next_Action(_ sender: Any) {
        self.BookIndex = self.BookIndex!+1
        
        if self.BookIndex! > BookIndexCount! {
            // Already at last chapter – show toast and clamp
            self.BookIndex = self.BookIndexCount!-1
            self.makeToast("Book finished. Choose the next book to play.", duration: 2.0, position: .top)
        } else {
            UserDefaults.standard.setValue(self.BookIndex!, forKey: "BookChapter")
            self.BookIndexNo(BookIndexNum: self.BookIndex!)
            self.StopSpeeking()
            self.ReloadPlayerIcons()
            App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
        }
    }
    
    @IBAction func Stop_Action(_ sender: Any) {
        self.StopStatus = true
        self.StopSpeeking()
    }
    
    
    func NextString() {
        self.Index = self.Index+1
        NextOrprevious = true
        if self.Index > AudioBibleList.count {
            self.Index = AudioBibleList.count-1
        }
        self.PlayOrder(TIntexIncrement: self.Index+1)
    }
    
    func PreviousString() {
        self.Index = self.Index-1
        NextOrprevious = true
        if self.Index < 0 {
            self.Index = 0
        }
        self.PlayOrder(TIntexIncrement: self.Index+1)
    }
    
    
    func pauseForAd() {
        let speech = synth.synth
        guard Playstatus, speech.isSpeaking || speech.isPaused else { return }
        if pausedForAd { return }
        pausedForAd = true
        if speech.isSpeaking {
            speech.pauseSpeaking(at: .immediate)
        }
    }

    func resumeAfterAd() {
        guard pausedForAd else { return }
        guard Playstatus else {
            pausedForAd = false
            return
        }
        AudioPlayerService.sharedInstance.setupAudioSession()
        if synth.synth.isPaused {
            synth.synth.continueSpeaking()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self, self.pausedForAd else { return }
            self.pausedForAd = false
            guard self.Playstatus, self.synth.synth.isPaused else { return }
            AudioPlayerService.sharedInstance.setupAudioSession()
            self.synth.synth.continueSpeaking()
        }
    }

    /// Stops speech so chapter audio can play alone. A late finish event must not start the next verse.
    func stopForChapterAudio() {
        let speech = synth.synth
        guard Playstatus || speech.isSpeaking || speech.isPaused else { return }
        Playstatus = false
        pausedForAd = false
        synth.myUtterance = nil
        speech.stopSpeaking(at: .immediate)
        PlayPause(ImageName: "Play")
    }

    func playAction() {
        
        self.TSPlayview.zoomIn()
        if Playstatus == false {
            (App_Protocol.delegateReader as? ReaderViewController)?.pauseChapterForSpeech()
            PlayerCommandClear()
            SpeechPlayFunc.Shared.playAudios()
            self.Playstatus = true
            self.PlayPause(ImageName: "pausePlayer")
            if self.synth.myUtterance != nil && self.synth.synth.isPaused {
                self.synth.synth.continueSpeaking()
            } else {
                self.PlayTS(self.Verse.text!)
            }
        } else {
            self.PlayPause(ImageName: "Play")
            self.synth.synth.pauseSpeaking(at: .immediate)
            self.Playstatus = false
        }
    }
    
    
    
    
    func ReloadPlayerIcons() {
        
        self.TS_Repeat.alpha = 1.0
        self.TS_Previous.alpha = 1.0
        self.TS_Backward.alpha = 1.0
        self.TS_Forward.alpha = 1.0
        self.TS_Next.alpha = 1.0
        
        
        self.TS_PreviousBtn.isEnabled = true
        self.TS_BackwardBtn.isEnabled = true
        self.TS_ForwardBtn.isEnabled = true
        self.TS_NextBtn.isEnabled = true
        
        
        
            if UserDefaults.standard.integer(forKey: "BookChapter") == 1 {                
                self.TS_Previous.alpha = 0.6
                self.TS_PreviousBtn.isEnabled = false
                // Also disable backward when at first chapter
                self.TS_Backward.alpha = 0.6
                self.TS_BackwardBtn.isEnabled = false
            } else if self.BookIndexCount! == UserDefaults.standard.integer(forKey: "BookChapter")  {
                self.TS_NextBtn.isEnabled = false
                self.TS_Next.alpha = 0.6
            }

            if self.Index == 0 {
                self.TS_Backward.alpha = 0.6
                self.TS_BackwardBtn.isEnabled = false
            } else if self.Index+1 == self.AudioBibleList.count {
                self.TS_ForwardBtn.isEnabled = false
                self.TS_Forward.alpha = 0.6
            }
        }
    
    
    func PlayerCommandClear() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.nextTrackCommand.removeTarget(nil)
        commandCenter.previousTrackCommand.removeTarget(nil)
    }
    func PlayTS(_ Verse:String) {
        speechStartIndex = 0
        spokenCharacterIndex = 0
        CurrentVerse = Verse
        CurrentIntex = self.Index
        self.synth.speak(self.Verse.text!)
    }
    
    func StopSpeeking() {
        self.PlayerCommandClear()
        self.Index = 0
        self.Playstatus = false
        synth.synth.stopSpeaking(at: .immediate)
        let SpeechText = String(format: "%@",AudioBibleList[self.Index])
        self.Verse.text = SpeechText
        self.synth.myUtterance = nil
        self.PlayPause(ImageName: "Play")
        self.Playstatus = false
        self.VerseTitle.text = "\(BookName) \(BookIndex!) - \(Index+1)/\(AudioBibleList.count)"
        
        // VOICE CHANGE FIX: Clear voice change flag when stopping
        self.isChangingVoice = false
        self.voiceChangeStartIndex = -1
        
        // Clear slider adjustment flag when stopping
        self.isAdjustingSlider = false
        self.adjustmentStartIndex = -1
        self.spokenCharacterIndex = 0
        self.speechStartIndex = 0
        self.settingsResumeUtterance = nil
    }

  
    
    
    func ViewAnimation() {
        
        if CloseStatue == true {
            UIView.animate(withDuration: 0.6) {
                self.MainConsstrain.constant = 10
                self.SettingConsstrain.constant = 80
                self.layoutIfNeeded()
            }
            CloseStatue = false
        } else {
            UIView.animate(withDuration: 0.6, animations: {
                self.MainConsstrain.constant = -440
                self.SettingConsstrain.constant = -440
                self.layoutIfNeeded()
            }, completion: { finished in
                self.StopSpeeking()
                App_Protocol.delegateReader?.CloseView()
            })
        }
    }
    
    
    func TableAnimation() {
        
        UIView.animate(withDuration: 0.6, animations: {
            self.SettingConsstrain.constant =  80
             self.layoutIfNeeded()
        }, completion: { finished in
            self.Settingsstatus = true
        })
        
        if TableStatus == true {
            UIView.animate(withDuration: 0.6) {
                self.TableConstrain.constant = 10
                self.layoutIfNeeded()
            }
            TableStatus = false
        } else {
            TableStatus = true
            UIView.animate(withDuration: 0.6) {
                self.TableConstrain.constant = -440
                self.layoutIfNeeded()
            }
        }
    }
    
  

    
    func SettingsAnimation() {
        if Settingsstatus == true {
            UIView.animate(withDuration: 0.6) {
                self.SettingConsstrain.constant =  270
                self.layoutIfNeeded()
            }
            Settingsstatus = false
        } else {
            Settingsstatus = true
            UIView.animate(withDuration: 0.6, animations: {
                self.SettingConsstrain.constant =  80
                 self.layoutIfNeeded()
            }, completion: { finished in
                
            })
        }
    }
    
    
    
    // MARK:  table
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lang.count
      }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
      {
        
        self.LanguageCell = self.LangaugaTable.dequeueReusableCell(withIdentifier: "SpeechframeCell") as? SpeechframeCell
        
        self.LanguageCell!.MainFrame.layer.borderColor = UIColor(red: 228.0 / 255.0, green: 228.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0).cgColor
        self.LanguageCell!.MainFrame.layer.cornerRadius = 4
        
        self.LanguageCell!.Name.text = self.lang[indexPath.row]
        self.LanguageCell!.language.text = self.LAnguage[indexPath.row]
        
         //set(self.DlangID[indexPath.row], forKey: "langID")
        self.LanguageCell!.backgroundColor = .clear
            
        if  self.langID[indexPath.row] == UserDefaults.standard.string(forKey:"langID") || (UserDefaults.standard.string(forKey: "langID") == nil && indexPath.row == 0 ) {
            self.LanguageCell!.MainFrame.backgroundColor = self.Themecolor
            self.LanguageCell!.MainFrame.layer.borderWidth = 0
            self.LanguageCell!.language.textColor = .white
            self.LanguageCell!.Name.textColor = .white
            self.LanguageCell!.SelectedAudio.isHidden = false
            self.LanguageCell!.Name.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
            self.LanguageCell!.language.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
        } else {
            self.LanguageCell!.language.textColor = .black
            self.LanguageCell!.Name.textColor = .black
            self.LanguageCell!.MainFrame.layer.borderWidth = 0.5
            self.LanguageCell!.MainFrame.backgroundColor = .clear
            self.LanguageCell!.SelectedAudio.isHidden = true
            self.LanguageCell!.Name.font = UIFont(name:"HelveticaNeue", size: 14.0)
            self.LanguageCell!.language.font = UIFont(name:"HelveticaNeue", size: 14.0)
        }
        
        return self.LanguageCell!
      }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCell = indexPath.row
        let selectedVoiceID = self.langID[indexPath.row]
        
        // DEVICE COMPATIBILITY FIX: Verify the voice is available before saving
        if AVSpeechSynthesisVoice(identifier: selectedVoiceID) != nil {
            UserDefaults.standard.set(selectedVoiceID, forKey: "langID")
            self.LangaugaTable.deselectRow(at: indexPath, animated: true)
            self.LangaugaTable.reloadData()
            
            print("🎤 [SpeechVu] Voice changed to: \(self.lang[indexPath.row]) (ID: \(selectedVoiceID))")
            
            // Save the new voice settings FIRST (this updates CoreData)
            self.SpeechVoiceSave()
            
            // VOICE CHANGE FIX: Set flag to prevent verse advancement
            if self.Playstatus {
                print("   → Stopping current playback and applying new voice")
                
                // Set flag and save current index BEFORE stopping speech
                self.isChangingVoice = true
                self.voiceChangeStartIndex = self.Index
                print("   🔒 Voice change locked at verse index: \(self.voiceChangeStartIndex)")
                
                // Stop current speech completely
                synth.synth.stopSpeaking(at: .immediate)
                self.synth.myUtterance = nil
                
                // Wait a moment for the stop to complete, then replay with new voice
                // The Speaker.speak() method reads from CoreData each time, so it will use the new voice
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    print("   → Replaying current verse at index \(self.Index): '\(self.Verse.text ?? "")'")
                    // This will create a NEW utterance with the updated voice from CoreData
                    self.PlayTS(self.Verse.text!)
                }
            } else {
                self.PlayPause(ImageName: "Play")
            }
        } else {
            // Voice not available - show error
            print("❌ [SpeechVu] Selected voice is not available on this device: \(selectedVoiceID)")
            self.makeToast("This voice is not available on your device", duration: 2.0, position: .top)
        }
    }
    
    
    
    func PlayPause(ImageName:String) {
        self.TS_Play.image = UIImage(named: ImageName)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.TS_Play! , colorVu: .white)
    }
    
    
    
    @objc func PitchValChanged(slider: UISlider, event: UIEvent) {
        // NEW FIX: Set flag and save current index to prevent verse advance
        if !isAdjustingSlider {
            isAdjustingSlider = true
            adjustmentStartIndex = self.Index // Save current verse index
            print("🎚 Pitch adjustment started at verse index: \(adjustmentStartIndex)")
        }
        SliderEnd = false
        self.settingsResumeUtterance = nil
        synth.synth.stopSpeaking(at: .immediate)
        
        // Check touch phase if available (for devices that support it)
        if let touchEvent = event.allTouches?.first {
            if touchEvent.phase == .ended {
                print("   ⚙️ Pitch slider ended, applying settings...")
                SliderEnd = true
                self.SpeechSettingsSave()
            }
        }
    }
    
    
    @objc func RateValChanged(slider: UISlider, event: UIEvent) {
        // NEW FIX: Set flag and save current index to prevent verse advance
        if !isAdjustingSlider {
            isAdjustingSlider = true
            adjustmentStartIndex = self.Index // Save current verse index
            print("🎚 Speed adjustment started at verse index: \(adjustmentStartIndex)")
        }
        SliderEnd = false
        self.settingsResumeUtterance = nil
        synth.synth.stopSpeaking(at: .immediate)
        
        // Check touch phase if available (for devices that support it)
        if let touchEvent = event.allTouches?.first {
            if touchEvent.phase == .ended {
                print("   ⚙️ Speed slider ended, applying settings...")
                SliderEnd = true
                self.SpeechSettingsSave()
            }
        }
    }
    
    // BUG FIX 6 (PITCH/SPEED NOT WORKING): NEW CODE - Fallback slider handlers for devices where touch events don't work
    @objc func PitchSliderChanged(slider: UISlider) {
        // NEW FIX: Set flag and save current index
        if !isAdjustingSlider {
            isAdjustingSlider = true
            adjustmentStartIndex = self.Index
            print("🎚 Pitch adjustment started at verse index: \(adjustmentStartIndex)")
        }
        self.settingsResumeUtterance = nil
        synth.synth.stopSpeaking(at: .immediate)
        SliderEnd = true
        self.SpeechSettingsSave()
        print("   ⚙️ Pitch changed, applying settings...")
    }
    
    @objc func RateSliderChanged(slider: UISlider) {
        // NEW FIX: Set flag and save current index
        if !isAdjustingSlider {
            isAdjustingSlider = true
            adjustmentStartIndex = self.Index
            print("🎚 Speed adjustment started at verse index: \(adjustmentStartIndex)")
        }
        self.settingsResumeUtterance = nil
        synth.synth.stopSpeaking(at: .immediate)
        SliderEnd = true
        self.SpeechSettingsSave()
        print("   ⚙️ Speed changed, applying settings...")
    }
    
    
    
    func SpeechVoiceSave() {
        // NEW: Remove delay for immediate voice change
        DispatchQueue.main.async {
            print("💾 [SpeechVu] Saving voice settings...")
            self.synth.synth.stopSpeaking(at: .immediate)
        
            let speeches = CoreDataModel.sharedInstance.GetSavedSpeechSettings(entity: CDSpeechSetting)
            let speechSettings = speeches.components(separatedBy: "/")

            
            CoreDataModel.sharedInstance.deleteAllData(CDSpeechSetting)

            if self.selectedCell == nil {
                CoreDataModel.sharedInstance.coreDataInsertSpeechSettings(CDSpeechSetting,langID:speechSettings[0],langName:speechSettings[1],langPitch:self.Pitchswitch.value,langRate:self.Rateswitch.value)
                print("   → Saved with existing voice: \(speechSettings[1])")
            } else {
                CoreDataModel.sharedInstance.coreDataInsertSpeechSettings(CDSpeechSetting,langID:self.langID[self.selectedCell!],langName:self.lang[self.selectedCell!],langPitch:self.Pitchswitch.value,langRate:self.Rateswitch.value)
                print("   → Saved with new voice: \(self.lang[self.selectedCell!])")
            }
        }
    }
    
    

    func SpeechSettingsSave() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            self.settingsResumeUtterance = nil
            self.synth.synth.stopSpeaking(at: .immediate)
        
            let speeches = CoreDataModel.sharedInstance.GetSavedSpeechSettings(entity: CDSpeechSetting)
            let speechSettings = speeches.components(separatedBy: "/")

            
            CoreDataModel.sharedInstance.deleteAllData(CDSpeechSetting)

            if self.selectedCell == nil {
                CoreDataModel.sharedInstance.coreDataInsertSpeechSettings(CDSpeechSetting,langID:speechSettings[0],langName:speechSettings[1],langPitch:self.Pitchswitch.value,langRate:self.Rateswitch.value)
            } else {
                CoreDataModel.sharedInstance.coreDataInsertSpeechSettings(CDSpeechSetting,langID:self.langID[self.selectedCell!],langName:self.lang[self.selectedCell!],langPitch:self.Pitchswitch.value,langRate:self.Rateswitch.value)
            }
            
            
            if self.Playstatus == true {
                // CRITICAL FIX: Ensure we're back at the correct index before replaying
                if self.adjustmentStartIndex >= 0 && self.Index != self.adjustmentStartIndex {
                    print("   ⚠️ Index mismatch! Resetting from \(self.Index) to \(self.adjustmentStartIndex)")
                    self.Index = self.adjustmentStartIndex
                }
                
                print("   → Continuing verse at index \(self.Index) with new settings")
                
                let fullVerse = String(format: "%@", self.AudioBibleList[self.Index])
                self.Verse.text = fullVerse
                let verse = fullVerse as NSString
                let start = min(max(0, self.spokenCharacterIndex), verse.length)
                let remaining = verse.substring(from: start)
                if remaining.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.isAdjustingSlider = false
                    self.adjustmentStartIndex = -1
                    self.speechStartIndex = 0
                    self.spokenCharacterIndex = 0
                    if self.Index < self.AudioBibleList.count - 1 {
                        self.Index = self.Index + 1
                        self.PlayOrder(TIntexIncrement: self.Index + 1)
                    } else {
                        self.StopSpeeking()
                    }
                } else {
                    self.speechStartIndex = start
                    self.synth.speak(remaining)
                    self.settingsResumeUtterance = self.synth.myUtterance
                }
            } else {
                self.PlayPause(ImageName: "Play")
                // Not playing, safe to clear flag immediately
                self.isAdjustingSlider = false
                self.adjustmentStartIndex = -1
                print("   ✅ Not playing, slider adjustment complete")
            }
        }
    }
    
     
    
    
    // MARK:- Speech delegate
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if isStartingNextChapter || pausedForAd { return }
        if let current = synth.myUtterance, utterance !== current { return }
        
        // VOICE CHANGE FIX: Handle voice change - prevent ANY verse advancement
        if isChangingVoice {
            print("🚫 Speech finished during voice change (current index: \(self.Index), voice change started at: \(self.voiceChangeStartIndex))")
            
            // Check if this is the replay finishing (index matches where voice change started)
            if self.Index == self.voiceChangeStartIndex {
                print("   ✅ Voice change replay finished at correct verse, clearing flag")
                self.isChangingVoice = false
                self.voiceChangeStartIndex = -1
                // Don't advance - just reload icons, let playback continue normally from here
                self.ReloadPlayerIcons()
                return
            } else {
                print("   ⚠️ Index mismatch during voice change - preventing any action")
                self.ReloadPlayerIcons()
                return
            }
        }
        // Moving pitch or speed stops the current line, then speaks the rest of this verse.
        // That stop is not the end of the verse. When the restarted verse finishes, keep going.
        if isAdjustingSlider {
            if settingsResumeUtterance == nil || utterance !== settingsResumeUtterance {
                self.ReloadPlayerIcons()
                return
            }
            self.settingsResumeUtterance = nil
            self.resumeHasStarted = false
            self.isAdjustingSlider = false
            self.adjustmentStartIndex = -1
            self.speechStartIndex = 0
            self.spokenCharacterIndex = 0
            self.SliderEnd = true
            self.continueAfterCurrentVerse()
            self.ReloadPlayerIcons()
            return
        }
        
        if SliderEnd {
            
//            print("self.Index ",self.Index)
//            print("self.AudioBibleList.count :", self.AudioBibleList.count)
//            print("NextOrprevious :", NextOrprevious)
            
            
            if NextOrprevious == true {
                print("End speech 1")
                NextOrprevious = false
                if self.AudioBibleList.count <= self.Index+1 {
                    self.StopSpeeking()
                }
            } else if self.ChangeVoice {
                // VOICE CHANGE FIX: This old code path caused verse advancement
                // Now handled by isChangingVoice flag above - just clear the old flag
                print("End speech 2 - Old ChangeVoice flag detected, clearing it")
                self.ChangeVoice = false
                // Don't advance to next verse - the new isChangingVoice flag handles this properly
                self.ReloadPlayerIcons()
            } else if self.ChangeLanguage {
                print("End speech 3")
                self.PlayOrder(TIntexIncrement: self.Index+1)
                self.ChangeLanguage = false
            } else if self.Index >= 0  &&  self.Index < self.AudioBibleList.count-1 && self.Playstatus {
                print("End speech 4")
                self.Index = self.Index+1
                self.PlayOrder(TIntexIncrement: self.Index+1)
            } else if self.StopStatus {
                print("End speech 5")
                self.StopStatus = false
                self.StopSpeeking()
            } else {
                print("End speech 6 - Chapter finished")
                
                // BUG FIX 4: OLD CODE - Had extra constraint check that prevented repeat from working
                // if UserDefaults.standard.bool(forKey: "ShuffleVerse") && self.SettingConsstrain.constant == 80 {
                // Problem: Repeat only worked when settings menu was at position 80, not always
                
                // Repeat restarts this chapter. Otherwise keep playing the next chapter.
                if Playstatus {
                    if UserDefaults.standard.bool(forKey: "ShuffleVerse") {
                        self.Index = 0
                        self.PlayOrder(TIntexIncrement: 1)
                    } else {
                        self.playNextChapter()
                    }
                }
            }
        } else {
            print("End speech")
        }
        
        self.ReloadPlayerIcons()
    }
    func continueAfterCurrentVerse() {
        speechStartIndex = 0
        spokenCharacterIndex = 0
        guard Playstatus else {
            StopSpeeking()
            return
        }
        if Index < AudioBibleList.count - 1 {
            Index = Index + 1
            PlayOrder(TIntexIncrement: Index + 1)
        } else if UserDefaults.standard.bool(forKey: "ShuffleVerse") {
            Index = 0
            PlayOrder(TIntexIncrement: 1)
        } else {
            playNextChapter()
        }
    }

    func playNextChapter() {
        let count = BookIndexCount ?? 0
        if (BookIndex ?? 0) >= count {
            makeToast("Book finished. Choose the next book to play.", duration: 2.0, position: .top)
            StopSpeeking()
            return
        }

        isStartingNextChapter = true
        BookIndex = (BookIndex ?? 0) + 1
        Index = 0
        speechStartIndex = 0
        spokenCharacterIndex = 0
        isAdjustingSlider = false
        adjustmentStartIndex = -1
        settingsResumeUtterance = nil
        resumeHasStarted = false
        UserDefaults.standard.setValue(BookIndex!, forKey: "BookChapter")
        NotificationCenter.default.post(name: Notification.Name("ReloadTable"), object: nil)

        if Selectedlang == primaryLanguage {
            AudioBibleList = BibleContent.sharedInstance.AudioBibleList(selecterBookName: BookName, selectedId: BookIndex! - 1)
        } else {
            let bookPosition = BibleContent.sharedInstance.BookToPosition(stringBook: BookName)
            AudioBibleList = SecondLanguage.shared.AudioBibleList(selectedId: BookIndex! - 1, bookPosition: bookPosition)
        }
        App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo: BookIndex!)

        guard !AudioBibleList.isEmpty else {
            isStartingNextChapter = false
            StopSpeeking()
            return
        }
        Playstatus = true
        PlayPause(ImageName: "pausePlayer")
        PlayOrder(TIntexIncrement: 1)
        isStartingNextChapter = false
        ReloadPlayerIcons()
    }

    
    
    func PlayOrder(TIntexIncrement:Int) {
        if TIntexIncrement > 0 && TIntexIncrement <= AudioBibleList.count {
            synth.synth.stopSpeaking(at: .immediate)
            self.synth.myUtterance = nil
            let SpeechText = String(format: "%@",AudioBibleList[self.Index])
            self.Verse.text = SpeechText
            if Playstatus {
                self.PlayTS(SpeechText)
            }
            self.VerseTitle.text = "\(BookName) \(BookIndex!) - \(Index+1)/\(AudioBibleList.count)"
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
            if isAdjustingSlider {
                resumeHasStarted = true
            }
        
        if Playstatus == true {
            self.spokenCharacterIndex = self.speechStartIndex + characterRange.location
            let shown = self.speechStartIndex == 0 ? utterance.speechString : (self.Index >= 0 && self.Index < self.AudioBibleList.count ? String(format: "%@", self.AudioBibleList[self.Index]) : utterance.speechString)
            let mutableAttributedString = NSMutableAttributedString(string: shown)
            let TextColor: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: self.Themecolor!]
            let highlight = NSRange(location: self.speechStartIndex + characterRange.location, length: characterRange.length)
            if highlight.location >= 0, highlight.location + highlight.length <= (shown as NSString).length {
                mutableAttributedString.addAttribute(.backgroundColor, value: SpeechColor, range: highlight)
                mutableAttributedString.addAttributes(TextColor, range: highlight)
            }
            
            self.Verse.attributedText = mutableAttributedString
        } else {
            self.synth.synth.stopSpeaking(at: .immediate)
        }
    }
    
    // DEVICE COMPATIBILITY FIX: Diagnostic function to log device voice capabilities
    func logDeviceVoiceCapabilities() {
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        
        print("📱 ========== DEVICE VOICE DIAGNOSTICS ==========")
        print("   Device Model: \(deviceModel)")
        print("   iOS Version: \(systemVersion)")
        print("   Total Available Voices: \(availableVoices.count)")
        
        // Group voices by language for better readability
        var voicesByLanguage: [String: [AVSpeechSynthesisVoice]] = [:]
        for voice in availableVoices {
            if voicesByLanguage[voice.language] == nil {
                voicesByLanguage[voice.language] = []
            }
            voicesByLanguage[voice.language]?.append(voice)
        }
        
        print("   Languages Available: \(voicesByLanguage.keys.sorted().joined(separator: ", "))")
        
        // Check which voices from our list are available
        let ourVoiceIDs = Set(App_langID)
        let availableVoiceIDs = Set(availableVoices.map { $0.identifier })
        let missingVoices = ourVoiceIDs.subtracting(availableVoiceIDs)
        
        if !missingVoices.isEmpty {
            print("   ⚠️ Missing Voices on This Device: \(missingVoices.count)")
            for (index, voiceID) in App_langID.enumerated() {
                if missingVoices.contains(voiceID) {
                    print("      - \(App_lang[index]) (\(voiceID))")
                }
            }
        } else {
            print("   ✅ All configured voices are available on this device")
        }
        print("================================================")
    }
    
    
}



