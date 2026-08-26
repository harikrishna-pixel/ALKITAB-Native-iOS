//
//  SettingsViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 09/12/22.
//

import UIKit
import StoreKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Setting {

  @IBOutlet weak var SettingsTable: UITableView!
  @IBOutlet weak var BannerVu: UIView!
  @IBOutlet weak var BlockActionVu: UIView!
  @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
  
  
  var SettingsCell: SettingsTableCell?
  var tableSwitch:Bool = false
  var timePicker = UIDatePicker()
  var toolbar:UIToolbar?
  var Picker_Vu:UIView?
  let dateFormatter = DateFormatter()
  let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
  override func viewDidLoad() {
      super.viewDidLoad()
      App_Protocol.SettingDelegate = self
      
      self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
      BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
      
      self.SettingsTable.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
      self.view.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
      
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
//      self.Notification_Check(Switchstatus: false)
      self.SettingsTable.reloadData()
      
  }
    
  
    override func viewWillAppear(_ animated: Bool) {
            App_Protocol.delegateReader?.hideBottomMenu(Status: false)
        }
    
    @IBAction func Back(_ sender: Any) {
         navigationController?.popViewController(animated: true)
         self.dismiss(animated: true, completion: nil)
       }
    
    
    

  @objc func switchValue(sender:UISwitch!)
  {
      if (sender.isOn == true) {
          self.tableSwitch = true
          UserDefaults.standard.set("1", forKey: "NotifiStatue")
          
          
          if UserDefaults.standard.integer(forKey: "Verses") >= 563 {
              UserDefaults.standard.set(1, forKey: "Verses")
          }
          UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Verses"), forKey: "NotifiVerses")
          
          AppDelegate().onRegisterPushNotification()
//          self.Notification_Check(Switchstatus: true)
      }
      else {
          UserDefaults.standard.set("0", forKey: "NotifiStatue")
          UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
          self.tableSwitch = false
      }
      
      
      self.SettingsTable.reloadData()
  }
  
   
  
  
  // MARK:- Tableview Delegate
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        if indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 6 || indexPath.section == 9 {
            return 38
        } else {
            return 44
        }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
          return 16
  }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if PaymentHistory.sharedInstance.paymentInfo() && book_ads_status > 0 && CoreDataModel.sharedInstance.GetMoreBookShare(entity: CDMoreBookApi).count > 0 {
                return 1
            } else {
                return 0
            }
        } else if section == 15 {
            return UserDefaults.standard.bool(forKey: "OnboardingLoggedIn") ? 1 : 0
        } else if section == 8 {
            // Open Chat hidden from Settings
            return 0
        } else if section == 7 {
            return 1
        } else {
            return 1
        }
        
    }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
      
      switch (indexPath.section) {
                
      
      case 0:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "Recent Arrivals") as! SettingsTableCell?)
          self.SettingsCell!.Notifications.textColor = (Themecolor == BGNightMode ? .white:.black)
//          self.SettingsCell!.selectionStyle = UITableViewCell.SelectionStyle.none
          return self.SettingsCell!
      case 1:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "empty") as! SettingsTableCell?)
          self.SettingsCell!.selectionStyle = UITableViewCell.SelectionStyle.none
          self.SettingsCell!.Notification.textColor = (Themecolor == BGNightMode ? .black:SettingTitleColor)
          self.SettingsCell!.backgroundColor =  (Themecolor == BGNightMode ? SettingTitleBG:.white)
          return self.SettingsCell!
          
      case 2:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "time") as! SettingsTableCell?)
          let dateStr = UserDefaults.standard.string(forKey: "NotifiTime") ?? "08:00"
          self.SettingsCell!.NotificationTime.textColor = (Themecolor == BGNightMode ? .white:.black)
          
          
//          if is24Hour() {
//
//              dateFormatter.dateFormat = "HH:mm"
//
//              if dateStr.count == 5 {
//                  self.SettingsCell!.NotifiTime.text = dateStr
//              } else {
//                  self.SettingsCell!.NotifiTime.text = dateTimeChangeFormat(str: dateStr, inDateFormat:  "hh:mm a", outDateFormat: "HH:mm")
//              }
//          } else {
//              dateFormatter.dateFormat = "hh:mm a"
//              if dateStr.count == 5 {
//                  self.SettingsCell!.NotifiTime.text = dateTimeChangeFormat(str: dateStr, inDateFormat:  "HH:mm", outDateFormat: "hh:mm a")
//              } else {
//                  self.SettingsCell!.NotifiTime.text = dateStr
//              }
//          }
          
