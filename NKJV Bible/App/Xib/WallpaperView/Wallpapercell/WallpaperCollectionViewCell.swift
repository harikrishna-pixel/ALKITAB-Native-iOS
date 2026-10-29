//
//  WallpaperCollectionViewCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 12/02/21.
//

import UIKit

class WallpaperCollectionViewCell: UICollectionViewCell {

    @IBOutlet var Wallpaper: UIImageView!
    @IBOutlet var Versetext: UILabel!
    @IBOutlet var Walpaperframe: UIView!
    @IBOutlet var Booktext: UILabel!
    @IBOutlet var TabTxt: UILabel!
    @IBOutlet var BibleName: UILabel!
    @IBOutlet var WaterMark: UIView!
    @IBOutlet var WaterMarkTxt: UILabel!
    @IBOutlet var WaterMarkVu: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TabTxt.isHidden = true
        TabTxt.text = "Tap on image"
        TabTxt.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        TabTxt.textColor = UIColor.white.withAlphaComponent(0.92)
        TabTxt.textAlignment = .center
        WaterMarkVu.backgroundColor = .clear
        WaterMarkVu.layer.cornerRadius = 0
        WaterMarkVu.clipsToBounds = false
        BibleName.textAlignment = .left
        BibleName.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        BibleName.textColor = .white
        BibleName.alpha = 1
        for case let label as UILabel in WaterMarkVu.subviews where label !== BibleName {
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 8)
            label.textColor = UIColor.white.withAlphaComponent(0.85)
            label.alpha = 1
            label.text = "Search in app store"
        }
        for case let icon as UIImageView in WaterMarkVu.subviews {
            icon.isHidden = false
            icon.image = UIImage(named: "About-logo-white.png")
        }
        applyVerseWatermarkName()
    }

    private var tapHintLink: CADisplayLink?
    private var tapHintStart: CFTimeInterval = 0

    deinit {
        tapHintLink?.invalidate()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopTapHintBlink()
        TabTxt.isHidden = true
        TabTxt.alpha = 1
    }

    func showTapHint(_ show: Bool) {
        TabTxt.layer.removeAllAnimations()
        if !show {
            stopTapHintBlink()
            TabTxt.isHidden = true
            TabTxt.alpha = 1
            return
        }
        TabTxt.isHidden = false
        guard tapHintLink == nil else { return }
        tapHintStart = CACurrentMediaTime()
        TabTxt.alpha = 1
        let link = CADisplayLink(target: self, selector: #selector(stepTapHint))
        link.add(to: .main, forMode: .common)
        tapHintLink = link
    }

    private func stopTapHintBlink() {
        tapHintLink?.invalidate()
        tapHintLink = nil
    }

    /// Fade on a clock. An ad can cancel a UIView animation; this keeps the same fade going.
    @objc private func stepTapHint() {
        guard tapHintLink != nil, !TabTxt.isHidden else { return }
        let wave = (cos((CACurrentMediaTime() - tapHintStart) / 1.4 * 2 * Double.pi) + 1) / 2
        TabTxt.alpha = 0.2 + (0.8 * CGFloat(wave))
    }

    /// Uses the configured app name, including the name loaded after the app config changes.
    func applyVerseWatermarkName() {
        BibleName.text = todaysVerseAppName()
    }
    
    

}
