//
//  QuizResultViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 22/02/23.
//

import UIKit
import CircleProgressView

class QuizResultViewController: UIViewController {
    

    @IBOutlet weak var TitleTxt: UILabel!
    @IBOutlet weak var MsgTxt: UILabel!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    var RawQuestionsList:[String] = []
    var AnswerKeyWords:Dictionary<Int,Array<String>> = [:]
    var KeyWords:Dictionary<Int,Array<String>> = [:]
    var BlankList:[String] = []
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!

    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    
    @IBOutlet weak var correctLbl: UILabel!
    @IBOutlet weak var wrongLbl: UILabel!
    
    
    var Booknname:String = ""
    var Chapter:Int = 0
    
    var Correct:Int = 0
    var OverAllcount:Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        self.circleProgressView.progress = Double(Correct)/10
        self.circleProgressView.trackWidth = 100
        self.circleProgressView.trackFillColor = QuizGreen
        self.circleProgressView.trackBackgroundColor = QuizRed
         
        self.correctLbl.text = "Correct \(Correct)"
        self.wrongLbl.text = "Wrong \(OverAllcount-Correct)"
        
        self.TitleTxt.text = self.resultTxt(correct: Correct).0
        self.MsgTxt.text = self.resultTxt(correct: Correct).1

        
//        self.PieChat.addSubview(progressView)
    }
    
    func finishedProgress(forCircle circle: ProgressView) {
        
    }
    

    func resultTxt(correct:Int) -> (String,String) {
        var Title = ""
        var Msg = ""
        if correct <= 3 {
            Title = "Need Improvement"
            Msg = "better luck next time! Learn and Practise \n \(Booknname) - Chapter: \(Chapter)"
            
        } else if correct == 4 {
            Title = "Try even better"
            Msg = "Are you struggling? Don't be discouraged, Keep learning \n \(Booknname) - Chapter: \(Chapter)"
        } else if correct > 4 && correct <= 6 {
            Title = "Well- played!"
            Msg = "you're right on track, still more go on \n the book\(Booknname) - Chapter: \(Chapter)"
        }
        else if correct >= 7 &&  correct <= 9 {
            Title = "Great job!"
            Msg = "Impressive on \(Booknname) - Chapter: \(Chapter) \n Play if you can beat your own high score"
            
        } else {
            Title = "Excellent!"
            Msg =  "Ace performance! keep it up"
        }
        return (Title,Msg)
    }
    
    
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popToViewController(ofClass: SelectionViewController.self)
//        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func ViewAnswers_Action(_ sender: Any) {
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "QuizAnswersVC") as! QuizAnswersVC
        vc.AnswerAry = RawQuestionsList
        vc.AnswerKeyWords = AnswerKeyWords
        vc.KeyWords = KeyWords
//        vc.BlankList = BlankList
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    @IBAction func Try_Again_Action(_ sender: Any) {
        navigationController?.popToViewController(ofClass: SelectionViewController.self)
    }
    
    @IBAction func Share_Action(_ sender: Any) {
        self.shared(Link: APP_LINK)
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
}
