//
//  DropDown.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 17/02/21.
//

import UIKit

class DropDown: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var TestamentTable: UITableView!
    @IBOutlet var BookTable: UITableView!
    
    
    @IBOutlet weak var OTViewFrame: UIView!
    @IBOutlet weak var BookViewFrame: UIView!
        
    var Style:String?
    var DropDownCl: DropDownCell?
    var Booklist:Array<String> = []
    var testamentSelect:String = ""
    var OldSelect:String = ""
    
    
    var TestamentList:Array<String> = ["OT","NT","Full Bible"]
    
    
    
    override func draw(_ rect: CGRect) {
        
        
        self.BookTable.delegate = self
        self.BookTable.dataSource = self
        self.TestamentTable.delegate = self
        self.TestamentTable.dataSource = self
        
        self.Booklist.removeAll()
        
        let BoolCount = BibleContent.sharedInstance.BookToPosition()
        
        if testamentSelect == "OT" {
            for i in 0 ..< 40 {
                self.Booklist.append(BibleContent.sharedInstance.BookToPosition()[i].components(separatedBy: "-")[0])
            }
        } else if testamentSelect == "NT" {
            for i in 40 ..< BoolCount.count {
                self.Booklist.append(BibleContent.sharedInstance.BookToPosition()[i].components(separatedBy: "-")[0])
            }
        } else {
            for i in 0 ..< BoolCount.count {
                self.Booklist.append(BibleContent.sharedInstance.BookToPosition()[i].components(separatedBy: "-")[0])
            }
        }
        
        OldSelect = testamentSelect
        
       
        
        
        
                
        if self.Style == "Books" {
            self.BookTable.isHidden = false
            self.TestamentTable.isHidden = true
            self.BookTable.register(UINib(nibName: "DropDownCell", bundle: nil), forCellReuseIdentifier: "cell")
            self.BookTable.reloadData()
            self.BookViewFrame.SideShadow()
        } else {
            self.BookTable.isHidden = true
            self.TestamentTable.isHidden = false
            self.TestamentTable.register(UINib(nibName: "DropDownCell", bundle: nil), forCellReuseIdentifier: "cell")
            self.TestamentTable.reloadData()
            self.OTViewFrame.SideShadow()
        }
        
    }
    
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 44
        }
    
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    
          func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            if self.Style == "Books" {
                return self.Booklist.count
            } else {
                return self.TestamentList.count
            }
          }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
          {
            if self.Style == "Books" {
                self.DropDownCl = self.BookTable.dequeueReusableCell(withIdentifier: "cell") as? DropDownCell
                self.DropDownCl!.ListItem.text = self.Booklist[indexPath.row]
                
                return self.DropDownCl!
            } else {
                self.DropDownCl = self.TestamentTable.dequeueReusableCell(withIdentifier: "cell") as? DropDownCell
                self.DropDownCl!.ListItem.text = self.TestamentList[indexPath.row]
                
                return self.DropDownCl!
            }

          }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.Style == "Books" {
            self.BookTable.deselectRow(at: indexPath, animated: true)
            let dic = ["dropdown": self.Booklist[indexPath.row]]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dropdownData"),object: nil, userInfo: dic)
        } else {
            self.TestamentTable.deselectRow(at: indexPath, animated: true)
            let dic = ["dropdown": self.TestamentList[indexPath.row]]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dropdownDataT"),object: nil, userInfo: dic)
        }
        NotificationCenter.default.post(name: Notification.Name("PopupClose"), object: nil)
    }
}



