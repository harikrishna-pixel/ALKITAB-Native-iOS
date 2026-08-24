//
//  SearchViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 09/12/22.
//

import UIKit
import IQKeyboardManager

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,SearchDelegate {
    
    

    @IBOutlet weak var SearchView: UIView!
    @IBOutlet weak var Searchbar: UIView!
    @IBOutlet weak var SearchListFrame: UIView!
    @IBOutlet weak var Testament: UIView!
    @IBOutlet weak var Book: UIView!
    @IBOutlet weak var BannerVu: UIView!
    
    @IBOutlet weak var SearchTxt: UITextField!
    
    @IBOutlet weak var BookTable: UITableView!
    @IBOutlet weak var TestamentTable: UITableView!
    
    @IBOutlet weak var BookLbl:UILabel!
    @IBOutlet weak var TestamentLbl:UILabel!
    
    
    
    @IBOutlet weak var BookDownArrow:UIImageView!
    @IBOutlet weak var TestDownArrow:UIImageView!
    
    
    
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var BookHeight: NSLayoutConstraint!
    @IBOutlet weak var TestamentHeight: NSLayoutConstraint!
    
    var Bibledata:Data?
    var BibleDictionary:Dictionary<String,Array<String>> = [:]
    var BibleList: Array<String>?
    var SearchedList: Array<String> = []
    var BibleBookListSeperated:Array<String> = []
    var BibleBookList:Array<String> = []
    var arraySearchList:Array<String> = []
    
    
    weak var SearchCollectionMVC: SearchCollectionMainView?
    weak var PopupMenuView: PopupMenu?
    var myView:UIView?
    
    
    var selectedTestamant:Int = 2
    var selectedBook:Int = 0
    
    
    var Booklist:Array<String> = []
    var TestamentList:Array<String> = ["OT","NT","Full Bible"]
    var testamentSelect:String = "Full Bibke"
    var OldSelect:String = ""
    
    var BookCell:BookTableCell?
    var TestamentCell:TestamentTableCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        App_Protocol.delegateSearch = self
        self.BookHeight.constant = (isIpad ? 40:34)
        self.TestamentHeight.constant = (isIpad ? 40:34)
        
        
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        
        
        let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
        self.Booklist.append("All Chapter")
        
        self.BookLbl.textColor = Themecolor
        self.TestamentLbl.textColor = Themecolor
        
        SearchView.ViewShadow((isIpad ? 27:22), color: .black)
        self.Searchbar.roundCorners(corners: [.topRight, .bottomRight ], radius: (isIpad ? 27:23))
        
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        self.Searchbar.backgroundColor = Themecolor
        self.view.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        
        Testament.ViewShadow((isIpad ? 20:17), color: .black)
        Book.ViewShadow((isIpad ? 20:17), color: .black)

        self.BookListArray()
        
        self.BookTable.reloadData()
        self.TestamentTable.reloadData()
        
        
        
        let config = IQBarButtonItemConfiguration(title: "Search", action: #selector(self.doneAction(_:)))
        self.SearchTxt.addKeyboardToolbar(withTarget: self, titleText: nil , rightBarButtonConfiguration: config, previousBarButtonConfiguration: nil, nextBarButtonConfiguration: nil)
        
        
        self.PositionTOBook()
        self.SearchViewCreate()
        
    }
    
    

    @objc func doneAction(_ sender : UITextField!) {
        self.Search()
    }
    

    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    func BookListArray() {
        
        let BoolCount = BibleContent.sharedInstance.BookToPosition()
        self.Booklist.removeAll()
        self.Booklist.append("All Chapter")
        
        if self.TestamentLbl.text! == "OT" {
            for i in 0 ..< 39 {
                self.Booklist.append(BibleContent.sharedInstance.BookToPosition()[i].components(separatedBy: "-")[0])
            }
            
        } else if self.TestamentLbl.text! == "NT" {
            for i in 39 ..< BoolCount.count {
                self.Booklist.append(BibleContent.sharedInstance.BookToPosition()[i].components(separatedBy: "-")[0])
            }
            
        } else {
            for i in 0 ..< BoolCount.count {
                self.Booklist.append(BibleContent.sharedInstance.BookToPosition()[i].components(separatedBy: "-")[0])
            }
        }
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if tableView == self.BookTable {
              return self.Booklist.count
          } else {
              return self.TestamentList.count
          }
          
      }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
      {
          
          if tableView == self.BookTable {
              
              let cell = self.BookTable.dequeueReusableCell(withIdentifier: "BookTableCell") as? BookTableCell
                 cell?.BookLbl.text = self.Booklist[indexPath.row]
              
              
              return cell!
              
          } else {
              
              let cell = self.TestamentTable.dequeueReusableCell(withIdentifier: "TestamentTableCell") as? TestamentTableCell
                cell?.TestamentLbl.text = self.TestamentList[indexPath.row]
              return cell!
              
          }

          
          
//          cell!.BookTxt.text = self.BibleBooks[indexPath.row].components(separatedBy: "-")[0]
//          cell!.BookCount.text = self.BibleBooks[indexPath.row].components(separatedBy: "-")[1]
              
          
//          cell!.BookTxt.textColor = (UserDefaults.standard.string(forKey: "BookName") == cell!.BookTxt.text ? UIColor.white : UIColor.black)
//          cell!.BookCount.textColor = (UserDefaults.standard.string(forKey: "BookName") == cell!.BookTxt.text ? UIColor.white : UIColor.black)
//
//          cell!.backgroundColor = (UserDefaults.standard.string(forKey: "BookName") == cell!.BookTxt.text ?  UserDefaults.standard.color(forKey: "AppThemeColor") : UIColor.white)
//
//          cell!.layer.cornerRadius = 5
          
          
      }
    
    
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if tableView == self.BookTable {
        self.BookLbl.text = self.Booklist[indexPath.row]
    } else {
        self.TestamentLbl.text = self.TestamentList[indexPath.row]
        self.BookLbl.text = "All Chapter"
        self.BookListArray()
        self.BookTable.reloadData()
    }
    tableView.deselectRow(at: indexPath, animated: true)
    
    self.Search()
    BookHeight.constant = (isIpad ? 40:34)
    TestamentHeight.constant = (isIpad ? 40:34)
}

    
    @IBAction func BookSelectionAction(_ sender: Any) {
        
        self.BookDownArrow.transform = CGAffineTransform(rotationAngle: BookHeight.constant == 260 ? 0:.pi)
        
        BookHeight.constant = (BookHeight.constant == 260 ? (isIpad ? 40:34):260)
        TestamentHeight.constant = (isIpad ? 40:34)
        
        self.TestDownArrow.transform = CGAffineTransform(rotationAngle: 0)
        
    }
    
    
    @IBAction func TestamentSelectionAction(_ sender: Any) {

        self.TestDownArrow.transform = CGAffineTransform(rotationAngle: TestamentHeight.constant == 150 ? 0:.pi)
        
        BookHeight.constant = (isIpad ? 40:34)
        TestamentHeight.constant = (TestamentHeight.constant == 150 ? (isIpad ? 40:34):150)
        
        self.BookDownArrow.transform = CGAffineTransform(rotationAngle: 0)
    }
    
    
    func CollecrtionNibinit() {
        if self.SearchTxt.text!.count >= 3 {
            // BUG FIX 7: OLD CODE - Always showed "Results :X" even when X=0 (confusing message)
            // self.view.makeToast(NSLocalizedString("Results :\(self.arraySearchList.count)", comment: ""), duration: 1.0, position: .bottom)
            // Problem: User sees "Results :0" instead of clear "No results found" message
            
            // BUG FIX 7: NEW CODE - Check count and show appropriate message
            if self.arraySearchList.count == 0 {
                self.view.makeToast("No results found", duration: 1.0, position: .bottom)
            } else {
                self.view.makeToast(NSLocalizedString("Results :\(self.arraySearchList.count)", comment: ""), duration: 1.0, position: .bottom)
            }
        }
        self.SearchViewCreate()
    }
    
    
    
    func SearchViewCreate(){
        self.SearchCollectionMVC = SearchCollectionMainView.fromNib(named: "SearchCollectionMainView")
        if self.SearchTxt.text! == "" {
            self.SearchCollectionMVC!.SearchTxt = []
        } else {
            self.SearchCollectionMVC!.SearchTxt = self.arraySearchList
        }
        self.SearchCollectionMVC!.frame = self.SearchListFrame!.bounds
        self.SearchCollectionMVC!.coreTitle = "search_PH"
        self.SearchCollectionMVC!.Searchstring = self.SearchTxt.text!
        self.SearchCollectionMVC!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.SearchListFrame!.addSubview(self.SearchCollectionMVC!)
        self.SearchListFrame!.backgroundColor! = UIColor.clear
    }
    
    
    
    func popupvuew(SelectedVerse:String) {
        
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.myView!)
        self.PopupMenuView = PopupMenu.fromNib(named: "PopupMenu")
        self.PopupMenuView!.getString = SelectedVerse
        self.PopupMenuView!.frame = self.myView!.bounds
        self.PopupMenuView!.VCSelection = "SearchViewController"
        self.PopupMenuView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView!.addSubview(self.PopupMenuView!)
        
    }
    
    
    
    func navigateMainClass() {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ReaderViewController") as! ReaderViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func CloseView() {
        if self.myView != nil {
            self.myView?.removeFromSuperview()
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





// MARK:- INIT Search
@available(iOS 13.4, *)
extension  SearchViewController {

    func SearchBookText()  {
        
        guard
            let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/101/audio.plist")
            else { fatalError("Unable to get file") }
        
        let BoolCount = BibleContent.sharedInstance.BookToPosition()
        
        self.Bibledata = try! Data(contentsOf: fileURL)
        self.BibleDictionary = try! PropertyListSerialization.propertyList(from: self.Bibledata!, options: [], format: nil) as! Dictionary<String,Array<String>>
        
        self.SearchedList.removeAll()
        
        if self.TestamentLbl.text == "OT" && self.BookLbl.text == "All Chapter" {
            for i in 0 ..< 39 {
                let AudioBiblestring = self.BibleDictionary[String(i+1)]! as Array<String>
                for j in 0 ..< AudioBiblestring.count {
                    var audio1 = AudioBiblestring[j]
                      audio1 = audio1.withoutHtmlTags()
                    self.BibleList = audio1.components(separatedBy: "@@@@")
                    for k in 0 ..< self.BibleList!.count {
                        let appendvalue = String(format: "%@_%@ %i-%i",self.BibleList![k],self.BibleBookListSeperated[i],j+1,k+1)
                        self.SearchedList.append(appendvalue)
                    }
                }
            }
        } else if self.TestamentLbl.text == "NT" && self.BookLbl.text == "All Chapter" {
            for i in 39 ..< BoolCount.count {
                let AudioBiblestring = self.BibleDictionary[String(i+1)]! as Array<String>
                for j in 0 ..< AudioBiblestring.count {
                    var audio1 = AudioBiblestring[j]
                      audio1 = audio1.withoutHtmlTags()
                    self.BibleList = audio1.components(separatedBy: "@@@@")
                    for k in 0 ..< self.BibleList!.count {
                        let appendvalue = String(format: "%@_%@ %i-%i",self.BibleList![k],self.BibleBookListSeperated[i],j+1,k+1)
                        self.SearchedList.append(appendvalue)
                    }
                }
            }
        } else if self.TestamentLbl.text == "Full Bible" && self.BookLbl.text == "All Chapter" {
            for i in 0 ..< BoolCount.count {
                let AudioBiblestring = self.BibleDictionary[String(i+1)]! as Array<String>
                for j in 0 ..< AudioBiblestring.count {
                    var audio1 = AudioBiblestring[j]
                        audio1 = audio1.withoutHtmlTags()
                    self.BibleList = audio1.components(separatedBy: "@@@@")
                    for k in 0 ..< self.BibleList!.count {
                        let appendvalue = String(format: "%@_%@ %i-%i",self.BibleList![k],self.BibleBookListSeperated[i],j+1,k+1)
                        self.SearchedList.append(appendvalue)
                    }
                }
            }
        } else {
            let BoolPOsition = BibleContent.sharedInstance.BookToPosition(stringBook: self.BookLbl.text!)
                let AudioBiblestring = self.BibleDictionary[String(BoolPOsition+1)]! as Array<String>
                for j in 0 ..< AudioBiblestring.count {
                    var audio1 = AudioBiblestring[j]
                        audio1 = audio1.withoutHtmlTags()
                    self.BibleList = audio1.components(separatedBy: "@@@@")
                    for k in 0 ..< self.BibleList!.count {
                        let appendvalue = String(format: "%@_%@ %i-%i",self.BibleList![k],self.BibleBookListSeperated[BoolPOsition],j+1,k+1)
                        self.SearchedList.append(appendvalue)
                }
            }
        }
    }
    
    
    
    // MARK: - Full chapter Property list
    
    // Get all Bible Book name from Full chapter Property list
    func PositionTOBook() {
        let filename = "fullchapters.plist"
        let foldername:String = UserDefaults.standard.string(forKey: "SelectedLanguage")!
        
        guard
            let fileURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("/\(foldername)/\(filename)")
            else { fatalError("Unable to get file") }
    
        self.Bibledata = try! Data(contentsOf: fileURL)
        self.BibleBookList = try! PropertyListSerialization.propertyList(from: self.Bibledata!, options: [], format: nil) as! Array<String>
        
        for i in 0 ..< self.BibleBookList.count {
            let seperate_Array = self.BibleBookList[i].components(separatedBy: "-")
            self.BibleBookListSeperated.append(seperate_Array[0])
        }
    }
}



@available(iOS 13.4, *)
extension  SearchViewController {

 
    @IBAction func Search_Verse(_ sender: Any) {
        self.Search()
    }
    
    func Search() {
        DispatchQueue.main.async {
            self.SearchTxt.resignFirstResponder()
            self.SearchCollectionMVC?.removeFromSuperview()
            if self.SearchTxt.text!.count >= 3 {
                self.arraySearchList.removeAll()
                self.SearchBookText()
                for i in 0 ..< self.SearchedList.count {
                    let verse = self.SearchedList[i].components(separatedBy: "_")[0]
                    let searchstr = self.SearchTxt.text!
                    if verse.localizedCaseInsensitiveContains(searchstr) {
                    self.arraySearchList.append(self.SearchedList[i])
                    } else if verse.contains(searchstr) {
                        self.arraySearchList.append(verse)
                    }
                }
            } else if self.SearchTxt.text!.count > 0  {
                self.view.makeToast("Incorrect word ", duration: 2.0, position: .bottom)
            }
            self.CollecrtionNibinit()
        }
    }
}

