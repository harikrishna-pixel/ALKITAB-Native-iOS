//
//  QuizAnswersVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 23/02/23.
//

import UIKit
import PDFKit

class QuizAnswersVC: UIViewController {

    var LineCount:CGFloat = 0.0
    @IBOutlet var QuizAnswerCollectionVu: UICollectionView!
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    @IBOutlet weak var DateLbl: UILabel!
    
    @IBOutlet weak var PlayAgain: UIButton!
    @IBOutlet weak var BacktoMenu: UIButton!
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    var AnswerKeyWords:Dictionary<Int,Array<String>> = [:]
    var AnswerAry:[String] = []
    var KeyWords:Dictionary<Int,Array<String>> = [:]
//    var BlankList:[String] = []
    var AttributedArray:[NSAttributedString] = []
    
    var AnswerKeyWordsAry:[String] = []
    var KeyWordsAry:[String] = []
    var ShowResult:String = ""
    
    
    
    var AnswerKeys:Dictionary<Int,Array<String>> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.PlayAgain.backgroundColor = Themecolor
        self.BacktoMenu.backgroundColor = Themecolor
        
        
        
        if ShowResult == "Show" && UserDefaults.standard.array(forKey: "AnswerAry") != nil {
            AnswerAry = UserDefaults.standard.array(forKey: "AnswerAry")  as! [String]
            
//            for i in 0 ..< AnswerAry.count {
//                AnswerKeyWords[i+1] = []
//            }
        }
        
        
        if ShowResult == "Show" && UserDefaults.standard.array(forKey: "KeyWords") != nil {
            self.KeyWordsAry = UserDefaults.standard.array(forKey: "KeyWords")  as! [String]

            for i in 0 ..< KeyWordsAry.count {
                KeyWords[i+1] = KeyWordsAry[i].components(separatedBy: "@@@")
            }
        }
        
        
          
        
        
                
        
        
        
        for i in 0 ..< AnswerAry.count {
            let blank:[String] = KeyWords[i+1]!
            var keysValue:[String] = []
            for item in AnswerAry[i].components(separatedBy: " ") {
                if blank.contains(" \(item) ") {
                    keysValue.append(" \(item) ")
                }
            }
            AnswerKeys[i+1] = keysValue
        }
 
        
        
        
        for i in 0 ..< self.AnswerKeys.count {

            for _ in 0 ..< AnswerKeys[i+1]!.count {
                for _ in 0 ..< KeyWords[i+1]!.count {
                    if AnswerKeyWords[i+1]!.count < KeyWords[i+1]!.count {
                        AnswerKeyWords[i+1]!.append(" ________ ")
                    }
                }
            }
        }
                
            
        
        for i in 0 ..< self.KeyWords.count {
            self.AttributedArray.append(attributedTextBold(withString: self.AnswerAry[i], boldString: self.AnswerAry[i], font: UIFont.systemFont(ofSize: 17, weight: .regular) , BlanksValue: self.AnswerKeyWords[i+1]!, AnswerValue: self.AnswerKeys[i+1]!))
        }
        
        
        
        self.DateLbl.text = UserDefaults.standard.string(forKey: "LastAnsweredDate")
        
//        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func Share_Action(_ sender: Any) {
        let pdfTool = QuizPdf()
            pdfTool.generatePdfFromCollectionView(self.QuizAnswerCollectionVu, filename: "Answer.pdf") { (filePath) in
                
                let fileUrl = URL(string: filePath)
                
                self.loadPDFAndShare(sharedUrl: filePath)
//                self.sharedImage(sharedUrl: fileUrl!)
        }
    }
    
    
    
    
    func loadPDFAndShare(sharedUrl:String) {

            let documento = NSData(contentsOfFile: sharedUrl)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [documento!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView=self.view
            present(activityViewController, animated: true, completion: nil)
        
    }
    
    
    
    
  func createPdf() {
    
        let formatter = UIMarkupTextPrintFormatter(markupText: "asdf")

        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)

        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let printable = page.insetBy(dx: 0, dy: 0)

        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")

        let rect = CGRect.zero
      
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, rect, nil)


        for i in 1...render.numberOfPages {

            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }

        UIGraphicsEndPDFContext();


        // 5. Save PDF file

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        pdfData.write(toFile: "\(documentsPath)/new.pdf", atomically: true)

    }
    
    
    
    
   
    
    
//    func sharedImage(sharedUrl:URL) {
//
//        let activityViewController = UIActivityViewController(activityItems: [sharedUrl], applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
//
//        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
//        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
//
//        self.present(activityViewController, animated: true, completion: nil)
//        activityViewController.completionWithItemsHandler = { activity, success, items, error in
//
//        }
//    }
    
    
    
    @IBAction func Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Back_to_menu(_ sender: Any) {
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func PlayAgain(_ sender: Any) {
        QuizProtocol.QuizMaindelegate?.initQuiz()
        DispatchQueue.main.async {
            
            let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizMainPageVC") as! QuizMainPageVC
            vc.level = UserDefaults.standard.string(forKey: "Qlevel")!
            vc.BookName = UserDefaults.standard.string(forKey: "Qbook")!
            vc.Chapter = Int(UserDefaults.standard.string(forKey: "Qchapter")!)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    

}


func attributedTextBold(withString string: String, boldString: String, font: UIFont, BlanksValue:[String], AnswerValue:[String] ) -> NSAttributedString {
    
  let attributedString = NSMutableAttributedString(string: string)
    
  let FontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
  let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 10.0
     
  let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
    attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
    attributedString.addAttributes(FontAttribute, range: range)
            
        
        for i in 0 ..< AnswerValue.count {
            
           let range1 = (string as NSString).range(of: AnswerValue[i], options: .caseInsensitive)
             attributedString.addAttributes(FontAttribute, range: range1)
        
            
            var ForegroundColor: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: QuizGreen]
            
            
            if BlanksValue.count >= i && BlanksValue.count != 0 {
                
                if AnswerValue[i] != BlanksValue[i] {
                    if BlanksValue[i] == " ________ " {
//                         self.questionShow = self.questionShow.replacingCharacters(in: range, with:" ________ ")
                    }
                    ForegroundColor = [NSAttributedString.Key.foregroundColor: UIColor.red]
                }
            }
        
        let TextBold: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular),]
        
        attributedString.addAttributes(ForegroundColor, range: range1)
        
        attributedString.addAttributes(TextBold, range: range1)
    }
    
    
            
  return attributedString
}


extension QuizAnswersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
      }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AnswerAry.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.QuizAnswerCollectionVu!.dequeueReusableCell(withReuseIdentifier: "QuizAnswersCell", for: indexPath) as! QuizAnswersCell
        
        cell.QuestionNo.text = "Question No: \(indexPath.row+1)"
        cell.AnswerLbl.attributedText = AttributedArray[indexPath.row]
                                      
        cell.AnswerView.ViewShadow(6, color: UIColor.gray)
        return cell
                     
    }
    
}


extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}


extension URL    {
    func checkFileExist() -> Bool {
        let path = self.path
        if (FileManager.default.fileExists(atPath: path))   {
            print("FILE AVAILABLE")
            return true
        }else        {
            print("FILE NOT AVAILABLE")
            return false;
        }
    }
}
