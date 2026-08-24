//
//  HomeController.swift
//  Smart Bible
//
//  Created by ajayprasanth on 22/07/23.
//

import UIKit
import Photos



class HomeController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HomeVu {

    
    @IBOutlet weak var Quiztxt: UITextView!
    @IBOutlet weak var WallpaperVu:WallpaperList!
    @IBOutlet weak var ImageList:UICollectionView!
    @IBOutlet weak var QuizAnswerCV: UICollectionView!
    
    @IBOutlet weak var LastReadVU: NSLayoutConstraint!
    @IBOutlet weak var QuizVu: UIView!

    
    @IBOutlet weak var Readtitle: UILabel!
    
    @IBOutlet weak var FrameHeight: NSLayoutConstraint!
    @IBOutlet weak var QuizFrameHeight: NSLayoutConstraint!
    
    @IBOutlet weak var BGImage: UIImageView!
    
    @IBOutlet weak var Verertxt: UILabel!
    @IBOutlet weak var Booktxt: UILabel!
    @IBOutlet var VerseImageVu: UIView!
    @IBOutlet var EarnCoinAlertView: UIView!

    
    @IBOutlet var RewardPopup: UIView!
    @IBOutlet weak var ContinuetoreadBtn: ShimmerView!
    @IBOutlet weak var PlayQuizBtn: ShimmerView!
    @IBOutlet weak var ShareApp: ShimmerView!
    @IBOutlet weak var CheckNowBtn: ShimmerView!
    
    
    @IBOutlet weak var LastReadVerse: UILabel!
    @IBOutlet weak var LastReadTitle: UILabel!
    
    
    var WallpaperCc:WallpaperCell!
    var QuizAnswer:QuizAnswerCC!
    var SelectedAnswer:[String] = []
    var SelectedIndex:[Int] = []
    lazy var AudioBibleList:Array<String> = []
    
    
    var Answer:[String] = []
    var Blank:[String] = []
    var Questiontxt:String = ""
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            NotificationList_data.sharedInstance.UpdateDailyVerse()
            let nc = NotificationCenter.default
            nc.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            
            self.BGImage.image = UIImage(named: HomeVerseImage)
        }
    }
    
    
    
    func ChangeVerse() {
        DispatchQueue.main.async {
            let notification_data = DailyVerseLanguageConversion.sharedInstance.DailyVerseLAst().components(separatedBy: "_")
            if notification_data.count >= 3 {
                self.Verertxt.text = notification_data[2]
                self.Booktxt.text = notification_data[0]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.SelectedAnswer = []
        self.SelectedIndex = []
        self.Answer = []
        self.Blank = []
        
        self.ChangeVerse()
        
        
        self.AudioBibleList = BibleContent.sharedInstance.AudioBibleList(selecterBookName: UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName , selectedId: UserDefaults.standard.integer(forKey: "BookChapter")-1)
                
        self.Questiontxt = self.AudioBibleList.randomElement()!
        let Question = quizConvert(Question: &self.Questiontxt)
        self.Quiztxt.text = Question

        
        self.LastReadVerse.text = self.AudioBibleList[0]
        self.LastReadTitle.text = "\(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName) \(UserDefaults.standard.integer(forKey: "BookChapter")):1"
        
        
        self.ContinuetoreadBtn.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        self.PlayQuizBtn.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        self.ShareApp.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        self.CheckNowBtn.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        self.Quiztxt.attributedText = self.attributedTextBold(withString: self.Questiontxt, font: self.Quiztxt.font!, underlineValue: SelectedAnswer)
        self.LastReadVerse.addInterlineSpacing(spacingValue: 6)
        self.QuizAnswerCV.reloadData()
        
        
        self.LastReadVU.constant = CGFloat(LastReadVerse.maxNumberOfLinesHome+129)
        self.QuizVu.transform = CGAffineTransform(translationX: 0 , y: 0)
        
        
        
        if UserDefaults.standard.string(forKey: "AppOpenFirst") ?? "0" == "0" {
            self.ContinuetoreadBtn.setTitle("Read", for: .normal)
            self.Readtitle.text = "Start Reading"
        } else {
            
            self.ContinuetoreadBtn.setTitle("Continue Reading...", for: .normal)
            self.Readtitle.text = "Last Read"
        }
        
        
        self.FrameConstrain()
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.StartAnimation()
        
//        if NetworkManager.sharedInstance.isConnectedToInternet() {
//            self.moreAppScreen()
//        }
        
        DispatchQueue.main.async {
            UserDefaults.standard.set("1", forKey: "AppOpenFirst")
        }
    }
    
    
    
    func StartAnimation() {
        self.ContinuetoreadBtn.startAnimating()
        self.PlayQuizBtn.startAnimating()
        self.ShareApp.startAnimating()
        self.CheckNowBtn.startAnimating()
    }
    
    
    @objc func appMovedToForeground() {
        self.StartAnimation()
    }
    
    
    
    
//    func moreAppScreen() {
//
//        var MoreAppDate = UserDefaults.standard.string(forKey: "MoreAppDate") ?? ""
//
//        if MoreAppDate == "" {
//            UserDefaults.standard.setValue(Date.tomorrow.string(format: "dd-MM-yyyy"), forKey: "MoreAppDate")
//            UserDefaults.standard.setValue(Date.DayThree.string(format: "dd-MM-yyyy"), forKey: "RateUS")
//        } else {
//            let showDate1 = GetReceptKey.shared.convertData(date: MoreAppDate)
//            let diff = showDate1.interval(ofComponent: .day, fromDate: Date())
//
//            if diff < 0 {
//
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.1) {
//                    let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "AdSplashViewController") as! AdSplashViewController
//                    vc.modalPresentationStyle = .overCurrentContext
//                    vc.modalTransitionStyle = .crossDissolve
//                    self.present(vc, animated: true, completion: nil)
//                }
//
//            }
//        }
//    }



    
    

    
    func FrameConstrain() {
        
        self.EarnCoinAlertView.isHidden = (UserDefaults.standard.string(forKey: "ShareReward") ?? "" == Date().string(format: "dd-MM-yyyy"))
        self.FrameHeight.constant = 1220 + CGFloat(LastReadVerse.maxNumberOfLinesHome) + (self.EarnCoinAlertView.isHidden ? 0:50)
        self.QuizFrameHeight.constant = CGFloat(self.Quiztxt.maxNumberOfLinesTxt) + 256
    
    }

    
    
    @IBAction func NavigateToVerse(_ sender: Any) {
        UserDefaults.standard.set(self.Booktxt.text!, forKey: "readdata")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
            App_Protocol.delegateReaderSource?.navigateToSelectedVerse()
        }
    }
    
    
    
    @IBAction func CloseEarnPopup(_ sender: Any) {
        self.RewardPopup.isHidden = true
    }
    
    
    
    @IBAction func ContinueToRead(_ sender: Any) {
        UserDefaults.standard.set(self.LastReadTitle.text!, forKey: "readdata")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
            App_Protocol.delegateReaderSource?.navigateToSelectedVerse()
        }
    }
    
    
    @IBAction func PlayQuiz(_ sender: Any) {
        
        UserDefaults.standard.setValue("Medium", forKey: "Qlevel")
        UserDefaults.standard.setValue(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName, forKey: "Qbook")
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "BookChapter"), forKey: "Qchapter")
        
        
        DispatchQueue.main.async {
            
            UserDefaults.standard.setValue(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName, forKey: "LastSelectedBook")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "BookChapter"), forKey: "LastSelectedChapter")
            
            
            let vc1 = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
            self.navigationController?.pushViewController(vc1, animated: true)
            
            
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizMainPageVC") as! QuizMainPageVC
               vc.level = "Medium"
               vc.BookName = UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
               vc.Chapter = UserDefaults.standard.integer(forKey: "BookChapter")
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
    
    
    @IBAction func ShareLink(_ sender: Any) {
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            self.shared(Link: APP_LINK)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .center)
        }
        
    }


    
    
    func shared(Link:String) {
        let text = "Hi, I found an amazing Reading Bible application with challenging Bible Trivia to improvise biblical knowledge. \n\nTry it now! : \(Link)"
        let textShare = [ text ]
        
        let activityViewController = UIActivityViewController(activityItems: textShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            
            if UserDefaults.standard.string(forKey: "ShareReward") ?? "" != Date().string(format: "dd-MM-yyyy") {
                
                UserDefaults.standard.set(Date().string(format: "dd-MM-yyyy"), forKey: "ShareReward")
            
                self.RewardPopup.isHidden = false
                UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "WalletMoney")+20, forKey: "WalletMoney")
                self.FrameConstrain()
            }
        }
    }
    
    
    @IBAction func CheckCoin_Action(_ sender: Any) {
        self.RewardPopup.isHidden = true
        
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
            vc.ChapterString = UserDefaults.standard.string(forKey: "BookChapter") ?? "0"
            vc.BookString = UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
            vc.ChapterCount = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName)
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    
    @IBAction func Save_Action(_ sender: Any) {
        
        // BUG FIX 1 (DUPLICATE IMAGES): OLD CODE - No protection against multiple taps/calls
        // Problem: Button could be tapped multiple times, or action called multiple times, saving duplicates
        
        // BUG FIX 1 (DUPLICATE IMAGES): NEW CODE - Disable button for 2 seconds
        if let button = sender as? UIButton {
            button.isEnabled = false
            // Re-enable after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                button.isEnabled = true
            }
        }
        
        PHPhotoLibrary.requestAuthorization({ (newStatus) in

                if (newStatus == PHAuthorizationStatus.authorized) {
                    DispatchQueue.main.async {
                        CustomPhotoAlbum.sharedInstance.saveImage(image: self.VerseImageVu.asImage())
                        self.view.makeToast("Image Saved Successfully!", duration: 2.0, position: .center)
                    }
                }

                else {
                    DispatchQueue.main.async {
                        SettingAlert.GallaryPermission(SorceVc: self)
                        
//                        DispatchQueue.main.async {
//                            let alert = UIAlertController(title: "Alert", message: "Please enable permission to access gallery \n Select 'All photo' " , preferredStyle: .alert)
//                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
//                                }))
//                                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler:{ (UIAlertAction)in
//                                    SettingNavigate.sharedInstance.settingsNavigate()
//                                }))
//                            
//                            alert.popoverPresentationController?.sourceView = self.view
//                            self.present(alert, animated: true, completion: {
//                                })
//                        }
                    }
                }
            }) 
    }
    
    
    
    
    @IBAction func Copy_Action(_ sender: Any) {
             UIPasteboard.general.string = "\(Verertxt.text!) \n\n      \(Booktxt.text!) \n\n \(APP_LINK)"
        self.view.makeToast("Copied successfully", duration: 2.0, position: .center)
       }
     
    
    
    @IBAction func Share_Action(_ sender: Any) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = url.appendingPathComponent("\(Booktxt.text!).png")
        try! self.VerseImageVu.asImage().pngData()?.write(to: fileURL)
                    
        self.sharedImage(sharedUrl: fileURL, VerseStr: Verertxt.text!, Bookname: Booktxt.text!)
       }
    
    
    
    @IBAction func Edit_Action(_ sender: Any) {
        
        FileManager.default.clearTmpDirectory()
        
        let vc = kStoryboardImageIphone.instantiateViewController(withIdentifier: "IMageEditingPageVc") as! IMageEditingPageVc
        vc.verseTxt = self.Verertxt.text!
        vc.titceTxt = self.Booktxt.text!
        vc.GetImage = self.BGImage.image
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func DailyVerese_Action(_ sender: Any) {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "DailyVereseViewController") as! DailyVereseViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    private func loadImage(fileURL: URL) -> Data? {
        do {
            let imageData = try Data(contentsOf: fileURL)
            return imageData
        } catch {
        }
        return nil
    }
    
    
    
    
  
    
    func quizConvert(Question:inout String) -> String {
        Question = " \(Question) "
        var sometext = Question.components(separatedBy: " ").filter { $0 != "" }.filter { $0 != " "}

        var ans:[String] = sometext
        
        func validateGenericString(_ string: String) -> Bool {
            return string.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil
        }
        
        ans.shuffle()
        
        var AnswerKewords: [String] = []
        for item in ans {
            
//            if validateGenericString(item) {
                if AnswerKewords.contains(where: {$0.caseInsensitiveCompare(" \(item) ") == .orderedSame}) || AnswerKewords.contains(" \(item) ") {
                    ans.append(" \(item) ")
                } else {
                    AnswerKewords.append(" \(item) ")
                }
//            }
        }
        
    
        for item in ans {
            AnswerKewords = AnswerKewords.filter(){$0 != item}
            AnswerKewords = AnswerKewords.filter(){$0 != item.capitalized}
            AnswerKewords = AnswerKewords.filter(){$0 != item.lowercased()}
        }
          

        self.Blank = []
        self.Answer = []
        for i in 0 ..< 4 {
            if AnswerKewords.count > i {
                Question = Question.replacingOccurrences(of: AnswerKewords[i], with: " ________ ")
                self.Blank.append(AnswerKewords[i])
            }
        }
        
        for item in sometext {
            if Blank.contains(" \(item) ") {
                self.Answer.append(" \(item) ")
            }
        }
    
        
        return Question

    }
    
    
    

}


