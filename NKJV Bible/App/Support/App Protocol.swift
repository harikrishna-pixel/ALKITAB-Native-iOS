//
//  App Protocol.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 09/12/22.
//


import UIKit

class App_Protocol: NSObject {
    
    static var delegatePageController: PageControllerDelegate?
    static var delegateReader: ReaderDelegate?
    static var delegateBook: BookDelegate?
    static var delegateReaderSource: ReaderSourceDelegate?
    static var delegateMyLibrary:MyLibraryDelegate?
    static var delegateDailyVerse:DailyVerseDelegate?
    static var delegateSearch:SearchDelegate?
    static var delegate: SpeechAction?
    static var delegateAVplayerProtocol: AVplayerProtocol?
    static var Imagesliderdelegate: Imageslider?
    static var IMageReloaddelegate: IMageReload?
    static var DelegateSplash: SplashDelegate?
    
    static var DelegateSlideCard: SlideCard?
    static var DelegateVersesMenuPopup: VersesMenuPopup?
    
    static var UnituAdCallDelegate: UnituAdCall?
    
    static var SettingDelegate: Setting?
    
    static var CardShowdelegate: CardShow?
    static var QuizAlertdelegate: QuizAlert?
    static var InterstitialDelegate: InterstitialAd?
    static var HomeVuDelegate: HomeVu?
    
}




protocol HomeVu {
    func ChangeVerse()
}




protocol CardShow {
  func ReloadList()
  func cardNavigate()
  func AdNotAvailable()
}


protocol Setting {
   func CallRate(Rate:String)
}


protocol InterstitialAd {
   func CallRate(Rate:String)
}




protocol IMageReload {
  func LoadImage()
  func ReloadCollectionView()
}






protocol PageControllerDelegate {
    func disaBlePageControll()
    func enablePageControll()
    func ReloadAllData(index: Int)
}


protocol ReaderSourceDelegate {
    func ReloadBibleData(ChapterNo:Int)
    func ReloadFont(ChapterNo:Int)
    func navigateToSelectedVerse()
    func GetTSData() ->(AudioBibleList:Array<String>, BookName:String, pagecount:Int)
}


protocol BookDelegate {
    func CloseView()
    func SelectView()
    func CloseChapterView(VerseNo:Int)
    func VerseSelectionAction(Chapter:Int)
}

protocol DailyVerseDelegate {
    func CloseView(ReadEnable:Bool)
    func reloadDailyVerse()
}



protocol Imageslider {
    func DismissVc() 
}


protocol QuizAlert {
    func DismissVc(Close:Bool)
}



protocol VersesMenuPopup {
    func ChangeNote(Notetxt:String,_ Status:Bool)
}


protocol UnituAdCall {
    func AdDidClosed()
    func unityAdOpen()
    func NoAdClosed()
}




protocol SplashDelegate {
    func PopupClose()
    func LoadData()
    func OpenAd()
}



protocol MyLibraryDelegate {
    func popupvuew(SelectedVerse:String,SelectedTag:String)
    func CloseView()
    func ReloadAllData()
}

protocol SearchDelegate {
    func popupvuew(SelectedVerse:String)
    func CloseView()
    func navigateMainClass()
}




protocol SpeechAction {
    func StopSpeeking()
    func playAction()
    func NextString()
    func PreviousString()
}



protocol SlideCard {
    func reloadNotedata()
    func ChangeHighlightStatus()
    func CloseVc()
    func NotesSavedStatus(Status:Bool)
    func CloseChapterView()
    func CloseVerseView()
    func ChapterVers(Book:String)
    func VerseSelectionAction(Chapter:Int)
    func paymentStatus()
}




protocol ReaderDelegate {
    func NoteNib(VersePosition: Int, BookName: String, Pageindex:Int, BookVerse:Array<String>, note:String)
    
    
    func MenuNib(VersePosition: Int, BookName: String, Pageindex:Int, BookVerse:Array<String>, Bookmark:String, ColorCode:String, UnderlineStatus:String, note:String)
    
    func WallpaperNib(VersePosition: Int, BookName: String, Pageindex:Int, BookVerse:Array<String>)
//    func SliderCardPreview(Verese:String, Book:String)
    func SliderCardPreview(Vereseimage:UIImage)
    func OpenPreview(SavedImage:UIImage, FrameHeight:CGFloat)
    func CallAds()
    func CloseView()
    func ClosePlayerPopup()
    func CloseMenu()
    func ConstrainChange(Top:CGFloat,bottom:CGFloat)
    func ReloadCoredata() -> Array<String> 
//    func AlertFrame(AlertNote:String)
    func AlertFrame(AlertNote:String,Vers:String,Title:String)
    func shared(VerseStr:String,Bookname:String)
    func shared(Link:String)
    func HomePageCall(Status:Bool)
    func PageConfig()
    func hideBottomMenu(Status:Bool)
    func mainContainer()
//    func sharedImage(sharedUrl:URL)
    func sharedImage(sharedUrl:URL, VerseStr:String,Bookname:String)
    func MarkAsReadPopup()
    
    func FeedbackNavigate()
    func CallWallpaperAds()
    func Quiz(Go:Bool)
    func ImageEditor(Verse:String,Book:String,Image:UIImage)
    
    func AboutusCall()
    func NightMode()
    
    func CallInterstitialAd()
    func CloseChapterView()
    func VerseSelectionAction(Chapter:Int)
    func paymentStatus()
    
    func CallIndustrialAd()
    
    func CallMenu(getString: String, VCSelection: String, TagSelection:String)
    
    func ExplanationNib(VersePosition: Int, BookName: String, Pageindex:Int, BookVerse:Array<String>)
    
    func ChapterSummaryNib(BookName: String, Pageindex: Int, BookVerse: Array<String>)
    
    func ShowSavedExplanation(dataString: String)
    
    func CallRate(RateContent:String)
    
    func IndsAdLoad(Show:Bool)
    
    func NavigateToQuiz()
    
    
}






protocol AVplayerProtocol {
    func PlayControl()
}





