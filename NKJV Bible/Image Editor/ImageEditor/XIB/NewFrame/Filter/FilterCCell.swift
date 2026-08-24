//
//  FilterCCell.swift
//  ImageEditor
//
//  Created by ajayprasanth on 07/04/23.
//

import UIKit

class FilterCCell: UICollectionViewCell {

    @IBOutlet weak var ImageVu: UIImageView!
    @IBOutlet weak var ImageFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var ImageFramewidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    var representedAssetIdentifier: String!
    var thumbnailImage: UIImage! {
        didSet {
            ImageVu.image = thumbnailImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ImageVu.image = nil
    }
    
    
    
    

}
