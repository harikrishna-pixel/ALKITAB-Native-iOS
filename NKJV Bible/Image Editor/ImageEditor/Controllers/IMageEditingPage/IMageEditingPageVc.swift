//
//  IMageEditingPageVc.swift
//  ImageEditor
//
//  Created by ajayprasanth on 24/03/23.
//

import UIKit
import Photos

class IMageEditingPageVc: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ImageTxtEdit, UIColorPickerViewControllerDelegate {
  
    
    
    @IBOutlet weak var BannerVu: UIView!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var BottomBanner: NSLayoutConstraint!
    
    
    @IBOutlet var imageList: UICollectionView!
    @IBOutlet var imageVu: UIImageView!
    @IBOutlet var StickimageVu: JLStickerImageView!
    
    @IBOutlet var FontEditView: UIView!
    @IBOutlet var FontMainView: UIView!
    
    @IBOutlet var BackgroundVu: UIView!
    @IBOutlet var TextVu: UIView!
    @IBOutlet var FilterVu: UIView!
    @IBOutlet var StickerVuimageVu: UIView!
    @IBOutlet var FilterFrame: UIView!
    
    @IBOutlet var Commonframe: UIView!
    @IBOutlet var BottomMenu: UIView!
    
    @IBOutlet var VerseLbl: UILabel!
    @IBOutlet var TitleLbl: UILabel!
    
    @IBOutlet var AdloadView: UIView!
    
//    @IBOutlet var ImageBtn: UIButton!
//    @IBOutlet var ColorBtn: UIButton!
    
    @IBOutlet var AlignBtn: UIButton!
    @IBOutlet var FontColorBtn: UIButton!
    @IBOutlet var FontstyleBtn: UIButton!
    
    @IBOutlet var BlurVu: UIView!
    @IBOutlet var Watermark: UIView!
    @IBOutlet var WatermarkClose: UIImageView!
    
    
    @IBOutlet var BackgroundImg: UIImageView!
    @IBOutlet var TextImg: UIImageView!
    @IBOutlet var FilterImg: UIImageView!
    @IBOutlet var StickerImg: UIImageView!
    
    
    @IBOutlet var PayView: UIView!
    @IBOutlet var OrTxt: UILabel!
    
    @IBOutlet var bibleName: UILabel!
    
    
    @IBOutlet var Mainview:UIView!
    
    //    @IBOutlet var OpacitySlider: UISlider!
    
        let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
//    var alignment: NSTextAlignment  = .center
//    var textGape:CGFloat = 1.0
//    var lineGape:CGFloat = 1.0
//    var FontSize:CGFloat = 20.0
//    var FontColor:UIColor = UIColor.white
//    var Fontstyle:UIFont = UIFont(name: "HelveticaNeue", size: 20)!
//    var Fontname:String = "HelveticaNeue"
    
    var ColorList:Bool = false
    var RemoveAd:Bool = false
    
    var selectedColor: UIColor = UIColor.white
    lazy var SelectedTab:String = "0"
    
    lazy var SelectedImg:String = ""
    var GetImage:UIImage?
    
    weak var ColorVu: ColorView?
    weak var FontTableVu: FontTable?
    weak var StickerVu: Sticker?
    
    weak var fontAlignVu: fontAlign?
    weak var FilterView: Filter?
    
    
    var ImageListCell: ImageCollectionViewCell?
    
    var verseTxt:String = ""
    var titceTxt:String = ""
    
    var BGColor:[String] = ["D49854" ,"2BA27E" ,"8D50AF" ,"3C71B7" ,"3CB79E" ,"755112" ,"EF4444" ,"A6B24F" ,"7658CB" ,"1C67B2" ,"1C93B2" ,"1CB293" ,"72C46C", "#8a0e6c", "#052d72", "#05878a", "#163f34", "#dd9933", "#545454", "#a52a2a", "#607057", "#572c5f", "#5b4e77"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        ImageAppProtocol.ImageTxtEditDelegate  = self
        
        self.BottomMenu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.BackgroundImg!, colorVu: Themecolor)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.TextImg!, colorVu: Themecolor)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.FilterImg!, colorVu: Themecolor)
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.StickerImg!, colorVu: Themecolor)
        

        
        if UIScreen.main.bounds.height <= 690 {
            self.BottomBanner.constant = 90
        }
        
        
        self.bibleName.text = APPNAME_SPLASH
        self.bibleName.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        
        Mainview.layer.masksToBounds = true
        self.TitleLbl.text = titceTxt
        
