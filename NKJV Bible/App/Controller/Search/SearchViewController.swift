
//  SearchViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 09/12/22.
//

import UIKit
import IQKeyboardManager

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchDelegate, UIGestureRecognizerDelegate {
    
    

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

    private let searchSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    private var searchDebounceWork: DispatchWorkItem?
    private var searchGeneration = 0
    /// Cached verse corpus for the current testament/book/language filters.
    private var cachedSearchCorpus: [String]?
    private var cachedSearchCorpusKey: String = ""
    private let searchWorkQueue = DispatchQueue(label: "com.alkitab.verseSearch", qos: .userInitiated)
    /// Cap live-typing results so collection layout stays responsive.
    private let liveSearchResultLimit = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()

        App_Protocol.delegateSearch = self
        self.BookHeight.constant = (isIpad ? 40:34)
        self.TestamentHeight.constant = (isIpad ? 40:34)
        
        
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        
        
        let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        
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
        self.SearchTxt.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)

        // Tap results / outside the search field closes the keyboard (Search button still works as before).
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissSearchKeyboard))
        dismissTap.cancelsTouchesInView = false
        dismissTap.delegate = self
        view.addGestureRecognizer(dismissTap)
        
        self.PositionTOBook()
        self.SearchViewCreate()
        self.setupSearchSpinner(theme: Themecolor)
        
    }

    @objc private func dismissSearchKeyboard() {
        guard SearchTxt.isFirstResponder else { return }
        SearchTxt.resignFirstResponder()
    }

    @objc private func searchTextChanged() {
        searchDebounceWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.Search(fromTyping: true)
        }
        searchDebounceWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }

    private func setupSearchSpinner(theme: UIColor) {
        searchSpinner.color = (theme == BGNightMode ? .white : .gray)
        view.addSubview(searchSpinner)
        NSLayoutConstraint.activate([
            searchSpinner.centerXAnchor.constraint(equalTo: SearchListFrame.centerXAnchor),
            searchSpinner.centerYAnchor.constraint(equalTo: SearchListFrame.centerYAnchor)
        ])
    }

    private func setSearchLoading(_ loading: Bool, lockField: Bool) {
        if loading {
            searchSpinner.startAnimating()
            view.bringSubviewToFront(searchSpinner)
        } else {
            searchSpinner.stopAnimating()
        }
        if lockField {
            SearchTxt.isEnabled = !loading
        }
        Book.isUserInteractionEnabled = !loading
        Testament.isUserInteractionEnabled = !loading
    }
    
    

    @objc func doneAction(_ sender : UITextField!) {
        searchDebounceWork?.cancel()
        self.Search(fromTyping: false)
    }
    

    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    func BookListArray() {
        
        let BoolCount = BibleContent.sharedInstance.BookToPosition()
        self.Booklist.removeAll()
        
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
    
    self.invalidateSearchCorpusCache()
    self.Search(fromTyping: false)
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
    
    
    func CollecrtionNibinit(showToast: Bool = true) {
        if showToast, self.SearchTxt.text!.count >= 3 {
            // BUG FIX 7: OLD CODE - Always showed "Results :X" even when X=0 (confusing message)
            // self.view.makeToast(NSLocalizedString("Results :\(self.arraySearchList.count)", comment: ""), duration: 1.0, position: .bottom)
            // Problem: User sees "Results :0" instead of clear "No results found" message
            
            // BUG FIX 7: NEW CODE - Check count and show appropriate message
            if self.arraySearchList.count == 0 {
                self.view.makeToast("No results found", duration: 1.0, position: .top)
            } else {
                self.view.makeToast(NSLocalizedString("Results :\(self.arraySearchList.count)", comment: ""), duration: 1.0, position: .top)
            }
        }
        self.SearchViewCreate()
    }
    
    
    
    func SearchViewCreate(){
        let query = self.SearchTxt.text ?? ""
        let results = (query.isEmpty ? [] : self.arraySearchList)
        if let existing = self.SearchCollectionMVC, existing.superview === self.SearchListFrame {
            existing.updateVerseSearchResults(results, query: query)
            existing.SearchCollectionVu?.keyboardDismissMode = .onDrag
            return
        }
        self.SearchCollectionMVC?.removeFromSuperview()
        self.SearchCollectionMVC = SearchCollectionMainView.fromNib(named: "SearchCollectionMainView")
        self.SearchCollectionMVC!.SearchTxt = results
        self.SearchCollectionMVC!.frame = self.SearchListFrame!.bounds
        self.SearchCollectionMVC!.coreTitle = "search_PH"
        self.SearchCollectionMVC!.Searchstring = query
        self.SearchCollectionMVC!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.SearchCollectionMVC!.SearchCollectionVu?.keyboardDismissMode = .onDrag
        self.SearchListFrame!.addSubview(self.SearchCollectionMVC!)
        self.SearchListFrame!.backgroundColor! = UIColor.clear
    }
    
    
    
    func popupvuew(SelectedVerse:String) {
        SearchTxt.resignFirstResponder()
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

    private func invalidateSearchCorpusCache() {
        cachedSearchCorpus = nil
        cachedSearchCorpusKey = ""
        SearchedList.removeAll(keepingCapacity: false)
    }

    private func currentSearchCorpusKey() -> String {
        let language = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "101"
        let testament = TestamentLbl.text ?? ""
        let book = BookLbl.text ?? ""
        return "\(language)|\(testament)|\(book)"
    }

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
        
        self.BibleBookListSeperated.removeAll(keepingCapacity: true)
        for i in 0 ..< self.BibleBookList.count {
            let seperate_Array = self.BibleBookList[i].components(separatedBy: "-")
            self.BibleBookListSeperated.append(seperate_Array[0])
        }
        invalidateSearchCorpusCache()
    }

    /// Keep the keyboard when the user taps the search field / search bar itself.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touched = touch.view else { return true }
        if touched === SearchTxt || touched.isDescendant(of: SearchTxt) { return false }
        if touched.isDescendant(of: Searchbar) { return false }
        return true
    }
}



