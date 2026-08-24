//
//  Chapter.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 18/01/23.
//

import UIKit

class Chapter: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var ChapterCollection: UICollectionView!
   
    
    var ChapterCell: ChapterCollectionViewCell?
    var ChapterCount: Int = 0
    
    
    override func draw(_ rect: CGRect) {
        
        self.ChapterCollection.delegate = self
        self.ChapterCollection.dataSource = self
        
        
        self.ChapterCollection.register(UINib(nibName: "ChapterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChapterCollectionViewCell")
        
        self.ChapterCollection.reloadData()
    }
    
    // MARK: - Collection view Delegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 30, height: 30)
      }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return ChapterCount
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            self.ChapterCell = (self.ChapterCollection.dequeueReusableCell(withReuseIdentifier: "ChapterCollectionViewCell", for: indexPath) as! ChapterCollectionViewCell)
            
            self.ChapterCell!.ChapterTxt.text = "\(indexPath.row+1)"
            
            return self.ChapterCell!
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        QuizProtocol.QuizSelectdelegate?.ChapterSelection(Chapter:"\(indexPath.row+1)")
    }
    
    
    
}
