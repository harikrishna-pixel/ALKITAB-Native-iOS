//
//  DailyVereseViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 15/12/22.
//

import UIKit
 
class DailyVereseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DailyVerseDelegate  {

    @IBOutlet weak var BannerVu: UIView!
    
    @IBOutlet var DailyVerseCollectionView : UICollectionView!
    @IBOutlet weak var PageTiTle:UILabel!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    var myView:UIView?
    var SelectedValue:Int?
    var NavigationC:Int = 0
    var PopupMenuView: PopupMenu?
//    var VerseWallpaperVu: VerseWallpaper?
    var notification_data:Array<String> = []
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    
    var path = 0
    var ImagePath:[Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        App_Protocol.delegateDailyVerse = self
        self.reloadDailyVerse()
        
        self.DailyVerseCollectionView.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        self.view.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        
    
//        let Date1 = GetReceptKey.shared.convertData(date: UserDefaults.standard.string(forKey: "TodayDate")!)
//        var diff = Date().interval(ofComponent: .day, fromDate: Date1)
//        diff = diff-1
//        if diff >= 0 {
//            for i in 0..<diff {
//                VerseNotification.sharedInstance.VersCall()
//            }
//            UserDefaults.standard.set(Date().string(format: "dd-MM-yyyy"), forKey: "TodayDate")
//        }
        
        
    }
    
    
    func reloadDailyVerse() {
        
        
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        
        self.DailyVerseCollectionView!.register(UINib(nibName: "DailyVerseCell", bundle: nil), forCellWithReuseIdentifier: "DailyVerseCell")
        
        self.notification_data.removeAll()
        
        
        DispatchQueue.main.async {
            
            self.notification_data = CoreDataModel.sharedInstance.GetAllNotificationData(entity: CDDailyVerses)
            self.notification_data = Array(self.notification_data.reversed())
            
            
            for _ in 0 ..< self.notification_data.count {
                self.path = self.path+1
                if self.path > 10 {
                    self.path = 1
                    self.ImagePath.append(self.path)
                }
                self.ImagePath.append(self.path)
            }
            self.DailyVerseCollectionView.reloadData()
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
      }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.notification_data.count
    }
    
  

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
     let cell = self.DailyVerseCollectionView!.dequeueReusableCell(withReuseIdentifier: "DailyVerseCell", for: indexPath) as! DailyVerseCell
        
        
        let seperateArray = self.notification_data[indexPath.row].components(separatedBy: "_")
        let DateSeperate = seperateArray[1].components(separatedBy: [" ",","])
        
        cell.MenuBtn.tag = indexPath.row
        cell.MenuBtn.addTarget(self, action: #selector(CallMenu), for: .touchUpInside)
        
        
        cell.verse.text = seperateArray[2]
        cell.Book.text = seperateArray[0]
//        cell.Count.text = DateSeperate[1]
        if seperateArray[1] == Date().string(format: "MMM d, yyyy") && indexPath.row == 0 {
            cell.Day.text = "Today"
        } else if indexPath.row > 0 && indexPath.row < 7 {
            cell.Day.text = self.convertDateFormater(seperateArray[1], from: "MMM d, yyyy", to: "EEEE")
        } else {
            cell.Day.text = seperateArray[1]
        }
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            cell.widthConstraint.constant = (ScreenWidth/2)-20
        } else {
            cell.widthConstraint.constant = ScreenWidth-20
        }
        
        
        cell.verse.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: 20)
        cell.Book.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: 15)
        
        cell.verse.text = cell.verse.text!.trimmingCharacters(in: .whitespaces)
        cell.backgroundImage.image = UIImage(named: "S\(ImagePath[indexPath.row]).jpg")
        
        
      return cell
        
    }
 

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.SelectedValue = indexPath.row
}


    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }


