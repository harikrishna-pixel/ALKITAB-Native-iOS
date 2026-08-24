//
//  Sticker.swift
//  ImageEditor
//
//  Created by ajayprasanth on 13/04/23.
//

import UIKit

class Sticker: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var StickerList: UICollectionView!
    
    
    override func draw(_ rect: CGRect) {
        
        self.StickerList.delegate = self
        self.StickerList.dataSource = self
        
        self.StickerList.register(UINib(nibName: "StickerCell", bundle: nil), forCellWithReuseIdentifier: "StickerCell")
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 5)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          
            return CGSize(width: (self.StickerList.bounds.width/4)-14, height: (self.StickerList.bounds.width/4)-16)
      }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            return 16
        }
    
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = (self.StickerList.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell)
            
                cell.ImageFrameHeight.constant = (self.StickerList.bounds.width/4)-16
                cell.ImageFramewidth.constant = (self.StickerList.bounds.width/4)-14
                cell.ImageVu!.image = UIImage(named: "Sticker-\(indexPath.row+1).png")
            
               return cell
            }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ImageAppProtocol.ImageTxtEditDelegate?.StickerCall(image: UIImage(named: "Sticker-\(indexPath.row+1).png")!)
    }
    
    
    

}
