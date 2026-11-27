//
//  ImageCell.swift
//  Smart Bible
//
//  Created by ajayprasanth on 25/07/23.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
//    @IBOutlet weak var ImgHeight:NSLayoutConstraint!
//    @IBOutlet weak var ImgWidth: NSLayoutConstraint!
    
    @IBOutlet weak var VerseLbl:UILabel!
    @IBOutlet weak var VersetitleLbl:UILabel!
    
    @IBOutlet weak var PexelImage: UIImageView!
    
    
    @IBOutlet weak var Share:UIButton!
    @IBOutlet weak var Delete:UIButton!
    @IBOutlet weak var Copy:UIButton!
    @IBOutlet weak var Read:UIButton!
    
    @IBOutlet weak var ShareImg:UIImageView!
    @IBOutlet weak var CopyImg:UIImageView!
    @IBOutlet weak var ReadImg:UIImageView!
    
    
    @IBOutlet weak var ADView:UIView!
    
    @IBOutlet weak var ADViewHeight:NSLayoutConstraint!
    @IBOutlet weak var ADViewWidth: NSLayoutConstraint!
    
    
    
}
