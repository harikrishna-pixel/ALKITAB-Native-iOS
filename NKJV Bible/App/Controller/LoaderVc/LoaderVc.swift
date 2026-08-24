//
//  LoaderVc.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 24/05/21.
//

import UIKit

class LoaderVc: UIViewController {
    @IBOutlet var ActiveIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ActiveIndicator.startAnimating()
        // Do any additional setup after loading the view.
    }

}
