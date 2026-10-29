//
//  SearchCollectionMainView.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 13/02/21.
//

import UIKit


@available(iOS 13.4, *)
class SearchCollectionMainView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet var SearchCollectionVu: UICollectionView!
    @IBOutlet var PlaceHolderImg: UIImageView!
    @IBOutlet var AlertLbl:UILabel!
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    var SearchTxt: Array<String> = []
    var corevalue: Array<String> = []
    var corevalueReverced: Array<String> = []
    var coreTitle: String?
    var Searchstring: String = ""
    var LineCount:CGFloat = 0.0
    var LineNote:CGFloat = 0.0
    private var lastContentOffset: CGFloat = 60
    /// My Library → Explanations accordion: which row is open (`nil` = all collapsed).
    private var expandedExplanationIndex: Int? = nil
    
    @IBOutlet weak var ImageHeight: NSLayoutConstraint!
    @IBOutlet weak var ImageWidth: NSLayoutConstraint!
    
    var library = MyLibraryViewController()
    var fontsize: Int = 0
    
    override func draw(_ rect: CGRect) {

        self.AlertLbl.isHidden = true
        self.SearchCollectionVu.allowsSelection = (coreTitle == "Explanations")
        self.SearchCollectionVu.delegate = self
        self.SearchCollectionVu.dataSource = self
        self.PlaceHolderImg.image = UIImage(named: coreTitle ?? "search_PH")

        self.SearchCollectionVu.backgroundColor = (Themecolor == BGNightMode ? BGNightMode:.white)
        
        self.ImageHeight.constant = ScreenWidth/1.6
        self.ImageWidth.constant = ScreenWidth/1.6
        
        self.SearchCollectionVu!.register(UINib(nibName: "SearchCollectionView", bundle: nil), forCellWithReuseIdentifier: "Search")
        self.SearchCollectionVu!.register(UINib(nibName: "Notes", bundle: nil), forCellWithReuseIdentifier: "Notes")
        self.SearchCollectionVu!.register(ExplanationLibraryCell.self, forCellWithReuseIdentifier: ExplanationLibraryCell.reuseId)
        
        // BUG FIX: Use float(forKey:) instead of integer(forKey:) for FontSize
        // OLD CODE: fontsize = UserDefaults.standard.integer(forKey: "FontSize")
        // PROBLEM: integer() truncated float values, returning 0 or incorrect size
        let savedFontSize = UserDefaults.standard.float(forKey: "FontSize")
        fontsize = Int(savedFontSize > 0 ? savedFontSize : 17.0)
        if fontsize == 0 { fontsize = 17 }
        
        
    
        
         self.PlaceHolderImg.image = UIImage(named: "\(coreTitle!).png")
        self.AlertLbl.isHidden = false
        if corevalue.count > 0 && coreTitle! == "BookMark" {
            self.PlaceHolderImg.isHidden = true
            self.AlertLbl.isHidden = true
        } else if corevalue.count > 0 && coreTitle! == "Highlites" {
            self.PlaceHolderImg.isHidden = true
            self.AlertLbl.isHidden = true
        } else if corevalue.count > 0 && coreTitle! == "Notes" {
            self.PlaceHolderImg.isHidden = true
            self.AlertLbl.isHidden = true
        } else if SearchTxt.count > 0 && coreTitle! == "search_PH" {
            self.PlaceHolderImg.isHidden = true
            self.AlertLbl.isHidden = true
        } else if corevalue.count > 0 && coreTitle! == "Underline" {
            self.PlaceHolderImg.isHidden = true
            self.AlertLbl.isHidden = true
        } else if corevalue.count > 0 && coreTitle! == "Explanations" {
            self.PlaceHolderImg.isHidden = true
            self.AlertLbl.isHidden = true
        } else {
            self.SearchCollectionVu.isHidden = true
        }
        
        
        corevalueReverced = corevalue.reversed()
        expandedExplanationIndex = nil
        
        DispatchQueue.main.async {
            self.SearchCollectionVu.collectionViewLayout.invalidateLayout()
            self.SearchCollectionVu.reloadData()
           }
        
    }
    
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
      }

      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Get font size to calculate proper line height
        let savedFontSize = UserDefaults.standard.float(forKey: "FontSize")
        var fontsize = Int(savedFontSize > 0 ? savedFontSize : 17.0)
        if fontsize == 0 { fontsize = 17 }
        let font = UIFont(name: UserDefaults.standard.string(forKey: "FontName")!, size: CGFloat(fontsize) * 1.2) ?? UIFont.systemFont(ofSize: CGFloat(fontsize) * 1.2)
        let lineHeight = font.lineHeight

        if SearchTxt.count != 0 {
            let seperatedValue:Array<String> =  self.SearchTxt[indexPath.row].components(separatedBy: "_")
            
            if SearchTxt.count <= 0 {
                LineCount =  seperatedValue[3].lines()
            } else {
                LineCount =  seperatedValue[0].lines()
            }
            // Use actual line height instead of fixed 20 points, with extra padding
            return CGSize(width: self.SearchCollectionVu.frame.width , height: 70 + (lineHeight * LineCount))
            
        } else {
            if coreTitle == "Explanations" {
                let parts = self.corevalueReverced[indexPath.row].components(separatedBy: ExplanationRecordDelimiter)
                let storedVerse = parts.count > 3 ? parts[3] : ""
                let storedExplanation = parts.count > 2 ? parts[2] : ""
                let explanation = SearchCollectionMainView.librarySummaryText(verse: storedVerse, explanation: storedExplanation)
                let verseText = SearchCollectionMainView.explanationPreviewText(verse: storedVerse, explanation: storedExplanation)
                let fontName = UserDefaults.standard.string(forKey: "FontName")
                let verseFont = UIFont(name: fontName ?? "", size: CGFloat(fontsize)) ?? UIFont.systemFont(ofSize: CGFloat(fontsize))
                let bodyFont = verseFont
                let isExpanded = (expandedExplanationIndex == indexPath.row)
                let height = ExplanationLibraryCell.preferredHeight(
                    width: self.SearchCollectionVu.frame.width,
                    verseText: verseText,
                    explanation: explanation,
                    verseFont: verseFont,
                    bodyFont: bodyFont,
                    isExpanded: isExpanded
                )
                return CGSize(width: self.SearchCollectionVu.frame.width, height: height)
            }

            let seperatedValue:Array<String> =  self.corevalueReverced[indexPath.row].components(separatedBy: "_")
            if seperatedValue[2] != ""  && coreTitle == "Notes" {
                LineCount =  seperatedValue[3].lines()
                LineNote =  seperatedValue[2].Notelines()
                
                // Use actual line height for proper sizing
                return CGSize(width: self.SearchCollectionVu.frame.width , height: 70 + (lineHeight * LineCount) + (20 * LineNote) + 50)
            } else {
                LineCount =  seperatedValue[3].lines()
                // Use actual line height instead of fixed 20 points, with extra padding
                return CGSize(width: self.SearchCollectionVu.frame.width , height: 70 + (lineHeight * LineCount))
            }
        }
      }
      
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.SearchTxt.count > 0 {
            return self.SearchTxt.count
        } else if self.corevalueReverced.count > 0 {
            return self.corevalueReverced.count
        } else {
           return 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if SearchTxt.count != 0 {
            let cell = self.SearchCollectionVu!.dequeueReusableCell(withReuseIdentifier: "Search", for: indexPath) as! SearchCollectionView

            let seperatedValue:Array<String> =  self.SearchTxt[indexPath.row].components(separatedBy: "_")
            
            
            cell.DottedLines.addDashedLine()
            

            if SearchTxt.count <= 0 {
                cell.VerseLbl.text = seperatedValue[3] as String
                
                cell.VerseTitle.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: 15)
                
                
                cell.VerseLbl.attributedText =  TextAttribute.shared.attributedTextBold(withString: seperatedValue[3], boldString: seperatedValue[3], font: cell.VerseTitle.font, line: false, colorStatus: false, color: UIColor.clear)
                
                
                cell.VerseTitle.text = seperatedValue[0].replacingOccurrences(of: "-", with: ":")
                
            } else {

                
                cell.VerseLbl.textColor = (Themecolor == BGNightMode ? .white:.black)
                cell.VerseTitle.textColor = (Themecolor == BGNightMode ? .white:.black)
                
                let newfont:UIFont = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
                
                cell.VerseTitle.text = seperatedValue[1].replacingOccurrences(of: "-", with: ":")
                
                cell.VerseTitle.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: 15)
                
                
                cell.VerseLbl.attributedText = attributedText(withString: seperatedValue[0], boldString: self.Searchstring, font: newfont)
                
                cell.VerseLbl.attributedText =  TextAttribute.shared.attributedTextBoldSearch(withString: "\(seperatedValue[0])", boldString: "\(seperatedValue[0])", ColorString: self.Searchstring, font:UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: CGFloat(fontsize))!, line:false, colorStatus: false, color: UIColor.clear)
                
                
                
            }

            
            
            cell.MenuBtn.tag = indexPath.row
            cell.MenuBtn.addTarget(self, action: #selector(CallMenu), for: .touchUpInside)

            cell.DottedLines.addDashedBorderView()

            return cell

            
        } else {
            if coreTitle == "Explanations" {
                let parts = self.corevalueReverced[indexPath.row].components(separatedBy: ExplanationRecordDelimiter)
                let cell = self.SearchCollectionVu!.dequeueReusableCell(
                    withReuseIdentifier: ExplanationLibraryCell.reuseId,
                    for: indexPath
                ) as! ExplanationLibraryCell

                let isNight = (Themecolor == BGNightMode)
                let fontName = UserDefaults.standard.string(forKey: "FontName")
                let verseFont = UIFont(name: fontName ?? "", size: CGFloat(fontsize)) ?? UIFont.systemFont(ofSize: CGFloat(fontsize))
                let bodyFont = verseFont
                let storedVerse = parts.count > 3 ? parts[3] : ""
                let storedExplanation = parts.count > 2 ? parts[2] : ""
                let reference = (parts.first ?? "").replacingOccurrences(of: "-", with: " ")
                let isExpanded = (expandedExplanationIndex == indexPath.row)

                cell.configure(
                    verseText: SearchCollectionMainView.explanationPreviewText(verse: storedVerse, explanation: storedExplanation),
                    reference: reference,
                    explanation: SearchCollectionMainView.librarySummaryText(verse: storedVerse, explanation: storedExplanation),
                    themeColor: isNight ? .white : Themecolor,
                    isNight: isNight,
                    verseFont: verseFont,
                    bodyFont: bodyFont,
                    menuTint: isNight ? .white : .darkGray,
                    isExpanded: isExpanded
                )
                cell.menuBtn.tag = indexPath.row
                cell.menuBtn.removeTarget(nil, action: nil, for: .allEvents)
                cell.menuBtn.addTarget(self, action: #selector(CallMenu), for: .touchUpInside)
                return cell
            }

            let seperatedValue:Array<String> =  self.corevalueReverced[indexPath.row].components(separatedBy: "_")

            if seperatedValue[2] != ""  && coreTitle == "Notes" {

                let cell = self.SearchCollectionVu!.dequeueReusableCell(withReuseIdentifier: "Notes", for: indexPath) as! Notes

                cell.DottedLines.addDashedLine()
                
                if SearchTxt.count <= 0 {
//                    cell.VerseLbl.text = seperatedValue[3] as String
                    cell.VerseTitle.text = seperatedValue[0].replacingOccurrences(of: "-", with: " ")
                    
                    cell.VerseLbl.attributedText =  TextAttribute.shared.attributedTextBold(withString: seperatedValue[3], boldString: seperatedValue[3], font: cell.VerseTitle.font, line: false, colorStatus: false, color: UIColor.clear)
                    
                    
                } else {
//                    cell.VerseLbl.text = seperatedValue[0]
                    cell.VerseTitle.text = seperatedValue[1].replacingOccurrences(of: "-", with: ":")
                    
                    cell.VerseLbl.attributedText =  TextAttribute.shared.attributedTextBold(withString: seperatedValue[0], boldString: seperatedValue[3], font: cell.VerseTitle.font, line: false, colorStatus: false, color: UIColor.clear)
                }
                
                cell.VerseLbl.textColor = (Themecolor == BGNightMode ? .white:.black)
                cell.VerseTitle.textColor = (Themecolor == BGNightMode ? .white:.black)
                cell.NoteLbl.textColor = (Themecolor == BGNightMode ? .white:.black)
                cell.NoteTitle.textColor = (Themecolor == BGNightMode ? .white:.black)
                cell.NoteLbl.text = seperatedValue[2]
                cell.Noteheight.constant = 17*LineNote
                cell.MenuBtn.tag = indexPath.row
                cell.MenuBtn.addTarget(self, action: #selector(CallMenu), for: .touchUpInside)
                cell.VerseTitle.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: 15)
                cell.VerseLbl.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: CGFloat(fontsize))
                cell.NoteLbl.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: 14)
                
                ImageTint.sharedInstance.imageTintcolorMethod(img: cell.menuImage, colorVu: (Themecolor == BGNightMode ? .white:.darkGray))
                
                return cell

            } else {
                
                let cell = self.SearchCollectionVu!.dequeueReusableCell(withReuseIdentifier: "Search", for: indexPath) as! SearchCollectionView
                
                
                if SearchTxt.count <= 0 {
//                    cell.VerseLbl.text = seperatedValue[3] as String
                    cell.VerseLbl.attributedText =  TextAttribute.shared.attributedTextBold(withString: seperatedValue[3], boldString: seperatedValue[3], font: cell.VerseTitle.font, line: false, colorStatus: false, color: UIColor.clear)
                    
                    cell.VerseTitle.text = seperatedValue[0].replacingOccurrences(of: "-", with: " ")
                } else {
//                    cell.VerseLbl.text = seperatedValue[0]
                    cell.VerseLbl.attributedText =  TextAttribute.shared.attributedTextBold(withString: seperatedValue[0], boldString: seperatedValue[3], font: cell.VerseTitle.font, line: false, colorStatus: false, color: UIColor.clear)
                    
                    cell.VerseTitle.text = seperatedValue[1].replacingOccurrences(of: "_", with: ":")
                }

                cell.MenuBtn.tag = indexPath.row
                cell.MenuBtn.addTarget(self, action: #selector(CallMenu), for: .touchUpInside)
                cell.VerseTitle.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: 15)
                cell.VerseLbl.font = UIFont(name:UserDefaults.standard.string(forKey: "FontName")!, size: CGFloat(fontsize))
                
                
                if coreTitle! == "Highlites" {
                    cell.VerseLbl.attributedText =  TextAttribute.shared.attributedTextBold(withString: "\(seperatedValue[3])", boldString: "\(seperatedValue[3])", font: cell.VerseLbl.font, line:false, colorStatus: true, color: (seperatedValue[1] == "#000000" ? UIColor.clear: hexColorConvert.shared.hexStringToUIColor(hex: seperatedValue[1])))
                    
                } else if coreTitle! == "Underline" {
                    cell.VerseLbl.attributedText =  TextAttribute.shared.attributedTextBold(withString: "\(seperatedValue[3])", boldString: "\(seperatedValue[3])", font: cell.VerseLbl.font, line:true, colorStatus: false, color: .clear)
                }
                

                if coreTitle! == "Highlites" {
                    cell.VerseLbl.textColor = .black
                } else {
                    cell.VerseLbl.textColor = (Themecolor == BGNightMode ? .white:.black)
                }
                
                cell.VerseTitle.textColor = (Themecolor == BGNightMode ? .white:.black)
                ImageTint.sharedInstance.imageTintcolorMethod(img: cell.menuImage, colorVu: (Themecolor == BGNightMode ? .white:.darkGray))
                
                cell.DottedLines.addDashedLine()

                return cell
            }
        }
        
    }

    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
      let attributedString = NSMutableAttributedString(string: string,
                                                 attributes: [NSAttributedString.Key.font: font])
      let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
      let range = (string as NSString).range(of: boldString, options: .caseInsensitive)
        
        let paragraphStyle = NSMutableParagraphStyle()
        // BUG FIX: Use float(forKey:) instead of integer(forKey:) for LineGap
        // OLD CODE: paragraphStyle.lineSpacing = CGFloat(UserDefaults.standard.integer(forKey: "LineGap"))
        // PROBLEM: integer() truncated float values, causing line gap to not apply correctly
        let savedLineGap = UserDefaults.standard.float(forKey: "LineGap")
        paragraphStyle.lineSpacing = CGFloat(savedLineGap > 0 ? savedLineGap : 4.0)
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:range)
        
        attributedString.addAttribute(.foregroundColor, value: DefaultYellow as Any, range: range)
        attributedString.addAttributes(boldFontAttribute, range: range)
      return attributedString
    }
    
    
    
    @objc func CallMenu(sender: UIButton!) {
                
        let dic:[String: String]?
        if self.SearchTxt.count != 0 {
            
            App_Protocol.delegateSearch?.popupvuew(SelectedVerse: self.SearchTxt[sender.tag])
        } else if coreTitle == "Explanations" {
            showExplanationCardMenu(from: sender, record: self.corevalueReverced[sender.tag])
        } else {
            dic = ["CompleteVerseInfo": self.corevalueReverced[sender.tag], "TagSelected": self.coreTitle!]
            App_Protocol.delegateMyLibrary?.popupvuew(SelectedVerse: self.corevalueReverced[sender.tag], SelectedTag: self.coreTitle!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PopupData"),object: nil, userInfo: dic)
        }
    }

    private func showExplanationCardMenu(from source: UIView, record: String) {
        guard let host = window else { return }
        host.viewWithTag(8822104)?.removeFromSuperview()

        let parts = record.components(separatedBy: ExplanationRecordDelimiter)
        let storedVerse = parts.count > 3 ? parts[3] : ""
        let storedExplanation = parts.count > 2 ? parts[2] : ""
        let bookVerse = parts.first ?? ""
        let bibleVersion = parts.count > 1 ? parts[1] : APPNAME
        let bookTitle = bookVerse.replacingOccurrences(of: "-", with: " ")
        let isChapter = SearchCollectionMainView.isNumberedChapterDump(storedVerse)
        let summary = SearchCollectionMainView.librarySummaryText(verse: storedVerse, explanation: storedExplanation)
        let shown = isChapter ? summary : storedVerse

        let menu = ExplanationCardMenu(frame: host.bounds)
        menu.tag = 8822104
        menu.present(
            in: host,
            source: source,
            onCopy: {
                if isChapter {
                    UIPasteboard.general.string = "\(summary)\n\n\(bookTitle)\n\n\(APP_LINK)"
                } else {
                    UIPasteboard.general.string = "\(storedExplanation)\n\n\(shown)\n\n\(bookTitle)\n\n\(APP_LINK)"
                }
                (UIApplication.shared.keyWindow?.rootViewController)?.view.makeToast("Copied successfully", duration: 2.0, position: .top)
            },
            onShare: {
                App_Protocol.delegateReader?.shared(VerseStr: shown, Bookname: bookTitle)
            },
            onRead: {
                UserDefaults.standard.set(bookTitle, forKey: "readdata")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    App_Protocol.delegateReaderSource?.navigateToSelectedVerse()
                }
                App_Protocol.delegateReader?.CloseView()
            },
            onDelete: {
                CoreDataModel.sharedInstance.deleteVerseExplanation(bookVerse: bookVerse, bibleVersion: bibleVersion)
                (UIApplication.shared.keyWindow?.rootViewController)?.view.makeToast("Explanation removed", duration: 2.0, position: .top)
                App_Protocol.delegateMyLibrary?.ReloadAllData()
            }
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard coreTitle == "Explanations", corevalueReverced.count > indexPath.row else { return }
        let previous = expandedExplanationIndex
        if previous == indexPath.row {
            expandedExplanationIndex = nil
        } else {
            expandedExplanationIndex = indexPath.row
        }
        var paths = [indexPath]
        if let previous, previous != indexPath.row, previous < corevalueReverced.count {
            paths.append(IndexPath(row: previous, section: 0))
        }
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: paths)
        }, completion: nil)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if lastContentOffset-10 > scrollView.contentOffset.y {
            NotificationCenter.default.post(name: Notification.Name("ScrollUp"), object: nil)
            
        } else if lastContentOffset < scrollView.contentOffset.y {
            NotificationCenter.default.post(name: Notification.Name("ScrollDown"), object: nil)
        }
        
        if scrollView.contentOffset.y >= 60 {
            lastContentOffset = scrollView.contentOffset.y
        }
    }
}

