//
//  FontStyleViewController.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 13/12/22.
//

import UIKit

class FontStyleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var FontViewTable: UITableView!
    @IBOutlet weak var BannerVu: UIView!
    
    @IBOutlet weak var FontViewSizeSlider: UISlider!
    @IBOutlet weak var FontLabel: UILabel!
    @IBOutlet weak var FontSizeLabel: UILabel!
    @IBOutlet weak var SelectedFont: UILabel!
    @IBOutlet weak var BannerConstrain: NSLayoutConstraint!
    
     
    
    @IBOutlet weak var LineGapSlider: UISlider!
    @IBOutlet weak var LineGapLbl: UILabel!
    
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    let labelContent = "Please adjust to your preferred reading size below."
    var FontTableCell: FontCell?
    var FontListArray:Array<String> = []
    var SubFont:Array<String> = []
    var DefaultFontname:String?
    var Fontsize: CGFloat = 17.0
    var LineGap: CGFloat = 4.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        BannerVu.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
        self.FontViewTable.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        self.view.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        self.SelectedFont.textColor  = (Themecolor == BGNightMode ? .white:.darkGray)
        
        self.BannerConstrain.constant = (StatusbarHeight > 30 ? 90:70)
        
        
        self.FontViewTable.register(UINib(nibName: "FontCell", bundle: nil), forCellReuseIdentifier: "Font")
        self.FontList()
        self.DefaultFontname = UserDefaults.standard.string(forKey: "FontName")
                
        let FontIndex = self.FontListArray.firstIndex(of: self.DefaultFontname!)
        let indexPaths = NSIndexPath(row:FontIndex!, section: 0)
        self.FontViewTable.scrollToRow(at: indexPaths as IndexPath, at: UITableView.ScrollPosition.middle, animated: true)
         
        // BUG FIX: Changed slider event handlers to simpler approach
        // OLD CODE (NOT WORKING): Used complex event-based handlers that didn't trigger properly
        // self.FontViewSizeSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        // self.LineGapSlider.addTarget(self, action: #selector(onSliderLineGapChanged(slider:event:)), for: .valueChanged)
        
        // NEW CODE: Using simple, reliable slider handlers
        self.FontViewSizeSlider.addTarget(self, action: #selector(fontSizeSliderChanged(_:)), for: .valueChanged)
        self.FontViewSizeSlider.addTarget(self, action: #selector(fontSizeSliderReleased(_:)), for: [.touchUpInside, .touchUpOutside])
        
        self.LineGapSlider.addTarget(self, action: #selector(lineGapSliderChanged(_:)), for: .valueChanged)
        self.LineGapSlider.addTarget(self, action: #selector(lineGapSliderReleased(_:)), for: [.touchUpInside, .touchUpOutside])
        
        // Load current values
        self.loadSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload settings each time view appears
        self.loadSettings()
    }
    
    func loadSettings() {
        // BUG FIX: Load font size - use float instead of integer
        // OLD CODE (ISSUE): Used UserDefaults.standard.integer(forKey:) which truncated float values
        // self.FontViewSizeSlider.value = Float(UserDefaults.standard.integer(forKey: "FontSize"))
        // self.FontSizeLabel.text = "Font Size : \(UserDefaults.standard.integer(forKey: "FontSize"))"
        // PROBLEM: When saving 17.5, integer would return 0 or wrong value
        
        // NEW CODE: Properly handle float values with validation
        // Slider range is 15-45, default is 17 (or 21 for iPad)
        let savedFontSize = UserDefaults.standard.float(forKey: "FontSize")
        if savedFontSize >= 15.0 && savedFontSize <= 45.0 {
            self.Fontsize = CGFloat(savedFontSize)
        } else if savedFontSize == 0 {
            // Not set yet, use default based on device
            self.Fontsize = UIDevice.current.userInterfaceIdiom == .pad ? 21.0 : 17.0
        } else {
            self.Fontsize = 17.0
        }
        
        self.FontViewSizeSlider.value = Float(self.Fontsize)
        self.FontSizeLabel.text = "Font Size : \(Int(self.Fontsize))"
        
        print("DEBUG: Loaded font size: \(savedFontSize) -> Using: \(self.Fontsize)")
        
        // BUG FIX: Load line gap - use float instead of integer
        // OLD CODE (ISSUE): Used UserDefaults.standard.integer(forKey:) which truncated float values
        // self.LineGapSlider.value = Float(UserDefaults.standard.integer(forKey: "LineGap"))
        // self.LineGapLbl.text = "Line Gap : \(UserDefaults.standard.integer(forKey: "LineGap"))"
        // PROBLEM: Same issue - integer truncation caused values to be lost
        
        // NEW CODE: Properly handle float values with validation
        // Slider range is 5-30, default is 5
        let savedLineGap = UserDefaults.standard.float(forKey: "LineGap")
        if savedLineGap >= 5.0 && savedLineGap <= 30.0 {
            self.LineGap = CGFloat(savedLineGap)
        } else if savedLineGap == 0 {
            // Not set yet, use default
            self.LineGap = 5.0
        } else {
            self.LineGap = 5.0
        }
        
        self.LineGapSlider.value = Float(self.LineGap)
        self.LineGapLbl.text = "Line Gap : \(Int(self.LineGap))"
        
        print("DEBUG: Loaded line gap: \(savedLineGap) -> Using: \(self.LineGap)")
        
        // Update preview label
        self.FontLabel.attributedText = TextAttribute.shared.attributedLineGap(withString: labelContent, boldString: labelContent, font: UIFont(name: UserDefaults.standard.string(forKey: "FontName")!, size: self.Fontsize)!)
    }
    
    func FontList() {
        Text_List.sharedInstance.TextList()
        self.FontListArray = Text_List.sharedInstance.MAinfont
        self.SubFont = Text_List.sharedInstance.Subfont
        
  
        self.FontViewTable.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.FontListArray.count
      }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
      {
        
        self.FontTableCell = self.FontViewTable.dequeueReusableCell(withIdentifier: "Font") as? FontCell
        
            self.FontTableCell!.FontLabel.text = self.FontListArray[indexPath.row]
            self.FontTableCell!.FontLineVu.backgroundColor = .systemGray4
        
        if self.FontListArray[indexPath.row] == "OTHER FONTS" {
            self.FontTableCell!.selectionStyle = UITableViewCell.SelectionStyle.none
            self.FontTableCell!.FontLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
            self.FontTableCell!.FontLabel.textColor = UIColor.darkGray
            
        } else  {
            self.FontTableCell!.FontLabel.font = UIFont(name:self.FontListArray[indexPath.row], size: 15)
        }

          if DefaultFontname == self.FontListArray[indexPath.row] {
                self.FontTableCell!.FontImage.isHidden = false
            } else {
                self.FontTableCell!.FontImage.isHidden = true
            }
        return self.FontTableCell!
      }

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if self.FontListArray[indexPath.row] != "OTHER FONTS" {
        self.DefaultFontname = self.FontListArray[indexPath.row]
        UserDefaults.standard.set(DefaultFontname, forKey: "FontName")
        UserDefaults.standard.set(self.SubFont[indexPath.row], forKey: "SubFontName")
        self.FontViewTable.deselectRow(at: indexPath, animated: true)
        self.FontViewTable.reloadData()
        // Use the current Fontsize property instead of slider value directly
        self.FontLabel.attributedText = TextAttribute.shared.attributedLineGap(withString: labelContent, boldString: labelContent, font: UIFont(name: UserDefaults.standard.string(forKey: "FontName")!, size: self.Fontsize)!)
        
        App_Protocol.delegateReaderSource?.ReloadFont(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
    }    
}
    

    @IBAction func Back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

}



@available(iOS 11.0, *)
extension FontStyleViewController  {
    
    // MARK: - Font Size Slider Handlers
    
    /* BUG FIX: Replaced complex event-based slider handler with simple direct handler
     
     OLD CODE (NOT WORKING):
     @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
         if let touchEvent = event.allTouches?.first {
             switch touchEvent.phase {
             case .began:
                 break
             case .moved:
                 let fontValue = FontViewSizeSlider.value
                 self.Fontsize = CGFloat(fontValue)
                 self.FontLabel.attributedText = TextAttribute.shared.attributedLineGap(...)
                 self.FontSizeLabel.text = "Font Size : \(Int(self.Fontsize))"
                 UserDefaults.standard.set(self.Fontsize, forKey: "FontSize") // Saved as CGFloat
                 break
             case .ended:
                 App_Protocol.delegateReaderSource?.ReloadFont(...)
                 break
             default:
                 break
             }
         }
     }
     
     PROBLEMS WITH OLD CODE:
     1. Event-based handler with UIEvent parameter wasn't triggering reliably
     2. Saving CGFloat directly instead of Float caused data type mismatch
     3. Complex touch phase switching made debugging difficult
     4. Slider appeared stuck and didn't respond to user input
     */
    
    // NEW CODE: Simple, reliable slider handler
    @objc func fontSizeSliderChanged(_ slider: UISlider) {
        // Called continuously while dragging
        let fontValue = slider.value
        self.Fontsize = CGFloat(fontValue)
        
        // Update UI
        self.FontSizeLabel.text = "Font Size : \(Int(self.Fontsize))"
        self.updatePreviewLabel()
        
        // BUG FIX: Save as Float (not CGFloat) to ensure proper retrieval
        // OLD: UserDefaults.standard.set(self.Fontsize, forKey: "FontSize") // CGFloat
        // NEW: UserDefaults.standard.set(Float(self.Fontsize), forKey: "FontSize") // Float
        UserDefaults.standard.set(Float(self.Fontsize), forKey: "FontSize")
        UserDefaults.standard.synchronize()
        
        print("DEBUG: Font size changed to: \(Float(self.Fontsize))")
    }
    
    @objc func fontSizeSliderReleased(_ slider: UISlider) {
        // Called when user releases the slider
        let fontValue = slider.value
        self.Fontsize = CGFloat(fontValue)
        
        // Final save
        UserDefaults.standard.set(Float(self.Fontsize), forKey: "FontSize")
        UserDefaults.standard.synchronize()
        
        print("DEBUG: Font size finalized at: \(Float(self.Fontsize))")
        
        // Update the reader view
        App_Protocol.delegateReaderSource?.ReloadFont(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
    }
    
    // MARK: - Line Gap Slider Handlers
    
    /* BUG FIX: Replaced complex event-based slider handler with simple direct handler
     
     OLD CODE (NOT WORKING):
     @objc func onSliderLineGapChanged(slider: UISlider, event: UIEvent) {
         if let touchEvent = event.allTouches?.first {
             switch touchEvent.phase {
             case .began:
                 break
             case .moved:
                 let fontValue = LineGapSlider.value
                 self.LineGap = CGFloat(fontValue)
                 self.FontLabel.attributedText = TextAttribute.shared.attributedLineGap(...)
                 self.LineGapLbl.text = "Line Gap : \(Int(self.LineGap))"
                 UserDefaults.standard.set(self.LineGap, forKey: "LineGap") // Saved as CGFloat
                 break
             case .ended:
                 App_Protocol.delegateReaderSource?.ReloadFont(...)
                 break
             default:
                 break
             }
         }
     }
     
     PROBLEMS WITH OLD CODE:
     1. Same issues as font size slider - event handler not triggering
     2. Data type mismatch (CGFloat vs Float)
     3. Slider appeared stuck at default value (5)
     */
    
    // NEW CODE: Simple, reliable slider handler
    @objc func lineGapSliderChanged(_ slider: UISlider) {
        // Called continuously while dragging
        let gapValue = slider.value
        self.LineGap = CGFloat(gapValue)
        
        // Update UI
        self.LineGapLbl.text = "Line Gap : \(Int(self.LineGap))"
        self.updatePreviewLabel()
        
        // BUG FIX: Save as Float (not CGFloat) to ensure proper retrieval
        // OLD: UserDefaults.standard.set(self.LineGap, forKey: "LineGap") // CGFloat
        // NEW: UserDefaults.standard.set(Float(self.LineGap), forKey: "LineGap") // Float
        UserDefaults.standard.set(Float(self.LineGap), forKey: "LineGap")
        UserDefaults.standard.synchronize()
        
        print("DEBUG: Line gap changed to: \(Float(self.LineGap))")
    }
    
    @objc func lineGapSliderReleased(_ slider: UISlider) {
        // Called when user releases the slider
        let gapValue = slider.value
        self.LineGap = CGFloat(gapValue)
        
        // Final save
        UserDefaults.standard.set(Float(self.LineGap), forKey: "LineGap")
        UserDefaults.standard.synchronize()
        
        print("DEBUG: Line gap finalized at: \(Float(self.LineGap))")
        
        // Update the reader view
        App_Protocol.delegateReaderSource?.ReloadFont(ChapterNo:UserDefaults.standard.integer(forKey: "BookChapter"))
    }
    
    // MARK: - Helper Methods
    
    // Helper function to update preview label
    func updatePreviewLabel() {
        self.FontLabel.attributedText = TextAttribute.shared.attributedLineGap(withString: labelContent, boldString: labelContent, font: UIFont(name: UserDefaults.standard.string(forKey: "FontName")!, size: self.Fontsize)!)
    }
    
}
    