@objc func CallMenu(sender: UIButton!) {
    self.SelectedValue = sender.tag
        
        self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(self.myView!)
        self.PopupMenuView = PopupMenu.fromNib(named: "PopupMenu")
        self.PopupMenuView!.getString = self.notification_data[sender.tag]
        self.PopupMenuView!.VCSelection = "DailyVerses"
        self.PopupMenuView!.TagSelection = ""
        self.PopupMenuView!.frame = self.myView!.bounds
        self.PopupMenuView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myView!.addSubview(self.PopupMenuView!)
}
    
    func CloseView(ReadEnable:Bool) {
        if self.myView! != nil {
            self.myView!.removeFromSuperview()
            if ReadEnable {
                navigationController?.popViewController(animated: true)
            }
        }
    }

@objc func RemoveFontView (notification: NSNotification) {
    self.myView?.removeFromSuperview()
}

@objc func NavigateToBible(notification: NSNotification) {
    if NavigationC == 0 {
        NavigationC = NavigationC+1
    ReadBible()
    }
}

func ReadBible() {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "HomeView") as! UINavigationController
         let readBible = self.notification_data[self.SelectedValue!].components(separatedBy: "_")
       UserDefaults.standard.set(readBible[0], forKey: "readdata")
        self.navigationController?.pushViewController(vc, animated: true)
}

//@objc func share (notification: NSNotification) {
//
//    let indexPath = NSIndexPath(row: self.SelectedValue!, section: 0)
//    let multilineCell = self.DailyVerseCollectionView.cellForItem(at: indexPath as IndexPath)  as? DailyVersesCollectionViewCell
//
//    let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SharedViewController") as! SharedViewController
//    vc.VerseStr = multilineCell!.verse.text
//    vc.Bookname = multilineCell!.Book.text
//    vc.modalPresentationStyle = .overCurrentContext
//    vc.modalTransitionStyle = .crossDissolve
//    present(vc, animated: true, completion: nil)
//
//}



func convertDateFormater(_ date: String,from:String,to:String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = from
    let date = dateFormatter.date(from: date)
    dateFormatter.dateFormat = to
    return  dateFormatter.string(from: date!)
}

}



@available(iOS 13.4, *)
extension DailyVereseViewController  {

func AlertVc() {
    let indexPaths = NSIndexPath(row: 0, section: 0)
    let multilineCell = self.DailyVerseCollectionView.cellForItem(at: indexPaths as IndexPath)  as? DailyVersesCollectionViewCell
    
    let alert: UIAlertController
    
    
    if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
        alert = UIAlertController(title: nil, message: nil , preferredStyle: .alert)
    }else {
        alert = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
    }
     
        alert.addAction(UIAlertAction(title: "Copy", style: .default, handler:{ (UIAlertAction)in
            UIPasteboard.general.string = (multilineCell?.verse.text)!
            self.view.makeToast("Copied successfully", duration: 2.0, position: .bottom)
        }))
    
        alert.addAction(UIAlertAction(title: "Share as text", style: .default , handler:{ (UIAlertAction)in
//            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SharedViewController") as! SharedViewController
//            vc.VerseStr = multilineCell!.verse.text!
//            vc.Bookname = multilineCell!.Book.text!
//            vc.modalPresentationStyle = .overCurrentContext
//            vc.modalTransitionStyle = .crossDissolve
//            self.present(vc, animated: true, completion: nil)
            
        }))

        alert.addAction(UIAlertAction(title: "Share as Image", style: .default , handler:{ (UIAlertAction)in
//            self.verseView(VerseStr: (multilineCell?.verse.text)! , Bookname: (multilineCell?.Book.text)!)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Read Full bible", style: .default, handler:{ (UIAlertAction)in
            self.ReadBible()
        }))
    
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
        
        }))
    
        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: {
        })
    
}

//func verseView(VerseStr:String,Bookname:String) {
//
//    self.myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
//    self.view.addSubview(self.myView!)
//    self.VerseWallpaperVu = VerseWallpaper.fromNib(named: "VerseWallpaper")
//    self.VerseWallpaperVu!.VerseStr = VerseStr
//    self.VerseWallpaperVu!.Bookname = Bookname
//    self.VerseWallpaperVu!.Selection = "DailyVerseCollectionView"
//    self.VerseWallpaperVu!.frame = self.myView!.bounds
//    self.VerseWallpaperVu!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//    self.myView!.addSubview(self.VerseWallpaperVu!)
//
//}
}

