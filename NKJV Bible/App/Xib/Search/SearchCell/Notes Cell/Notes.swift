//
//  Notes.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 17/02/21.
//

import UIKit

class Notes: UICollectionViewCell {
    
    
    @IBOutlet var VerseLbl: UILabel!
    @IBOutlet var MenuBtn: UIButton!
    @IBOutlet var VerseTitle: UILabel!
    @IBOutlet var NoteLbl: UILabel!
    @IBOutlet var NoteTitle: UILabel!
    @IBOutlet var menuImage: UIImageView!
    @IBOutlet var DottedLines: UIView!
    @IBOutlet weak var Noteheight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    
    
}
