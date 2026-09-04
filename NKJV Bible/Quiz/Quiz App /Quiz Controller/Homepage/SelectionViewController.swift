//
//  SelectionViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 18/01/23.
//

import UIKit
import Toast_Swift
import SwiftUI

class SelectionViewController: UIViewController, QuizSelect {
    
    
    
    
    @IBOutlet weak var BookView: UIView!
    @IBOutlet weak var ChapterView: UIView!
    
    
    @IBOutlet weak var BookSelect: UIView!
    @IBOutlet weak var ChapterSelect: UIView!
    @IBOutlet weak var EasySelect: UIView!
    @IBOutlet weak var MediumSelect: UIView!
    @IBOutlet weak var HardSelect: UIView!
    
    
    @IBOutlet weak var EasyTxt: UILabel!
    @IBOutlet weak var MediumTxt: UILabel!
    @IBOutlet weak var HardTxt: UILabel!
    
    
    @IBOutlet weak var BookListVu: UIView!
    @IBOutlet weak var ChapterListVu: UIView!
    
    
    @IBOutlet weak var BookTxt:UILabel!
    @IBOutlet weak var ChapterTxt:UILabel!
    
    
    @IBOutlet weak var EasyBtn: UIButton!
    @IBOutlet weak var MediumBtn: UIButton!
    @IBOutlet weak var HardBtn: UIButton!
    @IBOutlet weak var BlankAlert: UILabel!
    @IBOutlet weak var Start: UIButton!
    
    
    @IBOutlet weak var LogoImage: UIImageView!
    @IBOutlet weak var TitleLbl: UILabel!
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    
    @IBOutlet weak var WalletMoney: UILabel!
    
    
    weak var BookCell :BookList?
    weak var ChapterCell :Chapter?
    var ChapterCount :Int = 0
    
    var ChapterString :String = ""
    var BookString :String = ""
    var refresh :Bool = false
    
    var Level :String = ""
    var Themecolor:UIColor?
    /// Set from Mark as Read → Quiz Hub. Nil keeps classic Let's Start → Bible Quiz.
    var markAsReadDestination: MarkAsReadQuizDestination? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        
        if UserDefaults.standard.integer(forKey: "QuestionList") == 0 {
            UserDefaults.standard.setValue(10, forKey: "QuestionList")
        }
        
    
        if UserDefaults.standard.string(forKey: "CardDate") ?? "" != Date().string(format: "dd:MM:yyy") {
            UserDefaults.standard.setValue(Date().string(format: "dd:MM:yyy"), forKey: "CardDate")
            UserDefaults.standard.setValue(0, forKey: "CardCount")
            CoreDataModel.sharedInstance.deleteAllData(CDCardList)
        }
        
         
        if UserDefaults.standard.integer(forKey: "CardCount") > 3 && TimeConvert.sharedInstance.ConvertSeconds(toDate: UserDefaults.standard.string(forKey: "CardAdTime") ?? Date().string(format: "MM/dd/yy HH:mm:ss")) <= 0 {
            CoreDataModel.sharedInstance.deleteAllData(CDCardList)
        }
 
        
        
