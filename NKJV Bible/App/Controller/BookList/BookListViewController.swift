//
//  BookListViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 09/12/22.
//

import UIKit


class BookListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BookDelegate {
    

    @IBOutlet weak var AudioBookTableView: UITableView!
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    @IBOutlet weak var TestamentSegment: UISegmentedControl!
    
    
    var biblename:Array<String> = []
    
    var AudioBibleName:Array<String> = []
    var MarkAsReadArray:Array<String> = []
    
    var SelectedBook:String?
    var BibleBooks:[String] = []
    var OldTestament:[String] = []
    var NewTestament:[String] = []
    
    var VerseListVc: VerseListView?
    var VerseView:UIView?
    
    
    var myView:UIView?
    var ChapterVc: ChapterView?
    var ChapterNo:String?
    var HideProgressBar:Bool = false
    var getBook:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.AudioBibleName = BibleContent.sharedInstance.BookToPosition()
        
        let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
    
        
        let font = UIFont.systemFont(ofSize: BookCatagorytxtSize)
        self.TestamentSegment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
         
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        
        for item in self.AudioBibleName {
            if item.contains(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName)  { getBook = item }
            
            if OldTestament.count <= 38 {
                OldTestament.append(item)
            } else {
                NewTestament.append(item)
            }
        }
        
        
        
        if self.AudioBibleName.firstIndex(of: getBook)! <= 38 {
            TestamentSegment.selectedSegmentIndex = 0
            BibleBooks = OldTestament
        } else {
            TestamentSegment.selectedSegmentIndex = 1
            BibleBooks = NewTestament
        }
        
        self.ScrollCollectionView(BookIntex: self.BibleBooks.firstIndex(of: getBook)!)
        
        AudioBookTableView.reloadData()
        App_Protocol.delegateBook = self
        // Do any additional setup after loading the view.
    }
    
    
    
    func ScrollCollectionView(BookIntex:Int) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: BookIntex, section: 0)
            self.AudioBookTableView.layoutIfNeeded()
            self.AudioBookTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
         }
    }
    
    
    
    @IBAction func Back(_ sender: Any) {
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    
    
    @IBAction func segmentedControlButtonClickAction(_ sender: UISegmentedControl) {
        
       if sender.selectedSegmentIndex == 0 {
           BibleBooks = OldTestament
       }
       else {
           BibleBooks = NewTestament
       }
        
        AudioBookTableView.reloadData()
    }
    
    
    

    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return self.BibleBooks.count
      }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
      {

          let cell = self.AudioBookTableView.dequeueReusableCell(withIdentifier: "BookTableViewCell") as? BookTableViewCell
          cell!.BookTxt.text = self.BibleBooks[indexPath.row].components(separatedBy: "-")[0]
          cell!.BookCount.text = self.BibleBooks[indexPath.row].components(separatedBy: "-")[1]
          
          
          cell!.BookTxt.textColor = (UserDefaults.standard.string(forKey: "BookName") == cell!.BookTxt.text ? UIColor.white : UIColor.black)
          cell!.BookCount.textColor = (UserDefaults.standard.string(forKey: "BookName") == cell!.BookTxt.text ? UIColor.white : UIColor.black)
          
          cell!.backgroundColor = (UserDefaults.standard.string(forKey: "BookName") == cell!.BookTxt.text ?  UserDefaults.standard.color(forKey: "AppThemeColor") : UIColor.white)
          
          cell!.circleProgressView.isHidden = HideProgressBar
          cell!.circleProgressView.progress = self.readProgress(Book: cell!.BookTxt.text!, total: cell!.BookCount.text!)
          
          cell!.ProgressValue.text = "\(Int(self.readProgress(Book: cell!.BookTxt.text!, total: cell!.BookCount.text!)*100))%"
          
          cell!.circleProgressView.trackFillColor = (UserDefaults.standard.string(forKey: "BookName") == cell!.BookTxt.text ? UIColor.white : UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
          
//          cell!.circleProgressView.roundedCap = (self.readProgress(Book: cell!.BookTxt.text!, total: cell!.BookCount.text!) == 0.0 ? false :true)
          
          cell!.layer.cornerRadius = 5
          
          return cell!
      }

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.SelectedBook = self.BibleBooks[indexPath.row]
        self.AudioBookTableView.reloadData()
        self.chapterView()
}

    
    func CloseView() {
        if self.myView! != nil {
            self.myView!.removeFromSuperview()
        }
    }
    
    
    func CloseChapterView(VerseNo:Int) {
        if self.VerseView! != nil {
            self.VerseView!.removeFromSuperview()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            App_Protocol.DelegateSlideCard?.ChapterVers(Book: "\(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName)-\(UserDefaults.standard.integer(forKey: "BookChapter")):\(VerseNo)")
            
        }
    }
    
    
    func SelectView() {
        if self.myView! != nil {
            self.myView!.removeFromSuperview()
        }
    }
    


    func chapterView() {
        
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.myView!)
        self.ChapterVc = ChapterView.fromNib(named: "ChapterView")
        self.ChapterVc!.frame = self.myView!.bounds
        self.ChapterVc!.BookName.text = self.SelectedBook!.components(separatedBy: "-")[0]
        self.ChapterVc!.SelectedBook = (UserDefaults.standard.string(forKey: "BookChapter") ?? "0")
        self.ChapterVc!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView!.addSubview(self.ChapterVc!)
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
                self.VerseListVc!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.VerseView!.addSubview(self.VerseListVc!)
            }
       }
    
    
    
    func readProgress(Book:String, total:String) -> Double {
        var bookmarked:Double = 0.0
        self.MarkAsReadArray = CoreDataModel.sharedInstance.GetMarkasReadStatus(entity: CDMarkAsRead)
        for item in self.MarkAsReadArray {
            if Book == item.components(separatedBy: "-")[0] {
                bookmarked = bookmarked+1
            }
        }
        if bookmarked == 0 {
            return 0
        } else {
            return (bookmarked/(Double(total)!))
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




