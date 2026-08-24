//
//  FontTable.swift
//  ImageEditor
//
//  Created by ajayprasanth on 29/03/23.
//

import UIKit

class FontTable: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var FontCollectionview: UICollectionView!
    
    var ListSelected: Int = -1
    
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.FontCollectionview.delegate = self
        self.FontCollectionview.dataSource = self
        
        self.FontCollectionview.register(UINib(nibName: "FontCCell", bundle: nil), forCellWithReuseIdentifier: "FontCCell")
        self.FontCollectionview.reloadData()
        
    }
    
    
}


extension FontTable {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          
            return CGSize(width: self.FontCollectionview.bounds.height-20, height: self.FontCollectionview.bounds.height-20)
      }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            return Color_Txt.FontList.count
        }

        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = (self.FontCollectionview.dequeueReusableCell(withReuseIdentifier: "FontCCell", for: indexPath) as! FontCCell)
            
            
            cell.fontLbl.font = UIFont(name: Color_Txt.FontList[indexPath.row], size: 18)
            cell.layer.cornerRadius = 8
            cell.layer.borderColor = UIColor.gray.cgColor
            
              
            if self.ListSelected == indexPath.row {
                cell.fontLbl.textColor = UIColor.white
                cell.layer.backgroundColor = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor).cgColor
                cell.layer.borderWidth = 0.0
            } else {
                cell.fontLbl.textColor = UIColor.gray
                cell.layer.backgroundColor = UIColor.white.cgColor
                cell.layer.borderWidth = 1.0
            }
            
                
               return cell
            }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.ListSelected = indexPath.row
        self.FontCollectionview.reloadData()
        ImageAppProtocol.ImageTxtEditDelegate?.Font_Action(fontStyle: Color_Txt.FontList[indexPath.row])
    }


}
