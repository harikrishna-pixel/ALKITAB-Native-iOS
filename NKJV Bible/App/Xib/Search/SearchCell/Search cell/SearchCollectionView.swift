//
//  SearchCollectionView.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 13/02/21.
//

import UIKit

class SearchCollectionView: UICollectionViewCell {

    
    @IBOutlet var VerseLbl: UILabel!
    @IBOutlet var MenuBtn: UIButton!
    @IBOutlet var VerseTitle: UILabel!
    @IBOutlet var menuImage: UIImageView!
    
    @IBOutlet var DottedLines: UIView!
//    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // XIB pins MenuBtn to the full cell — shrink hit area to the ⋯ icon only
        // so tapping the verse text does not open the bottom popup.
        pinMenuButtonToIcon()
    }

    private func pinMenuButtonToIcon() {
        contentView.constraints
            .filter { ($0.firstItem as? UIView) == MenuBtn || ($0.secondItem as? UIView) == MenuBtn }
            .forEach { $0.isActive = false }
        MenuBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            MenuBtn.centerXAnchor.constraint(equalTo: menuImage.centerXAnchor),
            MenuBtn.centerYAnchor.constraint(equalTo: menuImage.centerYAnchor),
            MenuBtn.widthAnchor.constraint(equalToConstant: 44),
            MenuBtn.heightAnchor.constraint(equalToConstant: 44)
        ])
        contentView.bringSubviewToFront(MenuBtn)
    }
    
    
  
    
}

