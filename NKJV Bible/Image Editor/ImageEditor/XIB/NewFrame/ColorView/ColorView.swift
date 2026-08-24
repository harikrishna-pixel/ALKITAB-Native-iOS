//
//  ColorView.swift
//  ImageEditor
//
//  Created by ajayprasanth on 05/04/23.
//

import UIKit

class ColorView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var ColorCollectionview: UICollectionView!
    var ListSelected: Int = -1
    
    
    var BGColor:[String] = ["ffffff", "ffffff", "000000", "D49854" ,"2BA27E" ,"8D50AF" ,"3C71B7" ,"3CB79E" ,"755112" ,"EF4444" ,"A6B24F" ,"7658CB" ,"1C67B2" ,"1C93B2" ,"1CB293" ,"72C46C", "#8a0e6c", "#052d72", "#05878a", "#163f34", "#dd9933", "#545454", "#a52a2a", "#607057", "#572c5f", "#5b4e77"]
    
    override func draw(_ rect: CGRect) {
        
        self.ColorCollectionview.delegate = self
        self.ColorCollectionview.dataSource = self
        
        self.ColorCollectionview.register(UINib(nibName: "ColorViewCCell", bundle: nil), forCellWithReuseIdentifier: "ColorViewCCell")
        self.ColorCollectionview.reloadData()
        
    }


}


extension ColorView {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      }

    
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          
            return CGSize(width: self.ColorCollectionview.bounds.height-20, height: self.ColorCollectionview.bounds.height-20)
      }
    

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            return BGColor.count
        }

        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = (self.ColorCollectionview.dequeueReusableCell(withReuseIdentifier: "ColorViewCCell", for: indexPath) as! ColorViewCCell)
  
            
            
                
            cell.SelectImg.isHidden = (self.ListSelected == indexPath.row ? false:true)
            
            
            cell.ColorImg.isHidden = (indexPath.row == 0 ? false:true)
            cell.layer.borderColor = UIColor.gray.cgColor
            cell.layer.borderWidth = ((indexPath.row == 0 || indexPath.row == 1) ? 1.0:0.0)
            
            cell.layer.cornerRadius = 8
            cell.backgroundColor = HexColorConvert.shared.hexStringToUIColor(hex: BGColor[indexPath.row])
            
               return cell
            }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            ImageAppProtocol.ImageTxtEditDelegate?.CallColorPicker()
        } else {
            self.ListSelected = indexPath.row
            self.ColorCollectionview.reloadData()
            ImageAppProtocol.ImageTxtEditDelegate?.fontColor_Action(fontColor: HexColorConvert.shared.hexStringToUIColor(hex: BGColor[indexPath.row]))
        }
    }


    
}
