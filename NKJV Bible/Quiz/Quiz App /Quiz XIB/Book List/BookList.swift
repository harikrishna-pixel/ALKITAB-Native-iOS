//
//  BookList.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 18/01/23.
//

import UIKit

class BookList: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var BookListCollection: UICollectionView!
   
    
    var BookCell: BookCellCollectionViewCell?
    var AudioBibleName: [String] = []
    
    
    override func draw(_ rect: CGRect) {
        
        self.BookListCollection.delegate = self
        self.BookListCollection.dataSource = self
        
        
        self.AudioBibleName = BibleContent.sharedInstance.BookToPosition()
        
        
        self.BookListCollection.register(UINib(nibName: "BookCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BookCellCollectionViewCell")
        
        self.BookListCollection.reloadData()
    }
    
    
    // MARK: - Collection view Delegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 100, height: 30)
      }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.AudioBibleName.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            self.BookCell = (self.BookListCollection.dequeueReusableCell(withReuseIdentifier: "BookCellCollectionViewCell", for: indexPath) as! BookCellCollectionViewCell)
            
            self.BookCell!.BookTxt.text = self.AudioBibleName[indexPath.row].components(separatedBy: "-")[0]
            
            return self.BookCell!
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        QuizProtocol.QuizSelectdelegate?.Selection(BookCount: self.AudioBibleName[indexPath.row])
    }
    

}
