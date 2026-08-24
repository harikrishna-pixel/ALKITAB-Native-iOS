//
//  SplashSliderViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 26/05/23.
//



import UIKit

class SplashSliderViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var WallPaperCollection: UICollectionView!
    @IBOutlet var Pagecontrol: UIPageControl!
    
    @IBOutlet var NextBtn: UIButton!
    @IBOutlet var Skip: UIButton!
    
    
    var SplashCell: SplashSliderCell?
    
    var TitleArray:[String] = ["Explore The Divine \nTruths", "Listen Anywhere, \nAnytime", "Daily Inspirational \nBlessings", "Visualise The God’s \nWord", "Bible Trivia Game!"]
    
    var ContentArray:[String] = ["Let the Bible be your light and \nguide throughout your life", "Enjoy endless high-quality \naudio", "Start your day with the power \nof positivity", "The perfect choice for reflecting \nGod's Word in images", "Discover the joy of learning with our engaging Bible quiz"]
    
    var ColorLists = ["1C46B2", "09C5A2", "CF15B6", "8A9406", "9641C7"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.Pagecontrol.currentPage = 0
        self.Pagecontrol.numberOfPages = ContentArray.count
        
        self.WallPaperCollection.reloadData()
    }
    
    
    // MARK:- Collection view Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: ScreenWidth, height: ScreenHeight)
      }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 5
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            self.SplashCell = (self.WallPaperCollection.dequeueReusableCell(withReuseIdentifier: "SplashSliderCell", for: indexPath) as! SplashSliderCell)
        
            
            self.SplashCell!.CollectionMainWidth.constant = ScreenWidth
            self.SplashCell!.Image1Width.constant = ScreenHeight/2
            self.SplashCell!.Image2Width.constant = ScreenHeight/2.5
            
            
            self.SplashCell!.Image1.image = UIImage(named: "Artboard – \(indexPath.row+8)")
            self.SplashCell!.Image2.image = UIImage(named: "Artboard – \(indexPath.row+1)")

            self.SplashCell!.TitleLbl.text = TitleArray[indexPath.row]
            self.SplashCell!.ContentLbl.text = ContentArray[indexPath.row]
            
            self.SplashCell!.TitleLbl.textColor = hexColorConvert.shared.hexStringToUIColor(hex: ColorLists[indexPath.row])
            self.SplashCell!.ContentLbl.textColor = hexColorConvert.shared.hexStringToUIColor(hex: ColorLists[indexPath.row])
            

            return self.SplashCell!
        }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
        let pageWidth: Float = Float(ScreenWidth+10) // width + space

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
                  
        let SelectedPath = Int((newTargetOffset / pageWidth))
        self.Pagecontrol.currentPage = SelectedPath
        self.ButtonHide()
        
        
       }
    
    
    
    func ButtonHide() {
        if self.Pagecontrol.currentPage == 4 {
            self.NextBtn.setTitle("Finish", for: .normal)
            self.Skip.isHidden = true
        } else {
            self.NextBtn.setTitle("Next", for: .normal)
            self.Skip.isHidden = false
        }
    }
    
    
    @IBAction func Skip_Action(_ sender: Any) {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ReaderViewController") as! ReaderViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func Next_Action(_ sender: Any) {
        if self.Pagecontrol.currentPage == 4 {
            self.NextBtn.setTitle("Finish", for: .normal)
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ReaderViewController") as! ReaderViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            Pagecontrol.currentPage = Pagecontrol.currentPage+1
            let indexPath = IndexPath(row: Pagecontrol.currentPage, section: 0)
            DispatchQueue.main.async {
                self.WallPaperCollection.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
              }
        }
        self.ButtonHide()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
