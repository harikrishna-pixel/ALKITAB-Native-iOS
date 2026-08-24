//
//  FilterVC.swift
//  ImageEditor
//
//  Created by ajayprasanth on 28/03/23.
//

import UIKit

class FilterVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


    @IBOutlet var FilterList: UICollectionView!
    
    
    var FilterCC: FilterCCell?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension FilterVC {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 5)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          
            return CGSize(width: (self.FilterList.bounds.height/2)-14, height: (self.FilterList.bounds.height/2)-16)
      }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
                return 10
        }
    
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = (self.FilterList.dequeueReusableCell(withReuseIdentifier: "FilterCC", for: indexPath) as! FilterCCell)
            
                cell.ImageFrameHeight.constant = (self.FilterList.bounds.height/2)-16
                cell.ImageFramewidth.constant = (self.FilterList.bounds.height/2)-14

                cell.ImageVu!.image = UIImage(named: "S1.jpg")
           
            
               return cell
            }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

            
            
        }
    