//        self.ImageBtn.layer.cornerRadius = self.ImageBtn.frame.height/2
//        self.ColorBtn.layer.cornerRadius = self.ColorBtn.frame.height/2
//        self.ImageBtn.backgroundColor  = Themecolor
        
        self.AlignBtn.layer.cornerRadius = self.AlignBtn.frame.height/2
        self.FontColorBtn.layer.cornerRadius = self.FontColorBtn.frame.height/2
        self.FontstyleBtn.layer.cornerRadius = self.FontstyleBtn.frame.height/2
        self.imageVu.image = GetImage
        
        
        
        self.atributetxt()
        
        if PaymentHistory.sharedInstance.paymentInfoVerify() {
            self.Watermark.isHidden = false
        } else {
            self.Watermark.isHidden = true
        }
        
        
        
        if IS_SUBSCRIPTION_ENABLE == 0 {
            self.PayView.isHidden = true
            self.OrTxt.isHidden = true
        }
        
    }
      

    
    override func viewDidDisappear(_ animated: Bool) {
        TFontColor = UIColor.white
    }
    
    
    
    @IBAction func BlurVu_Action(_ sender: Any) {
         BlurVu.isHidden = false
    }
    
    @IBAction func Cancel_Action(_ sender: Any) {
        BlurVu.isHidden = true
    }
    
    @IBAction func RemoveWatermark_Action(_ sender: Any) {
        
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            self.AdloadView.isHidden = false
            AdmobManager.shared.IronSource_Reward_ShowAds(vw: (UIApplication.shared.keyWindow?.rootViewController)!, RewardAd: "ImageWatermark")
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    @IBAction func Payment_Action(_ sender: Any) {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SubscrbViewController") as! SubscrbViewController
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.presentVu = true
            self.present(vc, animated: true, completion: nil)
        } else {
            self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
    
    
    
    
    
    func AdNotAvailable() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            self.BlurVu.isHidden = true
            self.AdloadView.isHidden = true
        }
    }
    
    
    
    func CollectCoin() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
            self.AdloadView.isHidden = true
            self.BlurVu.isHidden = true
            self.Watermark.isHidden = true
            self.RemoveAd = true
        }
    }
    
    
    
    
    
    func StickerCall(image:UIImage) {
        self.ImportImage(SignatureImg: image)
    }
    
    func ImportImage(SignatureImg:UIImage) {
        
        StickimageVu.addImage()
        StickimageVu.currentlyEditingLabel.imageView?.image = SignatureImg
        StickimageVu.currentlyEditingLabel.closeView!.image = UIImage(named: "CancelImage.png")
        StickimageVu.currentlyEditingLabel.rotateView?.image = UIImage(named: "rotating.png")
        StickimageVu.currentlyEditingLabel.labelTextView?.becomeFirstResponder()
        StickimageVu.currentlyEditingLabel.labelTextView?.alignment = Talignment
        StickimageVu.currentlyEditingLabel.labelTextView?.becomeFirstResponder()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PaymentHistory.sharedInstance.paymentInfoVerify() && !self.RemoveAd {
            self.Watermark.isHidden = false
        } else {
            self.Watermark.isHidden = true
        }
        
        self.imageList.reloadData()
    }
    
    
    func CheckPay() {
        
        if PaymentHistory.sharedInstance.paymentInfoVerify() {
            self.Watermark.isHidden = false
        } else {
            self.Watermark.isHidden = true
        }
        self.BlurVu.isHidden = true
    }
    
    
    
    
    func fontFrame_Init() {
        for view in self.FontEditView.subviews {
            view.removeFromSuperview()
        }
        self.FontColorBtn.backgroundColor = .gray.withAlphaComponent(0.6)
        self.FontstyleBtn.backgroundColor = .gray.withAlphaComponent(0.6)
        self.AlignBtn.backgroundColor = .gray.withAlphaComponent(0.6)
    }
    
    
    func ImageChange_Action(Image:UIImage) {
        imageVu.image = Image
    }
    
    
    func linegape_Action(lineGape: CGFloat) {
        TlineGape = lineGape
        self.atributetxt()
    }
    
    func textspace_Action(textGape: CGFloat) {
        TtextGape = textGape
        self.atributetxt()
    }
    
    func fontColor_Action(fontColor: UIColor) {
        TFontColor = fontColor.withAlphaComponent(1.0)
        self.atributetxt()
    }
    
    
    func alignment_Action(alignment:NSTextAlignment) {
        Talignment = alignment
        self.atributetxt()
    }
    
    
    func Color_Action() {
        self.atributetxt()
    }
    
    func Font_Action(fontStyle:String) {
        TFontname = fontStyle
        TFontstyle = UIFont(name: fontStyle, size: TFontSize)!
        self.atributetxt()
    }
    
    
    
    func FontSize_Action(FontSize:CGFloat) {
        TFontSize = FontSize
        TFontstyle = UIFont(name: TFontname, size: TFontSize)!
        self.atributetxt()
    }
    
    
    
    func atributetxt() {
        self.VerseLbl.attributedText = attributedTextBold(withString: verseTxt, boldString: verseTxt, font: TFontstyle, color:TFontColor, LineGap: TlineGape, align: Talignment, textGape: TtextGape)
        
        self.TitleLbl.attributedText = attributedTextBold(withString: titceTxt, boldString: titceTxt, font: TFontstyle, color:TFontColor, LineGap: TlineGape, align: Talignment, textGape: TtextGape)
    }
    
    
    
    
    func Buttonfram() {
        self.BackgroundVu.isHidden = true
        self.TextVu.isHidden = true
        self.FilterVu.isHidden = true
        self.StickerVuimageVu.isHidden = true
    }
    
        
    
    
    
    func FontTable_Call() {
        
        self.FontTableVu = FontTable.fromNib(named: "FontTable")
        self.FontEditView!.addSubview(self.FontTableVu!)
        self.FontTableVu!.frame = self.FontEditView!.bounds
        self.FontTableVu!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.FontEditView.layer.masksToBounds = true
        
    }
    
    
    
    func ColorVu_Call() {
        self.ColorVu = ColorView.fromNib(named: "ColorView")
        self.FontEditView!.addSubview(self.ColorVu!)
        self.ColorVu!.frame = self.FontEditView!.bounds
        self.ColorVu!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.FontEditView.layer.masksToBounds = true
    }
    
    
    
    
    func Sticker_Call() {
        self.StickerVu = Sticker.fromNib(named: "Sticker")
        self.Commonframe!.addSubview(self.StickerVu!)
        self.StickerVu!.frame = self.Commonframe!.bounds
        self.StickerVu!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.Commonframe.layer.masksToBounds = true
    }
    
    
    
    
    func Filter_Call() {
        
        self.FilterView = Filter.fromNib(named: "Filter")
        self.Commonframe!.addSubview(self.FilterView!)
        self.FilterView!.Bgimage =  self.imageVu.image
        self.FilterView!.frame = self.Commonframe!.bounds
        self.FilterView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.Commonframe.layer.masksToBounds = true
        
    }
    
    
    
    func FontAlign_Call() {
        
        self.fontAlignVu = fontAlign.fromNib(named: "fontAlign")
        
//        self.FontEditView.superview!.convert(self.FontEditView.center, to: self.fontAlignVu!.superview)
        
        self.FontEditView!.addSubview(self.fontAlignVu!)
        self.fontAlignVu!.frame = self.FontEditView!.bounds
        self.fontAlignVu!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.fontAlignVu!.center.x = self.FontEditView.center.x
        self.FontEditView.layer.masksToBounds = true
        
        
        
        
    }
    
    
    
    
    @IBAction func ImageVu_Action(_ sender: Any) {
        self.ColorList = false
        self.imageList.reloadData()
        
//        self.ImageBtn.backgroundColor = Themecolor
//        self.ColorBtn.backgroundColor = .gray.withAlphaComponent(0.6)
    }
    
    
    
    @IBAction func ColorVu_Action(_ sender: Any) {
        self.ColorList = true
        self.imageList.reloadData()
        
//        self.ImageBtn.backgroundColor = .gray.withAlphaComponent(0.6)
//        self.ColorBtn.backgroundColor = Themecolor
        
    }
    
    
    
    
    
    @IBAction func Align_Action(_ sender: Any) {
        self.fontFrame_Init()
        self.AlignBtn.backgroundColor = Themecolor
        self.FontAlign_Call()
    }
    
    
    @IBAction func ColorBtn_Action(_ sender: Any) {
        
        self.fontFrame_Init()
        self.FontColorBtn.backgroundColor = Themecolor
        self.ColorVu_Call()
        
    }
    
    
    func CallColorPicker() {
        let picker = UIColorPickerViewController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    
    
    @IBAction func Style_Action(_ sender: Any) {
        self.fontFrame_Init()
        self.FontstyleBtn.backgroundColor = Themecolor
        
        self.FontTable_Call()
    }
    
    
    
  
    
    
    
    
    @IBAction func Background_Action(_ sender: Any) {
        self.Buttonfram()
        self.BackgroundVu.isHidden = false
        self.Commonframe.isHidden = true
        self.FontMainView.isHidden = true
        self.FontTable_Call()
    }
    
    @IBAction func Text_Action(_ sender: Any) {
        self.Buttonfram()
        self.FontMainView.isHidden = false
        self.TextVu.isHidden = false
        
        self.fontFrame_Init()
        self.AlignBtn.backgroundColor = Themecolor
        self.FontAlign_Call()
    }
    
    @IBAction func Filter_Action(_ sender: Any) {
        self.Buttonfram()
        self.FilterVu.isHidden = false
        self.Commonframe.isHidden = false
        self.FontMainView.isHidden = true
        
        for view in self.Commonframe.subviews {
            view.removeFromSuperview()
        }
        DispatchQueue.main.async {
            self.Filter_Call()
        }
    }
    
    
    @IBAction func Sticker_Action(_ sender: Any) {
        self.Buttonfram()
        self.StickerVuimageVu.isHidden = false
        self.Commonframe.isHidden = false
        self.FontMainView.isHidden = true
        
        for view in self.Commonframe.subviews {
            view.removeFromSuperview()
        }
        self.Sticker_Call()
    }
    
    
    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func Share_Action(_ sender: Any) {

        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    
                    self.StickimageVu.cleanup()
                    self.WatermarkClose.isHidden = true
                    let vc = kStoryboardImageIphone.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
                    vc.OutputImage = self.makeImageFrom(self.Mainview)
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.WatermarkClose.isHidden = false
                    
                    CustomPhotoAlbum.sharedInstance.saveImage(image: self.makeImageFrom(self.Mainview))
                    self.view.makeToast("Image Saved Successfully!", duration: 2.0, position: .center)
                }
            case .denied:
                    SettingAlert.GallaryPermission(SorceVc: self)
            case .restricted:
                SettingAlert.GallaryPermission(SorceVc: self)
            case .notDetermined:
                SettingAlert.GallaryPermission(SorceVc: self)
            case .limited:
                SettingAlert.GallaryPermission(SorceVc: self)
            @unknown default:
                break
            }
        }
        
        
    }
    
    
    func makeImageFrom(_ desiredView: UIView) -> UIImage {
        
        let format = UIGraphicsImageRendererFormat()
        // We need to divide desired size with renderer scale, otherwise you get output size larger @2x or @3x
        let size = CGSize(width: (Mainview.frame.width*3) / format.scale, height: (Mainview.frame.height*3) / format.scale)

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { (ctx) in
        // remake constraints or change size of desiredView to 1080 x 1920
        // handle it's subviews (update font size etc.)
        // ...
        desiredView.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        // undo the size changes
        // ...
        }
        return image
    }

    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    

    
    
    
    func attributedTextBold(withString string: String, boldString: String, font: UIFont,  color:UIColor, LineGap:CGFloat, align: NSTextAlignment, textGape:CGFloat) -> NSAttributedString {
        
        
      let attributedString = NSMutableAttributedString(string: string)
        
      let FontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
      
      let BackgroundColor: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: color]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = LineGap
        paragraphStyle.alignment = align
        
    
        
      let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: textGape, range: range)
        attributedString.addAttributes(FontAttribute, range: range)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
        
        
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
        attributedString.addAttributes(BackgroundColor, range: range)

            
      return attributedString
    }
    
    
    
}


