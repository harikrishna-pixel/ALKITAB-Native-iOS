//
//  Text_List.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 15/10/21.
//

import UIKit

class Text_List: NSObject {
     
    
    static let sharedInstance = Text_List()
    
    var MAinfont:Array<String> = []
    var Subfont:Array<String> = []
    
    
    var AlertTitle:Array<String> = []
    var AlertContent:Array<String> = []
    
    
    func TextList() {
        if let path = Bundle.main.path(forResource: "FontListCount", ofType: "json") {
            do {
                self.MAinfont.removeAll()
                self.Subfont.removeAll()
                
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  let jsonOutput = jsonResult as! Array<AnyObject>
                
                
                for i in 0 ..< jsonOutput.count {
                    let FontInto = jsonOutput[i]
                    self.MAinfont.append(FontInto["Language"] as! String)
                    self.Subfont.append(FontInto["SecondaryLang"] as! String)
                }
                    
                
              } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    func AlertList() {
        if let path = Bundle.main.path(forResource: "QuizAlert", ofType: "json") {
            do {
                self.AlertTitle.removeAll()
                self.AlertContent.removeAll()
                
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  let jsonOutput = jsonResult as! Array<AnyObject>
                
                
                for i in 0 ..< jsonOutput.count {
                    let FontInto = jsonOutput[i]
                    self.AlertTitle.append(FontInto["Title"] as! String)
                    self.AlertContent.append(FontInto["Content"] as! String)
                }
                
              } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
}

