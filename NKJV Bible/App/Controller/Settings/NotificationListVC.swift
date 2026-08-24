//
//  NotificationListVC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 28/06/23.
//

import UIKit

class NotificationListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var SettingsTable: UITableView!
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BlockActionVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    let dateFormatter = DateFormatter()
    var timePicker = UIDatePicker()
    var toolbar:UIToolbar?
    var Picker_Vu:UIView?
    var SelectedPicker:Int = 0
    var NotificationCell: NotificationTableCell?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func Back(_ sender: Any) {
           navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
       }

}



extension NotificationListVC {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 4
    }
    
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 1
      }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
      {
        
        switch (indexPath.section) {
        
        case 0:
            self.NotificationCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "Morning") as! NotificationTableCell?)
            
            let dateStr = UserDefaults.standard.string(forKey: "Shift 1") ?? "08:00"
            self.NotificationCell!.NotifiMorningTime.text =  ChangeDate(dateStr: dateStr)
            self.NotificationCell!.Shift1Switch.isOn = UserDefaults.standard.bool(forKey: "Shift1ON")
            self.NotificationCell!.Shift1Switch.addTarget(self, action: #selector(Shift1_Value), for: .valueChanged)
            
            
            return self.NotificationCell!
            
        case 1:
            self.NotificationCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "Evening") as! NotificationTableCell?)
            
            let dateStr = UserDefaults.standard.string(forKey: "Shift 2") ?? "16:00"
            self.NotificationCell!.NotifiEveningTime.text =  ChangeDate(dateStr: dateStr)
            
            self.NotificationCell!.Shift2Switch.isOn = UserDefaults.standard.bool(forKey: "Shift2ON")
            self.NotificationCell!.Shift2Switch.addTarget(self, action: #selector(Shift2_Value), for: .valueChanged)

            return self.NotificationCell!
            
        case 2:
            self.NotificationCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "Night") as! NotificationTableCell?)
            
            let dateStr = UserDefaults.standard.string(forKey: "Shift 3") ?? "20:00"
            self.NotificationCell!.NotifiNightTime.text =  ChangeDate(dateStr: dateStr)
            
            self.NotificationCell!.Shift3Switch.isOn = UserDefaults.standard.bool(forKey: "Shift3ON")
            self.NotificationCell!.Shift3Switch.addTarget(self, action: #selector(Shift3_Value), for: .valueChanged)
            
            
            return self.NotificationCell!
            
        case 3:
            self.NotificationCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "QuizTime") as! NotificationTableCell?)
            
            let dateStr = UserDefaults.standard.string(forKey: "Shift 4") ?? "14:00"
            self.NotificationCell!.NotifiQuizTime.text =  ChangeDate(dateStr: dateStr)
            
            self.NotificationCell!.Shift4Switch.isOn = UserDefaults.standard.bool(forKey: "Shift4ON")
            self.NotificationCell!.Shift4Switch.addTarget(self, action: #selector(Shift4_Value), for: .valueChanged)
            
            
            return self.NotificationCell!
            
        default: break
        }

        return self.NotificationCell!
      }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.SettingsTable.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section) {
        case 0:
            if UserDefaults.standard.bool(forKey: "Shift1ON") {
                self.openTimePicker(Case: 0)
            }
        case 1:
            if UserDefaults.standard.bool(forKey: "Shift2ON") {
                self.openTimePicker(Case: 1)
            }
        case 2:
            if UserDefaults.standard.bool(forKey: "Shift3ON") {
                self.openTimePicker(Case: 2)
            }
        case 3:
            if UserDefaults.standard.bool(forKey: "Shift4ON") {
                self.openTimePicker(Case: 3)
            }
        default:
          break

        }
    }

    
    
    @objc func Shift1_Value(sender:UISwitch!) {
        
        if (sender.isOn == true) {
            UserDefaults.standard.setValue(true, forKey: "Shift1ON")
            if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
                UserDefaults.standard.set(1, forKey: "Verses")
            }
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Verses"), forKey: "NotifiVerses")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "PerDay")+1, forKey: "PerDay")
        } else {
            UserDefaults.standard.setValue(false, forKey: "Shift1ON")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "PerDay")-1, forKey: "PerDay")
        }
        self.NotificationReload()
    }
    
    
    
    @objc func Shift2_Value(sender:UISwitch!) {
        
        if (sender.isOn == true) {
            UserDefaults.standard.setValue(true, forKey: "Shift2ON")
            if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
                UserDefaults.standard.set(1, forKey: "Verses")
            }
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Verses"), forKey: "NotifiVerses")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "PerDay")+1, forKey: "PerDay")
        } else {
            UserDefaults.standard.setValue(false, forKey: "Shift2ON")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "PerDay")-1, forKey: "PerDay")
        }
        
        self.NotificationReload()
    }
    
    @objc func Shift3_Value(sender:UISwitch!) {
        
        if (sender.isOn == true) {
            UserDefaults.standard.setValue(true, forKey: "Shift3ON")
            if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
                UserDefaults.standard.set(1, forKey: "Verses")
            }
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Verses"), forKey: "NotifiVerses")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "PerDay")+1, forKey: "PerDay")
        } else {
            UserDefaults.standard.setValue(false, forKey: "Shift3ON")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "PerDay")-1, forKey: "PerDay")
        }
        
        self.NotificationReload()
    }
    
    
    
    @objc func Shift4_Value(sender:UISwitch!) {
        
        if (sender.isOn == true) {
            UserDefaults.standard.setValue(true, forKey: "Shift4ON")
            if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
                UserDefaults.standard.set(1, forKey: "Verses")
            }
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Verses"), forKey: "NotifiVerses")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "PerDay")+1, forKey: "PerDay")
        } else {
            UserDefaults.standard.setValue(false, forKey: "Shift4ON")
            UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "PerDay")-1, forKey: "PerDay")
        }
        
        self.NotificationReload()
    }
    
    
    
    
    func NotificationReload() {
        if UserDefaults.standard.bool(forKey: "Shift1ON") || UserDefaults.standard.bool(forKey: "Shift2ON") || UserDefaults.standard.bool(forKey: "Shift3ON") || UserDefaults.standard.bool(forKey: "Shift4ON") {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            AppDelegate().onRegisterPushNotification()
        }
        
        if !UserDefaults.standard.bool(forKey: "Shift1ON") && !UserDefaults.standard.bool(forKey: "Shift2ON") && !UserDefaults.standard.bool(forKey: "Shift3ON") && !UserDefaults.standard.bool(forKey: "Shift4ON") {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        self.SettingsTable.reloadData()
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                    let alert = UIAlertController(title: "Alert!", message: "Turn on Notifications to Stay Connected.\nTap on Settings -> Bible app  -> Notifications", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
        
    }
    
    
    
//    func NotificationStatus() {
//        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
//            print("Checking notification status")
//            if settings.authorizationStatus != .authorized {
//                UserDefaults.standard.setValue(false, forKey: "Shift1ON")
//                UserDefaults.standard.setValue(false, forKey: "Shift2ON")
//                UserDefaults.standard.setValue(false, forKey: "Shift3ON")
//                UserDefaults.standard.setValue(false, forKey: "Shift4ON")
//            }
//        }
//    }
    
    
    
    @objc func switchValue(sender:UISwitch!) {
           
        if (sender.isOn == true) {
            
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Verses"), forKey: "NotifiVerses")
            AppDelegate().onRegisterPushNotification()
            
        }
        else {
            UserDefaults.standard.set("0", forKey: "NotifiStatue")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
        self.SettingsTable.reloadData()
    }
    
    
    

    func openTimePicker(Case:Int)  {
        // Ui timepicker
        
        self.BlockActionVu.isHidden = false
        if self.Picker_Vu?.superview == nil {
            App_Protocol.delegateReader?.hideBottomMenu(Status: true)
            timePicker.datePickerMode = UIDatePicker.Mode.time
            timePicker.preferredDatePickerStyle = .wheels
            timePicker.backgroundColor = UIColor.white
            
            let indexPaths = NSIndexPath(row: 0, section: Case)
            let multilineCell = self.SettingsTable.cellForRow(at: indexPaths as IndexPath) as? NotificationTableCell
             
            self.SelectedPicker = Case
            
            switch (Case) {
            case 0:
                
                let date = dateFormatter.date(from: multilineCell!.NotifiMorningTime.text!)
                timePicker.setDate(date!, animated: false)
            case 1:
                let date = dateFormatter.date(from: multilineCell!.NotifiEveningTime.text!)
                timePicker.setDate(date!, animated: false)
            case 2:
                let date = dateFormatter.date(from: multilineCell!.NotifiNightTime.text!)
                timePicker.setDate(date!, animated: false)
            case 3:
                let date = dateFormatter.date(from: multilineCell!.NotifiQuizTime.text!)
                timePicker.setDate(date!, animated: false)
            default:
              break

            }


            
            self.BlockActionVu.isHidden = false
            self.Picker_Vu = UIView(frame: CGRect(x: 0, y:  UIScreen.main.bounds.size.height - 280, width:self.SettingsTable.frame.width, height: 280))
            
            timePicker.frame = CGRect(x: 0.0, y: (self.Picker_Vu?.frame.height)! - 240, width: (self.Picker_Vu?.frame.width)!, height: 220)

            // Ui tool bar
            self.toolbar = UIToolbar(frame: CGRect(x: 0, y:(self.Picker_Vu?.frame.height)! - 280, width: ScreenWidth, height: 50))
            self.toolbar!.barStyle = .default
            self.toolbar!.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(startTimeDiveChanged))
            ]
            
            self.toolbar!.sizeToFit()
            self.view.addSubview(self.Picker_Vu!)
            self.Picker_Vu!.addSubview(timePicker)
            self.Picker_Vu!.addSubview(self.toolbar!)
        }
        
    }
    
    
    
    
    func Notification_Check(Switchstatus:Bool) {
        let current = UNUserNotificationCenter.current()
                current.getNotificationSettings(completionHandler: { permission in
                    switch permission.authorizationStatus  {
                    case .authorized:
                        DispatchQueue.main.async {
                            let indexPath = NSIndexPath(row: 0, section: 1)
//                            self.SettingsCell = self.SettingsTable.cellForRow(at: indexPath as IndexPath)  as? SettingsTableCell
//                            if self.SettingsCell!.NotifiSwitch.isOn == true {
//                                UserDefaults.standard.set("1", forKey: "NotifiStatue")
//                            }
                        }
                        break
                    default:
                        if Switchstatus == true {
                            DispatchQueue.main.async {
//                                self.AlertVc()
                            }
                        }
                        
                        UserDefaults.standard.setValue(true, forKey: "Shift1ON")
                        UserDefaults.standard.setValue(true, forKey: "Shift2ON")
                        UserDefaults.standard.setValue(true, forKey: "Shift3ON")
                        UserDefaults.standard.setValue(true, forKey: "Shift4ON")
                        
                    }
                    DispatchQueue.main.async {
                        self.SettingsTable.reloadData()
                    }
                })
    }
    
    
    
    
    func ChangeDate(dateStr:String) -> String {
        
        if is24Hour() {

            dateFormatter.dateFormat = "HH:mm"

            if dateStr.count == 5 {
                return dateStr
            } else {
                return dateTimeChangeFormat(str: dateStr, inDateFormat:  "hh:mm a", outDateFormat: "HH:mm")
            }
        } else {
            dateFormatter.dateFormat = "hh:mm a"
            if dateStr.count == 5 {
                return dateTimeChangeFormat(str: dateStr, inDateFormat:  "HH:mm", outDateFormat: "hh:mm a")
            } else {
                return dateStr
            }
        }
        
    }
    
    @objc func startTimeDiveChanged(sender: UIDatePicker) {
        
        self.BlockActionVu.isHidden = true
        App_Protocol.delegateReader?.hideBottomMenu(Status: false)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        
        let indexPaths = NSIndexPath(row: 0, section: self.SelectedPicker)
        let multilineCell = self.SettingsTable.cellForRow(at: indexPaths as IndexPath) as? NotificationTableCell
        
                
            switch (self.SelectedPicker) {
            case 0:
                multilineCell!.NotifiMorningTime.text = formatter.string(from: timePicker.date)
                UserDefaults.standard.set(multilineCell!.NotifiMorningTime.text!, forKey: "Shift 1")
            case 1:
                multilineCell!.NotifiEveningTime.text = formatter.string(from: timePicker.date)
                UserDefaults.standard.set(multilineCell!.NotifiEveningTime.text!, forKey: "Shift 2")
            case 2:
                multilineCell!.NotifiNightTime.text = formatter.string(from: timePicker.date)
                UserDefaults.standard.set(multilineCell!.NotifiNightTime.text!, forKey: "Shift 3")
                
            case 3:
                multilineCell!.NotifiQuizTime.text = formatter.string(from: timePicker.date)
                UserDefaults.standard.set(multilineCell!.NotifiQuizTime.text!, forKey: "Shift 4")
                
            default:
              break

            }
                
        
        self.Picker_Vu!.removeFromSuperview()
        self.BlockActionVu.isHidden = true
        AppDelegate().onRegisterPushNotification()
    }
    
    
    
    func dateTimeChangeFormat(str stringWithDate: String, inDateFormat: String, outDateFormat: String) -> String {
        let inFormatter = DateFormatter()
        inFormatter.locale = Locale(identifier: "en_US_POSIX")
        inFormatter.dateFormat = inDateFormat

        let outFormatter = DateFormatter()
        outFormatter.locale = Locale(identifier: "en_US_POSIX")
        outFormatter.dateFormat = outDateFormat

        let inStr = stringWithDate
        let date = inFormatter.date(from: inStr)!
        return outFormatter.string(from: date)
    
    }
    
    
    func is24Hour() -> Bool {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        return dateFormat.firstIndex(of: "a") == nil
    }
    
    
    
    
}