extension SearchCollectionMainView {
    /// Chapter summaries are saved with every numbered verse in one field. Library cards show the summary only.
    static func isNumberedChapterDump(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let numbered = trimmed.components(separatedBy: .newlines).filter {
            $0.range(of: #"^\s*\d+[\.\)]\s+"#, options: .regularExpression) != nil
        }
        if numbered.count >= 3 { return true }
        guard trimmed.hasPrefix("1.") else { return false }
        if trimmed.range(of: #"(?:\r\n|\n|\r)\s*2[\.\)]"#, options: .regularExpression) != nil { return true }
        if trimmed.range(of: #"\s2[\.\)]\s"#, options: .regularExpression) != nil { return true }
        return false
    }

    static func librarySummaryText(verse: String, explanation: String) -> String {
        let chapterInVerse = SearchCollectionMainView.isNumberedChapterDump(verse)
        let chapterInExplanation = SearchCollectionMainView.isNumberedChapterDump(explanation)
        if chapterInVerse && !chapterInExplanation { return explanation }
        if chapterInExplanation && !chapterInVerse { return verse }
        if chapterInVerse || chapterInExplanation {
            let prose = SearchCollectionMainView.proseWithoutNumberedVerses(explanation)
            return prose.isEmpty ? explanation : prose
        }
        return explanation
    }

    static func proseWithoutNumberedVerses(_ text: String) -> String {
        let kept = text.components(separatedBy: .newlines).filter { line in
            line.range(of: #"^\s*\d+[\.\)]\s+"#, options: .regularExpression) == nil
        }
        return kept.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func explanationPreviewText(verse: String, explanation: String) -> String {
        if SearchCollectionMainView.isNumberedChapterDump(verse) || SearchCollectionMainView.isNumberedChapterDump(explanation) {
            return SearchCollectionMainView.librarySummaryText(verse: verse, explanation: explanation)
        }
        return verse.isEmpty ? explanation : verse
    }
}

private final class ExplanationCardMenu: UIView {

    func present(
        in host: UIView,
        source: UIView,
        onCopy: @escaping () -> Void,
        onShare: @escaping () -> Void,
        onRead: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        frame = host.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
        host.addSubview(self)

        let dismiss = UIButton(type: .custom)
        dismiss.frame = bounds
        dismiss.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dismiss.addTarget(self, action: #selector(close), for: .touchUpInside)
        addSubview(dismiss)

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        addSubview(card)

        let rows: [(String, String, UIColor, () -> Void)] = [
            ("Copy", "doc", UIColor(white: 0.2, alpha: 1), onCopy),
            ("Share", "square.and.arrow.up", UIColor(white: 0.2, alpha: 1), onShare),
            ("Read in Bible", "book", UIColor(white: 0.2, alpha: 1), onRead),
            ("Delete", "trash", UIColor(red: 0.86, green: 0.22, blue: 0.18, alpha: 1), onDelete)
        ]
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        card.addSubview(stack)

        for row in rows {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.contentHorizontalAlignment = .left
            button.tintColor = row.2
            button.setTitleColor(row.2, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            button.setTitle("  \(row.0)", for: .normal)
            let icon = UIImage(systemName: row.1)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
            button.setImage(icon, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            button.heightAnchor.constraint(equalToConstant: 46).isActive = true
            button.addAction(UIAction { [weak self] _ in
                self?.close()
                row.3()
            }, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        let sourceFrame = source.convert(source.bounds, to: host)
        let menuWidth: CGFloat = 196
        let menuHeight: CGFloat = 46 * 4
        var originX = sourceFrame.maxX - menuWidth
        var originY = sourceFrame.maxY + 8
        originX = max(12, min(originX, host.bounds.width - menuWidth - 12))
        if originY + menuHeight > host.bounds.height - 24 {
            originY = max(12, sourceFrame.minY - menuHeight - 8)
        }

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: originX),
            card.topAnchor.constraint(equalTo: topAnchor, constant: originY),
            card.widthAnchor.constraint(equalToConstant: menuWidth),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -6)
        ])
    }

    @objc private func close() {
        removeFromSuperview()
    }
}




