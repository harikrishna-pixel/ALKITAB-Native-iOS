//
//  TextEditVC.swift
//  ImageEditor
//
//  Created by ajayprasanth on 28/03/23.
//

import UIKit

class TextEditVC: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var FontTable: UITableView!
    
    var FontTC: FontTCell?

    
    
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

    
    
    // MARK:- Tableview Delegate

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return Color_Txt.FontList.count
      }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       self.FontTC = (self.FontTable.dequeueReusableCell(withIdentifier: "FontTC") as! FontTCell?)
           self.FontTC!.FontLbl.text = Color_Txt.FontList[indexPath.row]
        self.FontTC!.FontLbl.font = UIFont(name: Color_Txt.FontList[indexPath.row], size: 14)
        
        return self.FontTC!
      }
    

   
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       self.FontTable.deselectRow(at: indexPath, animated: true)
   }
   
    
    
    
}
