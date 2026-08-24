//
//  ColorPaletteVC.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 17/03/21.
//

import UIKit


class ColorPaletteVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIColorPickerViewControllerDelegate {

    
    @IBOutlet var ColorPaletteCollectionView: UICollectionView!
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    var Themecolor:UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    var ColorPaletteCC: ColorPaletteCell?
    var ColorLists: Array<String> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.ColorPaletteCollectionView.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        self.view.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        
        BannerVu.backgroundColor = (self.Themecolor == BGNightMode ? DarkModeColor:self.Themecolor)
        
        let url = Bundle.main.url(forResource: "colors", withExtension: "plist")!
        let Colordata = try! Data(contentsOf: url)
        let ColorDictionary = try! PropertyListSerialization.propertyList(from: Colordata, options: [], format: nil) as! NSDictionary
    
        let ColorPalette = ColorDictionary["colors"] as! Array<AnyObject>
        
        for i in 0 ..< ColorPalette.count {
            let dic = ColorPalette[i] as? Dictionary<String,AnyObject>
            self.ColorLists.append((dic?.stringValueForKey("hash"))!)
        }
        if  !self.ColorLists.contains((UserDefaults.standard.color(forKey: "AppThemeColor")?.toHexString())!) {
            self.ColorLists.append((UserDefaults.standard.color(forKey: "AppThemeColor")?.toHexString())!)
        }
    }
    
    
    // MARK: - Collection view Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.ColorPaletteCollectionView.bounds.width/4)-15, height: (self.ColorPaletteCollectionView.bounds.width/4)-15)
      }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.ColorLists.count
      }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        self.ColorPaletteCC = (self.ColorPaletteCollectionView.dequeueReusableCell(withReuseIdentifier: "ColorPaletteCell", for: indexPath) as! ColorPaletteCell)
        
        self.ColorPaletteCC?.layer.cornerRadius = 10
        
        self.ColorPaletteCC!.ColorPaletteView.backgroundColor = hexColorConvert.shared.hexStringToUIColor(hex: self.ColorLists[indexPath.row]) 
        
        if  UserDefaults.standard.color(forKey: "AppThemeColor")?.toHexString() ==  self.ColorLists[indexPath.row] {
            self.ColorPaletteCC!.SelectedColorImage.isHidden = false
        }  else {
            self.ColorPaletteCC!.SelectedColorImage.isHidden = true
        }
        
      return self.ColorPaletteCC!
     }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let SelectedColor:UIColor = hexColorConvert.shared.hexStringToUIColor(hex: self.ColorLists[indexPath.row])
        
        self.BannerVu.backgroundColor = SelectedColor
        
        if  UserDefaults.standard.color(forKey: "AppThemeColor")?.toHexString() ==  self.ColorLists[indexPath.row] {
            
            self.alertView(selectedColor: SelectedColor,A_Title:"Theme Colour",Msg:"Already Selected")
            
        } else if (self.Themecolor.toHexString() != UIColor.black.toHexString() &&  self.Themecolor.toHexString() != BGNightMode.toHexString()) || self.Themecolor.toHexString() == "#000000" {
            self.alertView(selectedColor: SelectedColor,A_Title:"Theme Colour",Msg:"Are you sure to change the theme colour?")
        } else {
            self.alertView(selectedColor: SelectedColor,A_Title:"Disable night mode?",Msg:"Changing the theme colour will deactivate the night mode")
        }
        
    }
    
    
    
    // MARK: - Back
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Back
    @IBAction func MoreColor(_ sender: Any) {
        if #available(iOS 14.0, *) {
            let picker = UIColorPickerViewController()
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        } else {
            
        }
    }

    
}



// MARK: - Color Picker

extension ColorPaletteVC {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        callAlert(viewController: viewController)
        
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        callAlert(viewController: viewController)
        
        
    }
    
    
    
    func callAlert(viewController: UIColorPickerViewController) {
        if (self.Themecolor.toHexString() != UIColor.black.toHexString() &&  self.Themecolor.toHexString() != BGNightMode.toHexString()) || self.Themecolor.toHexString() == "#000000" {
            self.alertView(selectedColor: viewController.selectedColor,A_Title:"Theme Colour",Msg:"Are you sure to change the theme colour?")
        } else {
            self.alertView(selectedColor: viewController.selectedColor,A_Title:"Disable night mode?",Msg:"Changing the theme colour will deactivate the night mode")
            
        }
    }
}



    
    

@available(iOS 13.4, *)
extension ColorPaletteVC {
    func alertView(selectedColor:UIColor,A_Title:String,Msg:String) {
        let alertController = UIAlertController(title: A_Title, message: Msg, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                UIAlertAction in
            
                if Msg != "Already Selected" {
                    UserDefaults.standard.set(selectedColor.withAlphaComponent(1.0), forKey: "AppThemeColor")
                    UserDefaults.standard.set(selectedColor.withAlphaComponent(1.0), forKey: "SourceThemecolor")
                      self.ColorPaletteCollectionView.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SplashVc") as! SplashVc
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                self.BannerVu.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor")
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
        
    }
}