@available(iOS 13.4, *)
extension  SearchViewController {

 
    @IBAction func Search_Verse(_ sender: Any) {
        searchDebounceWork?.cancel()
        self.Search(fromTyping: false)
    }
    
    func Search(fromTyping: Bool = false) {
        DispatchQueue.main.async {
            if !fromTyping {
                self.SearchTxt.resignFirstResponder()
            }
            let query = self.SearchTxt.text ?? ""
            if query.count >= 3 {
                self.searchGeneration += 1
                let generation = self.searchGeneration
                self.setSearchLoading(true, lockField: !fromTyping)

                let cacheKey = self.currentSearchCorpusKey()
                let cachedCorpus = (cacheKey == self.cachedSearchCorpusKey) ? self.cachedSearchCorpus : nil
                let resultLimit: Int? = fromTyping ? self.liveSearchResultLimit : nil

                self.searchWorkQueue.async {
                    guard generation == self.searchGeneration else { return }

                    let corpus: [String]
                    if let cachedCorpus = cachedCorpus {
                        corpus = cachedCorpus
                    } else {
                        self.SearchBookText()
                        corpus = self.SearchedList
                    }

                    var matched: [String] = []
                    matched.reserveCapacity(min(resultLimit ?? 256, corpus.count))
                    for item in corpus {
                        let verse = item.components(separatedBy: "_")[0]
                        if verse.localizedCaseInsensitiveContains(query) {
                            matched.append(item)
                        } else if verse.contains(query) {
                            matched.append(item)
                        } else {
                            continue
                        }
                        if let resultLimit = resultLimit, matched.count >= resultLimit {
                            break
                        }
                    }

                    DispatchQueue.main.async {
                        if cachedCorpus == nil, self.currentSearchCorpusKey() == cacheKey {
                            self.cachedSearchCorpus = corpus
                            self.cachedSearchCorpusKey = cacheKey
                            self.SearchedList = corpus
                        }
                        guard generation == self.searchGeneration else { return }
                        self.arraySearchList = matched
                        self.setSearchLoading(false, lockField: !fromTyping)
                        self.CollecrtionNibinit(showToast: !fromTyping)
                    }
                }
            } else if query.count > 0 {
                self.searchGeneration += 1
                self.arraySearchList = []
                if !fromTyping {
                    self.view.makeToast("Incorrect word ", duration: 2.0, position: .top)
                }
                self.CollecrtionNibinit(showToast: !fromTyping)
            } else {
                self.searchGeneration += 1
                self.arraySearchList = []
                self.CollecrtionNibinit(showToast: !fromTyping)
            }
        }
    }
}

