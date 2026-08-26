//
//  QuizAlertVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 22/03/23.
//

import UIKit

class QuizAlertVC: UIViewController, QuizAlert {

    @IBOutlet weak var AdBannerView: UIView!
    @IBOutlet weak var AskQuiz: UILabel!
    @IBOutlet weak var BackImg: UIImageView!
    @IBOutlet weak var BookTxt: UILabel!
    @IBOutlet weak var ChapterTxt: UILabel!
    @IBOutlet weak var LogoImage: UIImageView!
    @IBOutlet weak var ReadButton: UIButton!
    @IBOutlet weak var ShowDate: UILabel!
    @IBOutlet weak var YesButton: UIButton!

    var Ch_Count: Int = 0
    var chapterNo: Int = 0

    var bookname: String = ""
    var Chapter: String = ""
    var isDissmiss: Bool = false

    var Quiztxt: String = "Are you interested to play the Quiz?"

    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor

    override func viewDidLoad() {
        super.viewDidLoad()

        App_Protocol.QuizAlertdelegate = self

        BookTxt.text = bookname
        ChapterTxt.text = "Ch \(Chapter)"
        ShowDate.text = Date().string(format: "dd/MM/yyy")
        AskQuiz.text = Quiztxt

        ImageTint.sharedInstance.imageTintcolorMethod(img: self.LogoImage!, colorVu: Themecolor)

        Ch_Count = BibleContent.sharedInstance.AudioBibleListCount(
            selecterBookName: UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
        )
        chapterNo = UserDefaults.standard.integer(forKey: "BookChapter")

        if chapterNo >= Ch_Count {
            ReadButton.isHidden = true
        }

        if NetworkManager.sharedInstance.isConnectedToInternet() {
            if PaymentHistory.sharedInstance.paymentInfo() {
                AdBannerView.isHidden = false
                DispatchQueue.main.async {
                    IronSourceBanner.sharedInstance.ViewControl = self
                    IronSourceBanner.sharedInstance.IronSource_Banner_AdLoad(
                        bannerWidth: Int(ScreenWidth),
                        bannerHeight: Int(self.AdBannerView.frame.height)
                    )
                }
            }
        }
    }

    @IBAction func Read_Action(_ sender: Any) {
        if PaymentHistory.sharedInstance.paymentInfo() && MARK_US_READ {
            AdmobManager.shared.IronSource_Interstitial_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!)
            MARK_US_READ = false
        }

        if self.chapterNo + 1 > self.Ch_Count {
            self.view.makeToast("You've completed this book!", duration: 2.0, position: .center)
            self.navigationController?.popViewController(animated: true)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            App_Protocol.delegateReaderSource?.ReloadFont(ChapterNo: self.chapterNo + 1)
            App_Protocol.delegateReader?.mainContainer()
        }

        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func Yes_Action(_ sender: Any) {
        if PaymentHistory.sharedInstance.paymentInfo() && MARK_US_READ {
            AdmobManager.shared.IronSource_Interstitial_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!)
            MARK_US_READ = false
        }

        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
        vc.ChapterString = UserDefaults.standard.string(forKey: "BookChapter") ?? "0"
        vc.BookString = UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
        vc.ChapterCount = BibleContent.sharedInstance.AudioBibleListCount(
            selecterBookName: UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
        )
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func DismissVc(Close: Bool) {}

    @IBAction func Dismiss_Action(_ sender: Any) {
        if PaymentHistory.sharedInstance.paymentInfo() && MARK_US_READ {
            AdmobManager.shared.IronSource_Interstitial_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!)
            MARK_US_READ = false
        }

        self.navigationController?.popViewController(animated: true)
    }
}