extension IMageEditingPageVc {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.imageList.bounds.height)-14, height: (self.imageList.bounds.height)-16)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
     }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.ColorList {
            return self.BGColor.count
        } else {
            return 16
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = (self.imageList.dequeueReusableCell(withReuseIdentifier: "ImageListCell", for: indexPath) as! ImageCollectionViewCell)
        
            cell.ImageFrameHeight.constant = (self.imageList.bounds.height)-16
            cell.ImageFramewidth.constant = (self.imageList.bounds.height)-14
        
            cell.ViewFrame.layer.cornerRadius = 8
            cell.ViewFrame.layer.masksToBounds = true
            cell.ViewFrame.layer.borderColor = Themecolor.cgColor
        
        if self.ColorList {
            
            cell.ViewFrame.backgroundColor = HexColorConvert.shared.hexStringToUIColor(hex: BGColor[indexPath.row])
            cell.ImageVu!.isHidden = true
            cell.ViewFrame.layer.borderWidth =  (self.SelectedImg == BGColor[indexPath.row] ? 4.0:0.0)
            
        } else {
            cell.ImageVu!.isHidden = false
            cell.ViewFrame.backgroundColor = .clear
            cell.ImageVu!.image = UIImage(named: "S\(indexPath.row+1).jpg")
            cell.ViewFrame.layer.borderWidth =  (self.SelectedImg == "S\(indexPath.row+1).jpg" ? 4.0:0.0)
        }
        

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.ColorList {
            self.SelectedImg = BGColor[indexPath.row]
            self.imageVu.image  = UIImage(named: "White.png")?.withRenderingMode(.alwaysTemplate)
            self.imageVu.tintColor = HexColorConvert.shared.hexStringToUIColor(hex: BGColor[indexPath.row])
        } else {
            self.SelectedImg = "S\(indexPath.row+1).jpg"
            self.imageVu.image = UIImage(named: "S\(indexPath.row+1).jpg")
        }
        self.imageList.reloadData()
    }
    
}




extension IMageEditingPageVc {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        TFontColor = viewController.selectedColor.withAlphaComponent(1.0)
        self.atributetxt()
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        TFontColor = viewController.selectedColor.withAlphaComponent(1.0)
        self.atributetxt()
    }
    
}