//          self.SettingsCell!.NotifiTime.textColor = (Themecolor == BGNightMode ? .white:.gray)
          
          return self.SettingsCell!
          
      case 3:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "empty3") as! SettingsTableCell?)
          self.SettingsCell!.selectionStyle = UITableViewCell.SelectionStyle.none
          self.SettingsCell!.FontTheme.textColor = (Themecolor == BGNightMode ? .black:SettingTitleColor)
          self.SettingsCell!.backgroundColor =  (Themecolor == BGNightMode ? SettingTitleBG:.white)
          return self.SettingsCell!
          
      case 4:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "Font") as! SettingsTableCell?)
            self.SettingsCell!.FontStyle.text = UserDefaults.standard.string(forKey: "FontName") ?? "Euphemia UCAS"
          
          self.SettingsCell!.FontType.textColor = (Themecolor == BGNightMode ? .white:.black)
          
          self.SettingsCell!.FontStyle.textColor = (Themecolor == BGNightMode ? .white:.gray)
          ImageTint.sharedInstance.imageTintcolorMethod(img: self.SettingsCell!.arrow1!, colorVu: (Themecolor == BGNightMode ? .white:.gray))
                
          return self.SettingsCell!
          
      case 5:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "Theme") as! SettingsTableCell?)
          
          self.SettingsCell!.themeColor.ThemeColor()
          self.SettingsCell!.themeColor.backgroundColor = Themecolor
          
          self.SettingsCell!.Theme.textColor = (Themecolor == BGNightMode ? .white:.black)
          
          return self.SettingsCell!
          
      case 6:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "empty1") as! SettingsTableCell?)
          self.SettingsCell!.selectionStyle = UITableViewCell.SelectionStyle.none
          self.SettingsCell!.AboutApp.text = "FEATURES"
          self.SettingsCell!.AboutApp.textColor = (Themecolor == BGNightMode ? .black:SettingTitleColor)
          self.SettingsCell!.backgroundColor =  (Themecolor == BGNightMode ? SettingTitleBG:.white)
          return self.SettingsCell!
          
      case 7:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "FeedBack") as! SettingsTableCell?)
          self.SettingsCell!.Feedback.text = "AI Chat"
          self.SettingsCell!.Feedback.textColor = (Themecolor == BGNightMode ? .white:.black)
          ImageTint.sharedInstance.imageTintcolorMethod(img: self.SettingsCell!.arrow2!, colorVu: (Themecolor == BGNightMode ? .white:.gray))
          
          return self.SettingsCell!

