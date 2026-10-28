//
//  AboutUsViewController.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 13/02/21.
//

import UIKit
import StoreKit
import MessageUI


@available(iOS 11.0, *)
class AboutUsViewController: UIViewController, Setting {
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var AppLogo: UIImageView!
    
    @IBOutlet weak var FeedBack: UIView!
    @IBOutlet weak var Share_The_App: UIView!
    @IBOutlet weak var Rate_The_App: UIView!
    @IBOutlet weak var AppTitle: UILabel!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
                           
        App_Protocol.SettingDelegate = self
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.AppLogo!, colorVu: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
        
        applyAboutLayout(theme: Themecolor)
    }

    private func applyAboutLayout(theme: UIColor) {
        guard let content = AppTitle.superview else { return }
        let labels = content.subviews.compactMap { $0 as? UILabel }.filter { $0 !== AppTitle }
        guard let body = labels.first(where: { $0.numberOfLines == 0 }),
              let support = labels.first(where: { $0 !== body }) else { return }

        let versionText = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        AppTitle.text = APPNAME
        AppTitle.textColor = theme
        AppTitle.textAlignment = .center
        AppTitle.font = UIFont.systemFont(ofSize: 28, weight: .bold)

        if let titleGap = content.constraints.first(where: { ($0.firstItem as? UILabel) === AppTitle && $0.firstAttribute == .top && ($0.secondItem as? UIImageView) === AppLogo }) {
            titleGap.constant = 10
        }

        let version = UILabel()
        version.translatesAutoresizingMaskIntoConstraints = false
        version.text = "Version \(versionText)"
        version.textAlignment = .center
        version.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        version.textColor = UIColor(white: 0.55, alpha: 1)
        content.addSubview(version)

        content.constraints.first { ($0.firstItem as? UILabel) === body && $0.firstAttribute == .top && ($0.secondItem as? UILabel) === AppTitle }?.isActive = false
        NSLayoutConstraint.activate([
            version.topAnchor.constraint(equalTo: AppTitle.bottomAnchor, constant: 4),
            version.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            body.topAnchor.constraint(equalTo: version.bottomAnchor, constant: 18)
        ])

        body.text = "We are committed to providing the best features and tools to help you read, study, and grow in God's Word."
        body.textAlignment = .center
        body.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        body.textColor = UIColor(white: 0.25, alpha: 1)

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = theme.withAlphaComponent(0.35)
        let diamond = UIView()
        diamond.translatesAutoresizingMaskIntoConstraints = false
        diamond.backgroundColor = theme
        diamond.transform = CGAffineTransform(rotationAngle: .pi / 4)
        content.addSubview(divider)
        content.addSubview(diamond)

        content.constraints.first { ($0.firstItem as? UILabel) === support && $0.firstAttribute == .top && ($0.secondItem as? UILabel) === body }?.isActive = false
        support.text = "Support Us"
        support.textAlignment = .center
        support.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        support.textColor = theme

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Your feedback and rating help us improve and create better features"
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0
        subtitle.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitle.textColor = UIColor(white: 0.55, alpha: 1)
        content.addSubview(subtitle)

        content.constraints.first { ($0.firstItem as? UIView) === FeedBack && $0.firstAttribute == .top && ($0.secondItem as? UILabel) === support }?.isActive = false
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 22),
            divider.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            divider.widthAnchor.constraint(equalToConstant: 132),
            divider.heightAnchor.constraint(equalToConstant: 1),
            diamond.centerXAnchor.constraint(equalTo: divider.centerXAnchor),
            diamond.centerYAnchor.constraint(equalTo: divider.centerYAnchor),
            diamond.widthAnchor.constraint(equalToConstant: 7),
            diamond.heightAnchor.constraint(equalToConstant: 7),
            support.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            subtitle.topAnchor.constraint(equalTo: support.bottomAnchor, constant: 6),
            subtitle.leadingAnchor.constraint(equalTo: body.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: body.trailingAnchor),
            FeedBack.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 18)
        ])

        styleAboutCard(FeedBack, title: "Feedback", symbol: "bubble.left.fill", tint: theme, fill: theme.withAlphaComponent(0.10))
        styleAboutCard(Share_The_App, title: "Share The App", symbol: "square.and.arrow.up.fill", tint: UIColor(red: 0.18, green: 0.62, blue: 0.42, alpha: 1), fill: UIColor(red: 0.90, green: 0.96, blue: 0.93, alpha: 1))
        styleAboutCard(Rate_The_App, title: "Rate The App", symbol: "star.fill", tint: UIColor(red: 0.85, green: 0.62, blue: 0.16, alpha: 1), fill: UIColor(red: 1.0, green: 0.96, blue: 0.90, alpha: 1))

        for card in [Share_The_App, Rate_The_App] {
            content.constraints.first { ($0.firstItem as? UIView) === card && $0.firstAttribute == .top }?.constant = 12
        }

        content.constraints.first { $0.firstAttribute == .height && $0.secondItem == nil }?.isActive = false
        content.bottomAnchor.constraint(equalTo: Rate_The_App.bottomAnchor, constant: 28).isActive = true
    }

    private func styleAboutCard(_ card: UIView, title: String, symbol: String, tint: UIColor, fill: UIColor) {
        guard let content = card.superview, let label = card.subviews.compactMap({ $0 as? UILabel }).first else { return }
        card.isHidden = false
        card.backgroundColor = fill
        card.layer.borderWidth = 0
        card.layer.cornerRadius = 16
        card.clipsToBounds = true

        for constraint in card.constraints {
            if constraint.firstAttribute == .width && constraint.secondItem == nil {
                constraint.isActive = false
            }
            if constraint.firstAttribute == .height && constraint.secondItem == nil {
                constraint.constant = 62
            }
            if (constraint.firstItem as? UILabel) === label && constraint.firstAttribute == .leading {
                constraint.constant = 68
            }
            if constraint.firstAttribute == .trailing && (constraint.secondItem as? UILabel) === label {
                constraint.constant = 36
            }
        }
        let width = card.widthAnchor.constraint(equalTo: content.widthAnchor, constant: -40)
        width.priority = UILayoutPriority(999)
        width.isActive = true
        card.widthAnchor.constraint(lessThanOrEqualToConstant: 520).isActive = true

        label.text = title
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(white: 0.12, alpha: 1)

        let well = UIView()
        well.translatesAutoresizingMaskIntoConstraints = false
        well.backgroundColor = tint.withAlphaComponent(0.16)
        well.layer.cornerRadius = 18
        well.isUserInteractionEnabled = false
        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = tint
        icon.contentMode = .scaleAspectFit
        icon.isUserInteractionEnabled = false
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = tint
        chevron.contentMode = .scaleAspectFit
        chevron.isUserInteractionEnabled = false
        card.addSubview(well)
        well.addSubview(icon)
        card.addSubview(chevron)
        NSLayoutConstraint.activate([
            well.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            well.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            well.widthAnchor.constraint(equalToConstant: 36),
            well.heightAnchor.constraint(equalToConstant: 36),
            icon.centerXAnchor.constraint(equalTo: well.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: well.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 10),
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    
    // MARK: - Button Action
    
    
    @IBAction func FeedBack(_ sender: Any) {
//        App_Protocol.delegateReader?.FeedbackNavigate()
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
        
    }
    
    
    @IBAction func ShareApp(_ sender: Any) {
        self.shared(Link: APP_LINK)
        
    }
    
    func shared(Link:String) {
        let text = "Hi, I found an amazing Reading Bible application with challenging Bible Trivia to improvise biblical knowledge. \n\nTry it now! : : \(Link)"
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func RateApp(_ sender: Any) {
//        SKStoreReviewController.requestReviewInCurrentScene()
        self.RateVc()
    }
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
    
    
}
