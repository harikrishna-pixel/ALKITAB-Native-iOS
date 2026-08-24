//
//  VerseListView.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 30/03/23.
//

import UIKit

class VerseListView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var BookName: UILabel!
    @IBOutlet weak var ChapterCollection: UICollectionView!
    @IBOutlet weak var CollectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var WLeftConstrain: NSLayoutConstraint!
    @IBOutlet weak var WRightConstrain: NSLayoutConstraint!
    
    lazy var AudioBibleList:Array<String> = []
    
    var chapter:Int = 0
    var SelectedBook:String = ""
    var SelectedBookName:String = ""
    var ScreenName:String = ""
    var CellHeight:CGFloat = 0.0
    var CellWidth:CGFloat = 0.0
    var MarkedList:[Int] = []
    
    var VerseNo:Int = 0
    
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        self.ChapterCollection.delegate = self
        self.ChapterCollection.dataSource = self
        
        self.AudioBibleList = BibleContent.sharedInstance.AudioBibleList(selecterBookName: SelectedBookName , selectedId: chapter-1)
        
        self.ChapterCollection.register(UINib(nibName: "VerseListCell", bundle: nil), forCellWithReuseIdentifier: "VerseListCell")
        self.ChapterCollection.reloadData()
        
        
        
        self.CellHeight = (self.ChapterCollection.frame.width)/5.5
        self.CellWidth = (self.ChapterCollection.frame.width)/7
        var ChapterColumn = Int(self.AudioBibleList.count/7)
        
        if Float(ChapterColumn) < Float(self.AudioBibleList.count)/7 {
            ChapterColumn = ChapterColumn+1
        }
        
        
        
        
        if self.frame.height/1.5 < ((self.CellHeight+10)*CGFloat(ChapterColumn))+80 {
            self.CollectionHeight.constant = self.frame.height/1.5
        } else {
            self.CollectionHeight.constant = ((self.CellHeight+10)*CGFloat(ChapterColumn)+80)
        }
        
        
    }
    
    
    
    func CloseAction() {
        if ScreenName == "Home" {
            App_Protocol.delegateReader?.CloseChapterView()
        } else if ScreenName == "Slide" {
            App_Protocol.DelegateSlideCard?.CloseVerseView()
        } else {
            App_Protocol.delegateBook?.CloseChapterView(VerseNo:VerseNo)
        }
        
    }
    
    
    @IBAction func Close(_ sender: Any) {
        self.CloseAction()
    }
    
    @IBAction func CloseBG(_ sender: Any) {
        self.CloseAction()
    }
    
    
    
    
    // MARK: - Collection view
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.CellWidth, height: self.CellHeight)
      }
    
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.AudioBibleList.count
        }
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = (self.ChapterCollection.dequeueReusableCell(withReuseIdentifier: "VerseListCell", for: indexPath) as! VerseListCell)
            cell.CountTxt.text = String(indexPath.row+1)
             
                cell.mainVu.backgroundColor = .white
                cell.CountTxt.textColor = UIColor.gray.withAlphaComponent(0.6)
            
            if MarkedList.contains(indexPath.row+1) && cell.CountTxt.text != SelectedBook {
                cell.CountTxt.textColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
                cell.mainVu.chapterLayout(color: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
            } else {
                cell.mainVu.chapterLayout(color: UIColor.gray.withAlphaComponent(0.6))
            }
            
            return cell
        }
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            VerseNo = indexPath.row
            if ScreenName == "Slide" {
                App_Protocol.DelegateSlideCard?.ChapterVers(Book: "\(UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName)-\(chapter):\(indexPath.row)")
            } else {
                App_Protocol.delegateReaderSource?.ReloadBibleData(ChapterNo:chapter)
                UserDefaults.standard.set("\(SelectedBookName) \(chapter):\(indexPath.row+1)", forKey: "readdata")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
                    App_Protocol.delegateReaderSource?.navigateToSelectedVerse()
                }
            }
            
            
            self.CloseAction()
        }
    
    
    

}