//      case 8:
//          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "FeedBack") as! SettingsTableCell?)
//          self.SettingsCell!.Feedback.text = "Open Chat"
//          self.SettingsCell!.Feedback.textColor = (Themecolor == BGNightMode ? .white:.black)
//          ImageTint.sharedInstance.imageTintcolorMethod(img: self.SettingsCell!.arrow2!, colorVu: (Themecolor == BGNightMode ? .white:.gray))
//          return self.SettingsCell!
      
      case 9:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "empty2") as! SettingsTableCell?)
          self.SettingsCell!.selectionStyle = UITableViewCell.SelectionStyle.none
          self.SettingsCell!.Support.text = "ABOUT & SUPPORT"
          self.SettingsCell!.Support.textColor = (Themecolor == BGNightMode ? .black:SettingTitleColor)
          self.SettingsCell!.backgroundColor =  (Themecolor == BGNightMode ? SettingTitleBG:.white)
          return self.SettingsCell!

      case 10:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "FeedBack") as! SettingsTableCell?)
          self.SettingsCell!.Feedback.text = "Feedback"
          self.SettingsCell!.Feedback.textColor = (Themecolor == BGNightMode ? .white:.black)
          ImageTint.sharedInstance.imageTintcolorMethod(img: self.SettingsCell!.arrow2!, colorVu: (Themecolor == BGNightMode ? .white:.gray))
          return self.SettingsCell!
              
      case 11:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "About") as! SettingsTableCell?)
          self.SettingsCell!.AboutUs.textColor = (Themecolor == BGNightMode ? .white:.black)
          ImageTint.sharedInstance.imageTintcolorMethod(img: self.SettingsCell!.arrow3!, colorVu: (Themecolor == BGNightMode ? .white:.gray))
          return self.SettingsCell!
          
      case 12:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "Rateus") as! SettingsTableCell?)
          self.SettingsCell!.RateUs.textColor = (Themecolor == BGNightMode ? .white:.black)
          return self.SettingsCell!
          
      case 13:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "moreApp") as! SettingsTableCell?)
          self.SettingsCell!.MoreApp.textColor = (Themecolor == BGNightMode ? .white:.black)
          return self.SettingsCell!
      
      case 14:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "Help") as! SettingsTableCell?)
          self.SettingsCell!.Help.textColor = (Themecolor == BGNightMode ? .white:.black)
          return self.SettingsCell!

      case 15:
          self.SettingsCell = (self.SettingsTable.dequeueReusableCell(withIdentifier: "FeedBack") as! SettingsTableCell?)
          self.SettingsCell!.Feedback.text = "Log Out"
          self.SettingsCell!.Feedback.textColor = (Themecolor == BGNightMode ? .white:.black)
          ImageTint.sharedInstance.imageTintcolorMethod(img: self.SettingsCell!.arrow2!, colorVu: (Themecolor == BGNightMode ? .white:.gray))
          return self.SettingsCell!
                  
      default: break
      }

      return self.SettingsCell!
    }
  
  
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      self.SettingsTable.deselectRow(at: indexPath, animated: true)
      
      
      switch (indexPath.section) {
      case 0:
          self.BookCatagory()
      case 2:
//        self.openTimePicker()
          self.NotificationListVC()
      case 4:
          self.FontListNavigation()
            App_Protocol.delegateReader?.hideBottomMenu(Status: true)
      case 5:
          self.CokirPicker()
          App_Protocol.delegateReader?.hideBottomMenu(Status: true)
      case 7:
          self.openAIChat()
//      case 8:
//          self.openOpenChat()
      case 10:
          if NetworkManager.sharedInstance.isConnectedToInternet() {
              let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
              self.navigationController?.pushViewController(vc, animated: true)
          } else {
              self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
          }
      case 11:
          self.AboutUsNavigate()
          App_Protocol.delegateReader?.hideBottomMenu(Status: true)
      case 12:

          if NetworkManager.sharedInstance.isConnectedToInternet() {
              SKStoreReviewController.requestReviewInCurrentScene()
                 } else {
                     self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                 }
                    
      case 13:
          if CoreDataModel.sharedInstance.GetAppImageSave(entity: CDMoreAppApi).count > 0 {
              let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "MoreAppsViewController") as! MoreAppsViewController
              self.navigationController?.pushViewController(vc, animated: true)
          } else {
              if NetworkManager.sharedInstance.isConnectedToInternet() {
                         if let url = URL(string: moreLink), UIApplication.shared.canOpenURL(url) {
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
      case 14:
          if NetworkManager.sharedInstance.isConnectedToInternet() {
                     if let url = URL(string: FAQ), UIApplication.shared.canOpenURL(url) {
                         UIApplication.shared.open(url, options: [:]) { success in
                             print(success ? "URL was opened successfully." : "Failed to open URL.")
                         }
                     } else {
                         self.view.makeToast("Invalid URL or cannot open.", duration: 2.0, position: .bottom)
                     }
                     
                 } else {
                     self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                 }

      case 15:
          self.confirmLogOut()
          
      default:
        break
          
      }
  }
    
    
    
    func CallRate(Rate:String) {
        if Rate == "Feedback" {
            App_Protocol.delegateReader?.FeedbackNavigate()
        } else {
            SKStoreReviewController.requestReviewInCurrentScene()
        }
    }
     
    func RateVc() {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "RateUsViewController") as! RateUsViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
  

  func Notification_Check(Switchstatus:Bool) {
      let current = UNUserNotificationCenter.current()
              current.getNotificationSettings(completionHandler: { permission in
                  switch permission.authorizationStatus  {
                  case .authorized:
                      DispatchQueue.main.async {
                          let indexPath = NSIndexPath(row: 0, section: 1)
                          self.SettingsCell = self.SettingsTable.cellForRow(at: indexPath as IndexPath)  as? SettingsTableCell
                          if self.SettingsCell!.NotifiSwitch.isOn == true {
                              UserDefaults.standard.set("1", forKey: "NotifiStatue")
                          }
                      }
                      break
                  default:
                      if Switchstatus == true {
                          DispatchQueue.main.async {
                              self.AlertVc()
                          }
                      }
                      UserDefaults.standard.set("0", forKey: "NotifiStatue")

                  }
                  DispatchQueue.main.async {
                      self.SettingsTable.reloadData()
                  }
              })
  }
  
  
  @objc func  AlertVc() {

      let alert = UIAlertController(title: "Alert", message: "Please enable 'Notification permission' " , preferredStyle: .alert)

          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
              self.SettingsTable.reloadData()
          }))

          alert.addAction(UIAlertAction(title: "Settings", style: .default, handler:{ (UIAlertAction)in
              SettingNavigate.sharedInstance.settingsNavigate()
          }))


          // for iPad Support
      alert.popoverPresentationController?.sourceView = self.view
          self.present(alert, animated: true, completion: {
          })
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
  
  
  
}



