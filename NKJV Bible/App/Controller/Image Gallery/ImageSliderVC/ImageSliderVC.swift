//
//  ImageSliderVC.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 17/03/21.
//

import UIKit

class ImageSliderVC: UIViewController, Imageslider {
        
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!

    
    var ImageSliderView: ImageSlideVu?
    
    var myView:UIView?
    var SelectedCell:Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        App_Protocol.Imagesliderdelegate = self
        
        self.SliderViewFrame()
        
    }

    

    func SliderViewFrame() {

        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            self.myView = UIView(frame: CGRect(x: 0, y: 60+StatusbarHeight, width: screenSize.width, height: screenSize.height-200-StatusbarHeight))
        } else {
            self.myView = UIView(frame: CGRect(x: 0, y: 60+StatusbarHeight, width: screenSize.width, height: screenSize.height-60-StatusbarHeight))
        }
        self.view.addSubview(self.myView!)
        self.myView?.backgroundColor = .clear
        self.ImageSliderView = ImageSlideVu.fromNib(named: "ImageSlideVu")
        self.ImageSliderView!.SelectedCell = self.SelectedCell!
        self.ImageSliderView!.ImageVC = self
        self.ImageSliderView!.frame = self.myView!.bounds
        self.ImageSliderView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView!.addSubview(self.ImageSliderView!)
        self.view.bringSubviewToFront(self.BannerVu)
    }

    
    
    
    // MARK: - Back
    @IBAction func Back(_ sender: Any) {
        self.DismissVc()
    }
    
    
    func DismissVc() {
        App_Protocol.IMageReloaddelegate!.LoadImage()
        self.dismiss(animated: true, completion: nil)
    }
    
}
