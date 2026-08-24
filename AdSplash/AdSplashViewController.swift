//
//  AdSplashViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 14/08/23.
//

import UIKit

class AdSplashViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var Pagecontrol: UIPageControl!
    @IBOutlet var WallPaperCollection: UICollectionView!
    var AdCell: AdSplashFileCell?
        
    
    var SelectedPath: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DownloadAndLoad.shared.loadImageFromDiskWith()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.Pagecontrol.currentPage = 0
        self.Pagecontrol.numberOfPages = MORE_LINKS.count
    
        UserDefaults.standard.setValue(Date.OneWeek.string(format: "dd-MM-yyyy"), forKey: "MoreAppDate")
        self.WallPaperCollection.reloadData()
    }
    
    
    // MARK:- Collection view Delegate

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          return CGSize(width: ScreenWidth, height: ScreenHeight)
      }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 3
        }
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            self.AdCell = (self.WallPaperCollection.dequeueReusableCell(withReuseIdentifier: "AdSplashFileCell", for: indexPath) as! AdSplashFileCell)
            
            self.AdCell?.SplashImg.image = UIImage(named: "more\(self.SelectedPath+1).png")
            self.AdCell?.ImgWidth.constant = self.view.frame.width
            self.AdCell?.ImgHeight.constant = self.view.frame.height
            self.AdCell?.ADvu.transform = CGAffineTransform(rotationAngle: -.pi / 4)
            
            print("More app : more\(self.SelectedPath+1).png")

            return self.AdCell!
        }
    
    
    
    @IBAction func Download_Link(_ sender: Any) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
                   if let url = URL(string: MORE_LINKS[self.SelectedPath]), UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url, options: [:]) { success in
                           print(success ? "URL was opened successfully." : "Failed to open URL.")
                       }
                   } else {
                       self.view.makeToast("Invalid URL or cannot open.", duration: 2.0, position: .bottom)
                   }
                   
               } else {
                   self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
               }
        
        
      }

    
    
    
    
    @IBAction func Close_Link(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
        
    
    @IBAction func Front_Link(_ sender: Any) {
        if self.SelectedPath < 2 {
            self.SelectedPath = self.SelectedPath+1
            self.Pagecontrol.currentPage = self.SelectedPath
            let indexPath = IndexPath(item: self.SelectedPath, section: 0)
                self.WallPaperCollection.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        }
    }
    
    
    @IBAction func Back_Link(_ sender: Any) {
        if self.SelectedPath > 0 {
            self.SelectedPath = self.SelectedPath-1
            self.Pagecontrol.currentPage = self.SelectedPath
            let indexPath = IndexPath(item: self.SelectedPath, section: 0)
                self.WallPaperCollection.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        }
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
        let pageWidth: Float = Float(ScreenWidth) // width + space

        let currentOffset = CGFloat(scrollView.contentOffset.x)
        let targetOffset = targetContentOffset.pointee.x
        var newTargetOffset: Float = 0
         
        if targetOffset > currentOffset-(ScreenWidth/3) {
            newTargetOffset = ceilf(Float(currentOffset) / pageWidth) * pageWidth
        } else {
            newTargetOffset = floorf(Float(currentOffset) / pageWidth) * pageWidth
        }
        
        if newTargetOffset < 0 {
            newTargetOffset = 0
        } else if CGFloat(newTargetOffset) > scrollView.contentSize.width {
            newTargetOffset = Float(scrollView.contentSize.width)
        }

        targetContentOffset.pointee.x = currentOffset
        scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: 0), animated: true)
                  
        self.SelectedPath = Int((newTargetOffset / pageWidth))
        self.Pagecontrol.currentPage = self.SelectedPath
        
        self.SelectedPath = (self.SelectedPath == 3 ? 2:self.SelectedPath)
         
        let indexPath = IndexPath(item: self.SelectedPath, section: 0)
        self.WallPaperCollection.reloadItems(at: [indexPath])
        
       }
    
    
}


