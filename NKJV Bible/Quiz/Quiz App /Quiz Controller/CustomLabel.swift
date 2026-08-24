//
//  CustomLabel.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 21/06/23.
//

import UIKit

class CustomLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // This will call `awakeFromNib` in your code
        setup()
    }
    
    private func setup() {
        self.textColor = .red
        self.font = UIFont(name: "Chalkboard", size: 16)
        
        
    }
}
