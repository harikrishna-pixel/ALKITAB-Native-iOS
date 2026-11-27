//
//  ImageOpenCollectionViewCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 19/06/24.
//

import UIKit

class ImageOpenCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var ImgFrame: UIView!
    @IBOutlet weak var Img: UIImageView!
    @IBOutlet weak var BottomMenu:UIView!
    
    
//    @IBOutlet weak var ShareVu: UIView!
    @IBOutlet weak var ADView: UIView!
    
    
    @IBOutlet weak var DownloadImg: UIButton!
    @IBOutlet weak var ShareImg: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
     
}
