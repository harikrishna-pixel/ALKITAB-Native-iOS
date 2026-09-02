//
//  ChapterView.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 23/02/21.
//

import UIKit

@available(iOS 11.0, *)
class ChapterView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var BookName: UILabel!
    @IBOutlet weak var ChapterCollection: UICollectionView!
    @IBOutlet weak var CollectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var WLeftConstrain: NSLayoutConstraint!
    @IBOutlet weak var WRightConstrain: NSLayoutConstraint!
    
    var chaptercount:Int = 0
    var SelectedBook:String = ""
    var ScreenName:String = ""
    var CellHeight:CGFloat = 0.0
    var CellWidth:CGFloat = 0.0
    var MarkedList:[Int] = []
    private var didConfigureCollection = false
    private var lastCollectionWidth: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        configureCollectionIfNeeded()
        updateChapterLayoutIfNeeded()
    }

    private func configureCollectionIfNeeded() {
        guard !didConfigureCollection else { return }
        didConfigureCollection = true

        let markAsReadArray = CoreDataModel.sharedInstance.GetMarkasReadStatus(entity: CDMarkAsRead)
        MarkedList = []
        for item in markAsReadArray {
            if item.components(separatedBy: "-")[0] == self.BookName.text! {
                if let chapter = Int(item.components(separatedBy: "-")[1]) {
                    MarkedList.append(chapter)
                }
            }
        }

        if isIpad {
            self.WLeftConstrain.constant = 120
            self.WRightConstrain.constant = 120
        }

        self.ChapterCollection.delegate = self
        self.ChapterCollection.dataSource = self
        self.ChapterCollection.register(UINib(nibName: "ChapterCell", bundle: nil), forCellWithReuseIdentifier: "ChapterCell")
        self.chaptercount = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: self.BookName.text!)
    }

    private func updateChapterLayoutIfNeeded() {
        let collectionWidth = ChapterCollection.bounds.width
        guard collectionWidth > 0 else { return }
        guard abs(collectionWidth - lastCollectionWidth) > 0.5 else { return }
        lastCollectionWidth = collectionWidth

        self.CellHeight = collectionWidth / 5.5
        self.CellWidth = collectionWidth / 7
        var chapterColumn = Int(self.chaptercount / 7)

        if Float(chapterColumn) < Float(self.chaptercount) / 7 {
            chapterColumn = chapterColumn + 1
        }

        if self.frame.height / 1.5 < ((self.CellHeight + 10) * CGFloat(chapterColumn)) + 80 {
            self.CollectionHeight.constant = self.frame.height / 1.5
        } else {
            self.CollectionHeight.constant = ((self.CellHeight + 10) * CGFloat(chapterColumn) + 80)
        }

        self.ChapterCollection.reloadData()
    }

    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.CellWidth, height: self.CellHeight)
      }
    
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.chaptercount
        }
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = (self.ChapterCollection.dequeueReusableCell(withReuseIdentifier: "ChapterCell", for: indexPath) as! ChapterCell)
            cell.CountTxt.text = String(indexPath.row+1)
             
            
            if cell.CountTxt.text == SelectedBook && self.BookName.text == UserDefaults.standard.string(forKey: "BookName") {
                cell.mainVu.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor")
                cell.CountTxt.textColor = .white
                if (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor).toHexString() == BGNightMode.toHexString() {
                    cell.mainVu.backgroundColor = .black
                }
            } else {
                cell.mainVu.backgroundColor = .white
                cell.CountTxt.textColor = UIColor.gray.withAlphaComponent(0.6)
            }
            if MarkedList.contains(indexPath.row+1) && cell.CountTxt.text != SelectedBook {
                cell.CountTxt.textColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
                cell.mainVu.chapterLayout(color: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
            } else {
                cell.mainVu.chapterLayout(color: UIColor.gray.withAlphaComponent(0.6))
            }
            
            return cell
        }
    
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            self.SelectedBook = String(indexPath.row)
            UserDefaults.standard.set(self.BookName.text!.components(separatedBy: "-")[0], forKey: "BookName")
            
            if ScreenName == "Home" {
                self.CloseAction()
            } else if ScreenName == "Slide" {
                App_Protocol.DelegateSlideCard?.CloseChapterView()
            } else {
                App_Protocol.delegateBook?.SelectView()
            }
            App_Protocol.delegateReader?.mainContainer()
            
            
            
            var row = 0
            if self.chaptercount <= indexPath.row {
                row = self.chaptercount
            } else {
                row = indexPath.row+1
            }
            
            UserDefaults.standard.setValue(row, forKey: "BookChapter")
            
            if ScreenName == "Home" {
                App_Protocol.delegateReader?.VerseSelectionAction(Chapter: row)
            } else if ScreenName == "Slide" {
                App_Protocol.DelegateSlideCard?.VerseSelectionAction(Chapter: row)
            } else {
                App_Protocol.delegateBook?.VerseSelectionAction(Chapter: row)
            }
            
            
        }
    
    
    
    @IBAction func Close(_ sender: Any) {
        self.CloseAction()
    }
    
    
    @IBAction func CloseBG(_ sender: Any) {
        self.CloseAction()
    }
    
    
    func CloseAction() {
         
        if ScreenName == "Home" {
            App_Protocol.delegateReader?.CloseView()
        } else if ScreenName == "Slide" {
            App_Protocol.DelegateSlideCard?.CloseChapterView()
        } else {
            App_Protocol.delegateBook?.CloseView()
        }
    }

}

