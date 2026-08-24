//
//  QuizSettingVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 23/02/23.
//

import UIKit

class QuizSettingVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var QuizSettingsTable: UITableView!
    
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    var FAQView: FAQVu?
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    var QuizSettingsCell: QuizSettingsTableCell?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
     // MARK:- Tableview Delegate
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return 44
     }
     
     func numberOfSections(in tableView: UITableView) -> Int {
         return 5
     }
     
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
       }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
       {
         
         switch (indexPath.section) {
         
         case 0:
             self.QuizSettingsCell = (self.QuizSettingsTable.dequeueReusableCell(withIdentifier: "sound_timer") as! QuizSettingsTableCell?)
             
             return self.QuizSettingsCell!
             
         case 1:
             self.QuizSettingsCell = (self.QuizSettingsTable.dequeueReusableCell(withIdentifier: "sound") as! QuizSettingsTableCell?)


             self.QuizSettingsCell!.MusicSwitch.isOn = UserDefaults.standard.bool(forKey: "MusicSwitch")
             self.QuizSettingsCell!.MusicSwitch.addTarget(self, action: #selector(MusicSwitch_Action), for: .valueChanged)


             return self.QuizSettingsCell!

         case 2:
             self.QuizSettingsCell = (self.QuizSettingsTable.dequeueReusableCell(withIdentifier: "tone") as! QuizSettingsTableCell?)

             self.QuizSettingsCell!.ToneSwitch.isOn = UserDefaults.standard.bool(forKey: "ToneSwitch")
             self.QuizSettingsCell!.ToneSwitch.addTarget(self, action: #selector(ToneSwitch_Action), for: .valueChanged)

             return self.QuizSettingsCell!
             
         case 3:
             self.QuizSettingsCell = (self.QuizSettingsTable.dequeueReusableCell(withIdentifier: "vibration") as! QuizSettingsTableCell?)

             self.QuizSettingsCell!.VibrationSwitch.isOn = UserDefaults.standard.bool(forKey: "VibSwitch")
             self.QuizSettingsCell!.VibrationSwitch.addTarget(self, action: #selector(VibSwitch_Action), for: .valueChanged)

             return self.QuizSettingsCell!
             
         case 4:
             self.QuizSettingsCell = (self.QuizSettingsTable.dequeueReusableCell(withIdentifier: "FAQ") as! QuizSettingsTableCell?)
             
             self.QuizSettingsCell!.FaQBtn.addTarget(self, action: #selector(FAQFrame), for: .touchUpInside)

             return self.QuizSettingsCell!
             
             

         default: break
         }

         return self.QuizSettingsCell!
       }
     
    
    
    @objc func FAQFrame() {
        self.FAQView = FAQVu.fromNib(named: "FAQVu")
        self.FAQView!.frame = self.view.bounds
        self.FAQView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.FAQView!)
    }
    
    
    
    @objc func MusicSwitch_Action() {
            
        if UserDefaults.standard.bool(forKey: "MusicSwitch") {
            UserDefaults.standard.set(false, forKey: "MusicSwitch")
            MusicBgFile.sharedInstance.stop()
        } else {
            UserDefaults.standard.set(true, forKey: "MusicSwitch")
            MusicBgFile.sharedInstance.playSound()
        }
        self.QuizSettingsTable.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    @objc func ToneSwitch_Action() {
        if UserDefaults.standard.bool(forKey: "ToneSwitch") {
            UserDefaults.standard.set(false, forKey: "ToneSwitch")
        } else {
            UserDefaults.standard.set(true, forKey: "ToneSwitch")
        }
        self.QuizSettingsTable.reloadSections(IndexSet(integer: 2), with: .none)
    }
    
    @objc func VibSwitch_Action() {
        if UserDefaults.standard.bool(forKey: "VibSwitch") {
            UserDefaults.standard.set(false, forKey: "VibSwitch")
        } else {
            UserDefaults.standard.set(true, forKey: "VibSwitch")
            Vibration.heavy.vibrate()
        }
        self.QuizSettingsTable.reloadSections(IndexSet(integer: 3), with: .none)
    }
    
     


    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let indexPath = NSIndexPath(row: 0, section: 4)
        self.QuizSettingsCell = self.QuizSettingsTable.cellForRow(at: indexPath as IndexPath) as? QuizSettingsTableCell
        
        
        if Int((self.QuizSettingsCell?.QuestionCount.text!)!) ?? 5 >= 20 {
            self.QuizSettingsCell?.QuestionCount.text = "20"
        }
        
        UserDefaults.standard.setValue(Int((self.QuizSettingsCell?.QuestionCount.text!)!), forKey: "QuestionList")
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
//        if Int(self.QuestionCount.text!)! >= 20 {
//            return false
//        }
        
//        let indexPath = NSIndexPath(row: 0, section: 4)
//        self.QuizSettingsCell = self.QuizSettingsTable.cellForRow(at: indexPath as IndexPath) as? QuizSettingsTableCell
//
//        print("self.QuizSettingsCell?.QuestionCount.text :",self.QuizSettingsCell?.QuestionCount.text)
        
//        if Int((self.QuizSettingsCell?.QuestionCount.text!)!)! >= 20 {
//            return false
//        }
//
        return true
    }
    
    
    
    
    

}
