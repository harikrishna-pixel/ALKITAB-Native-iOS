//
//  Filter.swift
//  ImageEditor
//
//  Created by ajayprasanth on 07/04/23.
//

import UIKit

class Filter: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet var FilterList: UICollectionView!
    var FilterCC: FilterCCell?
    var ImageFVar = ImageFilterVar()
    var Bgimage:UIImage?
    var ciimage: CIImage?
    
    override func draw(_ rect: CGRect) {
        ciimage = CIImage(data: Bgimage!.pngData()!)
        
        self.FilterList.delegate = self
        self.FilterList.dataSource = self
        
        self.FilterList.register(UINib(nibName: "FilterCCell", bundle: nil), forCellWithReuseIdentifier: "FilterCCell")
        
        self.ImageFVar.thumbnailImage = ciimage
        
        self.setCollectionview()
        self.FilterList.reloadData()
        
    }
    
    
    func setCollectionview(){
        self.ImageFVar.thumbnailImages = ImageFVar.filters.map({ (name, applier) -> UIImage in
            if applier == nil {
                return UIImage(ciImage: ciimage!)
            }
            let uiImage = self.ImageFVar.applyFilter(
                applier: applier,
                ciImage: self.ImageFVar.thumbnailImage)
            return uiImage
        })
    }
    
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          
            return CGSize(width: (self.FilterList.bounds.height), height: (self.FilterList.bounds.height))
      }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            return self.ImageFVar.thumbnailImages.count
        }
    
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = (self.FilterList.dequeueReusableCell(withReuseIdentifier: "FilterCCell", for: indexPath) as! FilterCCell)
            
                cell.ImageFrameHeight.constant = (self.FilterList.bounds.height)
                cell.ImageFramewidth.constant = (self.FilterList.bounds.height)
                cell.ImageVu!.image = self.ImageFVar.thumbnailImages[indexPath.item] //UIImage(named: "S1.jpg")

               return cell
            }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ImageAppProtocol.ImageTxtEditDelegate?.ImageChange_Action(Image: self.ImageFVar.thumbnailImages[indexPath.item])
    }
    
    

    
    
    
}
