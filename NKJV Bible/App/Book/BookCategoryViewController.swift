//
//  BookCategoryViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 31/05/24.
//

import UIKit

class BookCategoryViewController: UIViewController {

    @IBOutlet var BookCatagory : UICollectionView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    var BookDictionary: Array<Dictionary<String, AnyObject>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let cellSize = CGSize(width:ScreenWidth , height:40)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 5.0
        layout.minimumInteritemSpacing = 0.0
        self.BookCatagory.setCollectionViewLayout(layout, animated: true)
        
        
        self.ApiCall(Apiid: 4)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func ApiCall(Apiid:Int) {
        let parameters:Dictionary<String, AnyObject> = ["book_app_id": Apiid as AnyObject]
        
        NetworkManager.sharedInstance.ImageFromGallery(urlString: "https://saveigm.com/bookads/admin/api/book/book_cat_list_by_app", params: parameters, completion: {(resultDictionary, error) -> () in

            if let Result:Dictionary<String, AnyObject> = resultDictionary {
                self.BookDictionary = Result["data"] as! Array<Dictionary<String, AnyObject>>
                DispatchQueue.main.async {
                    self.BookCatagory.reloadData()
                }
            }
            })
    }
    
    
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }


}


extension BookCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
             return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
         }


       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return self.BookDictionary.count
       }
       
    
     
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
        let cell = self.BookCatagory!.dequeueReusableCell(withReuseIdentifier: "BookCatagoryCell", for: indexPath) as! BookCatagoryCell
           
           cell.BookCatagoryList.text = self.BookDictionary[indexPath.row]["categoryTitle"] as? String
           
         return cell
       }
    

   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
              
       
   }
    
    
    
    
}