// MARK:- Button Actions


@available(iOS 13.4, *)
extension SettingsViewController {
  
    
    @objc func BookCatagory() {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "BookAdListViewController") as! BookAdListViewController
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func NotificationListVC() {
        let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "NotificationListVC") as! NotificationListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
  
  
    @objc func AboutUsNavigate() {
      let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
      self.navigationController?.pushViewController(vc, animated: true)
      App_Protocol.delegateReader?.AboutusCall()
  }
    
    @objc func openAIChat() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = AIChatViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }

    @objc func openOpenChat() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = OpenChatViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }

    @objc func confirmLogOut() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            OnboardingAuthManager.logOut()
            self?.SettingsTable.reloadData()
            self?.view.makeToast("Logout successfully", duration: 2.0, position: .bottom)
        }))
        present(alert, animated: true)
    }
    
    @objc func openPrayerWall() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = PrayerWallViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    
   @objc func FontListNavigation() {
         let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "FontStyleViewController") as! FontStyleViewController
         self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
  

  
  
  @available(iOS 14.0, *)
  @objc func CokirPicker() {
      
      let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ColorPaletteVC") as! ColorPaletteVC
      self.navigationController?.pushViewController(vc, animated: true)
  }
}




@available(iOS 13.4, *)
extension SettingsViewController {
  
  func openTimePicker()  {
      // Ui timepicker
      
      if self.Picker_Vu?.superview == nil {
          App_Protocol.delegateReader?.hideBottomMenu(Status: true)
          timePicker.datePickerMode = UIDatePicker.Mode.time
          timePicker.preferredDatePickerStyle = .wheels
          timePicker.backgroundColor = UIColor.white
          
          let indexPaths = NSIndexPath(row: 0, section: 2)
          let multilineCell = self.SettingsTable.cellForRow(at: indexPaths as IndexPath) as? SettingsTableCell
           
          let date = dateFormatter.date(from: multilineCell!.NotifiTime.text!)
          timePicker.setDate(date!, animated: false)
          
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
  
  
  @objc func startTimeDiveChanged(sender: UIDatePicker) {
      
      App_Protocol.delegateReader?.hideBottomMenu(Status: false)
      let formatter = DateFormatter()
      formatter.timeStyle = .short
      
      let indexPaths = NSIndexPath(row: 0, section: 2)
      self.SettingsCell = self.SettingsTable.cellForRow(at: indexPaths as IndexPath) as? SettingsTableCell
      self.SettingsCell!.NotifiTime.text = formatter.string(from: timePicker.date)
      UserDefaults.standard.set(self.SettingsCell!.NotifiTime.text!, forKey: "NotifiTime")
      self.Picker_Vu!.removeFromSuperview()
      self.BlockActionVu.isHidden = true
      AppDelegate().onRegisterPushNotification()
  }
  
  
  func is24Hour() -> Bool {
      let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
      return dateFormat.firstIndex(of: "a") == nil
  }
  
}



extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                requestReview(in: scene)
            }
        }
    }
}