extension HomeController {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if collectionView == QuizAnswerCV {
//
//            let cellWidth : CGFloat = 150.0
//
////            let numberOfCells = floor(collectionView.frame.size.width / cellWidth)
////            let edgeInsets = (collectionView.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
////
//
//
//            let numberOfCells = floor((UIScreen.main.bounds.size.width-24) / cellWidth)
//            let edgeInsets = ((UIScreen.main.bounds.size.width-24) - (numberOfCells * cellWidth)) / (numberOfCells + 1)
//
//            return UIEdgeInsets(top: 15, left: edgeInsets, bottom: 0, right: edgeInsets)
//
//        } else {
//            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
//
//      }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {

        let cellWidth : CGFloat = 150.0
        
        let totalCellWidth:CGFloat = cellWidth * 4
        let totalSpacingWidth:CGFloat = 30

        let leftInset = ((UIScreen.main.bounds.size.width-24) - (totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    
    
    

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          
          if collectionView == QuizAnswerCV {
              return CGSize(width: 200, height: 36)
          } else {
              return CGSize(width: self.ImageList.frame.height, height: self.ImageList.frame.height)
          }
         
      }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            if collectionView == QuizAnswerCV {
                return self.Blank.count
            } else {
                return 16
            }
            
        }

        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
              
            
            if collectionView == QuizAnswerCV {
                
                self.QuizAnswer = (self.QuizAnswerCV.dequeueReusableCell(withReuseIdentifier: "QuizAnswerCC", for: indexPath) as! QuizAnswerCC)
                self.QuizAnswer.AnswerLbl.text = Blank[indexPath.row]
                self.QuizAnswer.AnswerVu.ViewShadow(5, color: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
                self.QuizAnswer.AnswerLbl.textColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
                
                if SelectedAnswer.contains(Blank[indexPath.row]) {
                    self.QuizAnswer.AnswerVu.backgroundColor = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor).withAlphaComponent(0.5)
                    self.QuizAnswer.AnswerLbl.textColor = UIColor.white
                } else{
                    self.QuizAnswer.AnswerVu.backgroundColor = UIColor.white
                    self.QuizAnswer.AnswerLbl.textColor = UIColor.black
                }
                
                return self.QuizAnswer!
                
            } else {
                
                let cell = (self.ImageList.dequeueReusableCell(withReuseIdentifier: "ImageList", for: indexPath) as! WallpaperCell)
                
                cell.ImgHeight.constant = self.ImageList.frame.height-4
                cell.ImgWidth.constant = self.ImageList.frame.height-4
                cell.ImgVu.image = UIImage(named: "S\(indexPath.row+1).jpg")!.imageWithSize(scaledToSize: CGSize(width: self.ImageList.frame.height-4, height: self.ImageList.frame.height-4))
                
                return cell
            }
            
        }

    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            if collectionView == QuizAnswerCV {
                if SelectedAnswer.count < Blank.count {
                    if  !SelectedAnswer.contains(Blank[indexPath.row]) {
                        SelectedAnswer.append(Blank[indexPath.row])
                        
                        if let range = self.Questiontxt.range(of:" ________ ") {
                            self.Questiontxt = self.Questiontxt.replacingCharacters(in: range, with:Blank[indexPath.row])
                        }
                    }
                    
                    
                }
                self.Quiztxt.attributedText = self.attributedTextBold(withString: self.Questiontxt, font: self.Quiztxt.font!, underlineValue: SelectedAnswer)
                
                self.QuizAnswerCV.reloadData()
            } else {
                self.BGImage.image = UIImage(named: "S\(indexPath.row+1).jpg")
                HomeVerseImage = "S\(indexPath.row+1).jpg"
            }
            
