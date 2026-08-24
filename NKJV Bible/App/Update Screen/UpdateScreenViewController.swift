//
//  UpdateScreenViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 02/02/23.
//

import UIKit

class UpdateScreenViewController: UIViewController {

    @IBOutlet weak var PreviewImageWidth: NSLayoutConstraint!
    @IBOutlet weak var UpdateTxt: UILabel!
    @IBOutlet weak var Version: UILabel!

    var UpdateAppLink = ""
    var UpdateVersion = ""
    var UpdateText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        PreviewImageWidth.constant = ScreenWidth
        UpdateTxt.text = UpdateText
        Version.text = UpdateVersion
    }

    @IBAction func UpdateAction(_ sender: Any) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            if let url = URL(string: UpdateAppLink), UIApplication.shared.canOpenURL(url) {
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

    @IBAction func TrylaterAction(_ sender: Any) {
        UserDefaults.standard.set(Date().string(format: "MMM d, yyyy"), forKey: "CurrentDate")
        self.dismiss(animated: true, completion: nil)
    }
}
