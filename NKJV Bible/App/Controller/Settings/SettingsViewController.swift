//
//  SettingsViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 09/12/22.
//

import UIKit
import StoreKit
import SwiftUI

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
      
      let page = Themecolor == BGNightMode ? BGNightMode : UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
      self.SettingsTable.backgroundColor = page
      self.view.backgroundColor = page
      self.SettingsTable.separatorStyle = .none
      self.SettingsTable.rowHeight = 56
      self.SettingsTable.estimatedRowHeight = 56
      self.SettingsTable.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
      
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
        return 56
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .clear
        return footer
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titles = ["NOTIFICATION", "FONT & THEME", "FEATURES", "ABOUT & SUPPORT"]
        let header = UIView()
        header.backgroundColor = .clear
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = titles[section]
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(white: 0.55, alpha: 1)
        header.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -6)
        ])
        return header
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
          return 4
  }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 1
        case 3: return 6
        default: return 0
        }
    }

    private func cardEdge(for indexPath: IndexPath, in tableView: UITableView) -> SettingsTableCell.CardEdge {
        let count = tableView.numberOfRows(inSection: indexPath.section)
        if count == 1 { return .single }
        if indexPath.row == 0 { return .top }
        if indexPath.row == count - 1 { return .bottom }
        return .middle
    }

    private func styleRowTitle(_ label: UILabel?) {
        label?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label?.textColor = (Themecolor == BGNightMode ? .white : .black)
    }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let night = Themecolor == BGNightMode
      let cell: SettingsTableCell
      switch (indexPath.section, indexPath.row) {
      case (0, 0):
          cell = tableView.dequeueReusableCell(withIdentifier: "time", for: indexPath) as! SettingsTableCell
          cell.NotificationTime?.text = "Notification Mode"
          styleRowTitle(cell.NotificationTime)
      case (1, 0):
          cell = tableView.dequeueReusableCell(withIdentifier: "Font", for: indexPath) as! SettingsTableCell
          cell.FontStyle?.text = UserDefaults.standard.string(forKey: "FontName") ?? "Euphemia UCAS"
          cell.FontStyle?.textColor = night ? .white : UIColor(white: 0.55, alpha: 1)
          styleRowTitle(cell.FontType)
      case (1, 1):
          cell = tableView.dequeueReusableCell(withIdentifier: "Theme", for: indexPath) as! SettingsTableCell
          cell.themeColor?.layer.cornerRadius = 6
          cell.themeColor?.layer.borderWidth = 0
          cell.themeColor?.clipsToBounds = true
          cell.themeColor?.backgroundColor = Themecolor
          styleRowTitle(cell.Theme)
      case (2, 0):
          cell = tableView.dequeueReusableCell(withIdentifier: "FeedBack", for: indexPath) as! SettingsTableCell
          cell.Feedback?.text = "Bible Companion"
          styleRowTitle(cell.Feedback)
      case (3, 0):
          cell = tableView.dequeueReusableCell(withIdentifier: "Recent Arrivals", for: indexPath) as! SettingsTableCell
          cell.Notifications?.text = "Explore Bible Books"
          cell.Notifications?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
          styleRowTitle(cell.Notifications)
      case (3, 1):
          cell = tableView.dequeueReusableCell(withIdentifier: "FeedBack", for: indexPath) as! SettingsTableCell
          cell.Feedback?.text = "Feedback"
          styleRowTitle(cell.Feedback)
      case (3, 2):
          cell = tableView.dequeueReusableCell(withIdentifier: "About", for: indexPath) as! SettingsTableCell
          styleRowTitle(cell.AboutUs)
      case (3, 3):
          cell = tableView.dequeueReusableCell(withIdentifier: "Rateus", for: indexPath) as! SettingsTableCell
          cell.RateUs?.text = "Rate Us"
          styleRowTitle(cell.RateUs)
      case (3, 4):
          cell = tableView.dequeueReusableCell(withIdentifier: "moreApp", for: indexPath) as! SettingsTableCell
          styleRowTitle(cell.MoreApp)
      case (3, 5):
          cell = tableView.dequeueReusableCell(withIdentifier: "Help", for: indexPath) as! SettingsTableCell
          styleRowTitle(cell.Help)
      default:
          return UITableViewCell()
      }
      cell.applyCard(edge: cardEdge(for: indexPath, in: tableView), night: night)
      return cell
    }
  
  
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      self.SettingsTable.deselectRow(at: indexPath, animated: true)
      switch (indexPath.section, indexPath.row) {
      case (0, 0):
          self.NotificationListVC()
      case (1, 0):
          self.FontListNavigation()
          App_Protocol.delegateReader?.hideBottomMenu(Status: true)
      case (1, 1):
          self.CokirPicker()
          App_Protocol.delegateReader?.hideBottomMenu(Status: true)
      case (2, 0):
          self.openAIChat()
      case (3, 0):
          self.BookCatagory()
      case (3, 1):
          if NetworkManager.sharedInstance.isConnectedToInternet() {
              let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
              self.navigationController?.pushViewController(vc, animated: true)
          } else {
              self.view.makeToast("No internet connection", duration: 2.0, position: .top)
          }
      case (3, 2):
          self.AboutUsNavigate()
          App_Protocol.delegateReader?.hideBottomMenu(Status: true)
      case (3, 3):
          if NetworkManager.sharedInstance.isConnectedToInternet() {
              SKStoreReviewController.requestReviewInCurrentScene()
          } else {
              self.view.makeToast("No internet connection", duration: 2.0, position: .top)
          }
      case (3, 4):
          if CoreDataModel.sharedInstance.GetAppImageSave(entity: CDMoreAppApi).count > 0 {
              let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "MoreAppsViewController") as! MoreAppsViewController
              self.navigationController?.pushViewController(vc, animated: true)
          } else if NetworkManager.sharedInstance.isConnectedToInternet() {
              if let url = URL(string: moreLink), UIApplication.shared.canOpenURL(url) {
                  UIApplication.shared.open(url, options: [:], completionHandler: nil)
              } else {
                  self.view.makeToast("Invalid URL or cannot open.", duration: 2.0, position: .top)
              }
          } else {
              self.view.makeToast("No internet connection", duration: 2.0, position: .top)
          }
      case (3, 5):
          if NetworkManager.sharedInstance.isConnectedToInternet() {
              if let url = URL(string: FAQ) {
                  UIApplication.shared.open(url, options: [:], completionHandler: nil)
              } else {
                  self.view.makeToast("Invalid URL or cannot open.", duration: 2.0, position: .top)
              }
          } else {
              self.view.makeToast("No internet connection", duration: 2.0, position: .top)
          }
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
    
    @objc func openChallengeAttempts() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = ChallengeAttemptsViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            view.makeToast("No internet connection", duration: 2.0, position: .top)
        }
    }

    @objc func openAIChat() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = AIChatViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .top)
        }
    }

    @objc func openOpenChat() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = OpenChatViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .top)
        }
    }

    @objc func openProfile() {
        let root = AuthHubProfileView(onBack: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            self?.dismiss(animated: true, completion: nil)
        })
        let host = UIHostingController(rootView: root)
        host.title = "Profile"
        navigationController?.pushViewController(host, animated: true)
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
            self?.view.makeToast("Logout successfully", duration: 2.0, position: .top)
        }))
        present(alert, animated: true)
    }
    
    @objc func openPrayerWall() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = PrayerWallViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .top)
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