            print("Blank :",Blank.count)
            
        }

    
  
    
    
    
    func attributedTextBold(withString string: String, font: UIFont, underlineValue:[String]) -> NSAttributedString {
        
      let attributedString = NSMutableAttributedString(string: string)
        
      let FontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
      let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10.0
         
      let range = (string as NSString).range(of: string, options: .caseInsensitive)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
        attributedString.addAttributes(FontAttribute, range: range)
        
        
        for i in 0 ..< underlineValue.count {
            
            let range1 = (string as NSString).range(of: underlineValue[i], options: .caseInsensitive)
            attributedString.addAttributes(FontAttribute, range: range1)
            
            let ForegroundColor: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: self.Answer[i] == underlineValue[i] ? UIColor.green:UIColor.red]
            
            attributedString.addAttributes(ForegroundColor, range: range1)
        }
                
      return attributedString
    }
    
    
}






extension UILabel {
    var maxNumberOfLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let text = (self.text ?? "") as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font as Any], context: nil).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight + lineHeight))
    }
}



extension UILabel {
    var maxNumberOfLinesHome: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let text = (self.text ?? "") as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font as Any], context: nil).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight + lineHeight + lineHeight))
    }
}



extension UITextView {
    var maxNumberOfLinesTxt: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let text = (self.text ?? "") as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font as Any], context: nil).height
        let lineHeight = font!.lineHeight
        return Int(ceil(textHeight + lineHeight + lineHeight))
    }
}





extension Array {
    var last: Element {
        return self[self.endIndex - 1]
    }
}