        QuizProtocol.QuizSelectdelegate = self  
        self.Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.LogoImage!, colorVu: ((Themecolor == BGNightMode ? DarkModeColor:Themecolor)!))
        self.TitleLbl.textColor = self.Themecolor
        
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        self.WalletMoney.text =  "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        self.BlankAlert.textColor = self.Themecolor
        
        
        if !UserDefaults.standard.bool(forKey: "NotFirstTime") {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "WalletMoney")+500, forKey: "WalletMoney")
            UserDefaults.standard.set(true, forKey: "NotFirstTime")
        }
        
        if !UserDefaults.standard.bool(forKey: "FirstTime") {

            UserDefaults.standard.set(true, forKey: "MusicSwitch")
            UserDefaults.standard.set(true, forKey: "ToneSwitch")
            UserDefaults.standard.set(true, forKey: "VibSwitch")
            UserDefaults.standard.set(true, forKey: "FirstTime")
        }
        
        
        self.BookSelect.ViewShadow(6, color: UIColor.darkGray)
        self.ChapterSelect.ViewShadow(6, color: UIColor.darkGray)
        
        self.BookListVu.ViewShadow(6, color: UIColor.darkGray)
        self.ChapterListVu.ViewShadow(6, color: UIColor.darkGray)
        self.BookView.ViewShadow(6, color: UIColor.darkGray)
        self.ChapterView.ViewShadow(6, color: UIColor.darkGray)

        
        let TextInfo = App_Protocol.delegateReaderSource?.GetTSData()

        self.Start.backgroundColor = self.Themecolor
        
        if ChapterString != "" {
            self.BookTxt.text = BookString
            self.ChapterTxt.text = ChapterString
            self.Start.isHidden = false
        }
    }
    
     

    
    override func viewWillAppear(_ animated: Bool) {
        self.WalletMoney.text = "\(UserDefaults.standard.integer(forKey: "WalletMoney"))"
        
        
        if !refresh {
            
            if UserDefaults.standard.string(forKey: "LastSelectedBook") ?? "" != "" && self.BookString == ""{
                self.BookTxt.text = UserDefaults.standard.string(forKey: "LastSelectedBook") ?? ""
                self.ChapterTxt.text = UserDefaults.standard.string(forKey: "LastSelectedChapter") ?? ""
                self.ChapterCount = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: UserDefaults.standard.string(forKey: "LastSelectedBook")!)
                
            } else {
                self.BookTxt.text = (self.BookString == "" ? "Book":self.BookString)
                self.ChapterTxt.text = (self.ChapterString == "" ? "Chapter":self.ChapterString)
            }
            

            self.EasySelect.ViewShadow(6, color: UIColor.darkGray)
            self.MediumSelect.ViewShadow(6, color: UIColor.darkGray)
            self.HardSelect.ViewShadow(6, color: UIColor.darkGray)
            
            
            self.EasySelect.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            self.MediumSelect.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            self.HardSelect.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            
            self.EasyTxt.textColor = UIColor.black
            self.MediumTxt.textColor = UIColor.black
            self.HardTxt.textColor = UIColor.black
             
            
            self.Level = ""
            self.Start.isHidden = true
            self.BlankAlert.isHidden = true
            
        } else {
            self.refresh = false
        }
    }

    
    @IBAction func BookListAction(_ sender: Any) {
        self.BookOpenClose()
    }
    
    
    
    func BookOpenClose() {
        
        if self.BookListVu.isHidden {
            self.BookListVu.isHidden = false
            self.ChapterListVu.isHidden = true
             
            self.BookCell = BookList.fromNib(named: "BookList")
            self.BookCell!.frame = self.BookListVu!.bounds
            self.BookCell!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.BookListVu!.addSubview(self.BookCell!)
//            self.BookListVu!.ViewBorder(color: self.Themecolor!)
            
        } else {
            self.BookListVu.isHidden = true
            self.BookCell?.removeFromSuperview()
        }
    }
    
    
    
    func Selection(BookCount:String) {
        
        self.BookTxt.text = BookCount.components(separatedBy: "-")[0]
        self.ChapterCount = Int(BookCount.components(separatedBy: "-")[1])!
        self.ChapterTxt.text = "Chapter"
        self.Start.isHidden = true
        self.BookOpenClose()
        self.ChapterOpenClose()
          
    }
    
    
    func ChapterSelection(Chapter: String) {
        self.ChapterTxt.text = Chapter
        self.ChapterOpenClose()
        
        if self.ChapterTxt.text != "Chapter" && self.Level != "" {
            self.Start.isHidden = false
        } else {
            self.Start.isHidden = true
        }
    }
    
    
    @IBAction func ChapterListAction(_ sender: Any) {
        self.ChapterOpenClose()
    }


    
    
    func ChapterOpenClose() {
        if self.ChapterListVu.isHidden && self.BookTxt.text != "Book" {
            self.ChapterListVu.isHidden = false
            
            self.ChapterCell = Chapter.fromNib(named: "Chapter")
            self.ChapterCell!.frame = self.ChapterListVu!.bounds
            self.ChapterCell!.ChapterCount = self.ChapterCount
            self.ChapterCell!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.ChapterListVu!.addSubview(self.ChapterCell!)
//            self.ChapterListVu!.ViewBorder(color: self.Themecolor!)
            
        } else {
            self.ChapterListVu.isHidden = true
            self.BookCell?.removeFromSuperview()
            if self.BookTxt.text == "Book" {
                self.view.makeToast("Please select Book first", duration: 2.0, position: .bottom)
            }
        } 
    }
    
    
    @IBAction func Level_Action(sender: UIButton) {
        
        if self.ChapterTxt.text != "Chapter" {
            self.Start.isHidden = false
        } else {
            self.Start.isHidden = true
        }
        
        
        self.EasySelect.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.MediumSelect.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.HardSelect.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        self.EasyTxt.textColor = UIColor.black
        self.MediumTxt.textColor = UIColor.black
        self.HardTxt.textColor = UIColor.black
        self.BlankAlert.isHidden = false
        
        switch sender {
        case EasyBtn:
            self.EasySelect.backgroundColor = self.Themecolor
            self.EasyTxt.textColor = UIColor.white
            self.Level = "Easy"
            self.BlankAlert.text = "2 Blanks to fill"
            
        case MediumBtn:
            self.MediumSelect.backgroundColor = self.Themecolor
            self.MediumTxt.textColor = UIColor.white
            self.Level = "Medium"
            self.BlankAlert.text = "4 Blanks to fill"
            
        case HardBtn:
            self.HardSelect.backgroundColor = self.Themecolor
            self.HardTxt.textColor = UIColor.white
            self.Level = "Hard"
            self.BlankAlert.text = "6 Blanks to fill"
            
        default:
            break

        }
    }
    
    
    
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popToViewController(ofClass: ReaderViewController.self)
    }
    
    @IBAction func Start(_ sender: Any) {
        
        UserDefaults.standard.setValue(self.Level, forKey: "Qlevel")
        UserDefaults.standard.setValue(self.BookTxt.text!, forKey: "Qbook")
        UserDefaults.standard.setValue(Int(self.ChapterTxt.text!)!, forKey: "Qchapter")
        
        UserDefaults.standard.setValue(self.BookTxt.text!, forKey: "LastSelectedBook")
        UserDefaults.standard.setValue(self.ChapterTxt.text!, forKey: "LastSelectedChapter")
        
        let book = self.BookTxt.text!
        let chapter = Int(self.ChapterTxt.text!)!
        
        switch markAsReadDestination {
        case .challenge(let kind):
            openChallenge(kind, book: book, chapter: chapter, level: self.Level)
        case .bibleQuiz, .none:
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizMainPageVC") as! QuizMainPageVC
            vc.level = self.Level
            vc.BookName = book
            vc.Chapter = chapter
            self.navigationController?.pushViewController(vc, animated: true)
        }
     
    }

    private func openChallenge(_ kind: ChallengeKind, book: String, chapter: Int, level: String) {
        let difficulty: ChallengeDifficulty
        switch level.lowercased() {
        case "medium": difficulty = .medium
        case "hard": difficulty = .hard
        default: difficulty = .easy
        }
        let config = ChallengeSessionConfig.markAsRead(
            book: book,
            chapter: chapter,
            difficulty: difficulty
        )
        let verse = config.primaryVerse()
        let root = ChallengeGameScreen(
            kind: kind,
            verse: verse,
            sessionConfig: config,
            onClose: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onOpenLegacyQuiz: { [weak self] in
                guard let self = self else { return }
                let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizMainPageVC") as! QuizMainPageVC
                vc.level = level
                vc.BookName = book
                vc.Chapter = chapter
                self.navigationController?.pushViewController(vc, animated: true)
            }
        )
        let host = SelectionChallengeHostingController(rootView: root)
        host.view.backgroundColor = .white
        navigationController?.pushViewController(host, animated: true)
    }
    
   
    @IBAction func Settings_Action(_ sender: Any) {
        self.refresh = true
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizSettingVC") as! QuizSettingVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func Wallet_Action(_ sender: Any) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
                  self.navigationController?.pushViewController(vc, animated: true)
            }
    }
      
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

private final class SelectionChallengeHostingController<Content: View>: UIHostingController<Content> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
