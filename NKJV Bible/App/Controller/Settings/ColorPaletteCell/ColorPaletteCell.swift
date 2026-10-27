//
//  ColorPaletteCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 17/03/21.
//

import UIKit

class ColorPaletteCell: UICollectionViewCell {
    
    @IBOutlet weak var ColorPaletteView: UIView!
    @IBOutlet weak var SelectedColor: UIView!
    @IBOutlet weak var SelectedColorImage: UIImageView!

    private let defaultBadge = UILabel()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ColorPaletteView.layer.borderColor = UIColor.white.cgColor
        self.ColorPaletteView.layer.borderWidth = 1.0
        self.ColorPaletteView.layer.cornerRadius = 10

        defaultBadge.translatesAutoresizingMaskIntoConstraints = false
        defaultBadge.text = "Default"
        defaultBadge.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        defaultBadge.textColor = UIColor(red: 0.0, green: 72.0 / 255.0, blue: 184.0 / 255.0, alpha: 1.0)
        defaultBadge.backgroundColor = .white
        defaultBadge.textAlignment = .center
        defaultBadge.layer.cornerRadius = 9
        defaultBadge.clipsToBounds = true
        defaultBadge.isHidden = true
        ColorPaletteView.addSubview(defaultBadge)
        NSLayoutConstraint.activate([
            defaultBadge.centerXAnchor.constraint(equalTo: ColorPaletteView.centerXAnchor),
            defaultBadge.bottomAnchor.constraint(equalTo: ColorPaletteView.bottomAnchor, constant: -6),
            defaultBadge.heightAnchor.constraint(equalToConstant: 18),
            defaultBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 58)
        ])
    }

    func showDefaultBadge(_ show: Bool, checkmarkSelected: Bool) {
        defaultBadge.isHidden = !show
        if show {
            ColorPaletteView.bringSubviewToFront(defaultBadge)
        }
        if show && checkmarkSelected {
            SelectedColorImage.transform = CGAffineTransform(translationX: 0, y: -8)
        } else {
            SelectedColorImage.transform = .identity
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        defaultBadge.isHidden = true
        SelectedColorImage.transform = .identity
    }
    
}



