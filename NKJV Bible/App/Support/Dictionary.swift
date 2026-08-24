//
//  Dictionary.swift
//
//
//  Created
//  Copyright  All rights reserved.
//

import UIKit
extension Dictionary {
    
    func hasValueForKey(_ key:Key) -> Bool{
        
        if let value = self[key] {
            if value is NSNull {
                return false
            }
            else {
                return true
            }
            
        }
        else {
            return false
        }
    }
    func hasStringForKey(_ key:Key) -> Bool{
        
        if let value = self[key] {
            if value is NSNull {
                return false
            }
            else {
                var strValue = ""
                if let object = self[key] {
                    if object is String {
                        strValue = object as! String
                    }
                    else if object is NSNumber || object is Float || object is Int || object is Double {
                        strValue = String(describing: object)
                    }
                }
                strValue = strValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                if strValue.count > 0 {
                    return true
                }
                else {
                    return false
                }
                
            }
            
        }
        else {
            return false
        }
    }
    
    func stringValueForKey(_ key:Key) -> String {
        var strValue = ""
        
        if let object = self[key] {
            if object is String {
                strValue = object as! String
            }
            else if object is NSNumber || object is Float || object is Int || object is Double {
                strValue = String(describing: object)
            }
        }
        strValue = strValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return strValue
    }
    
    
    var jsonString: String {
        if let dict = (self as? AnyObject) as? Dictionary<String, AnyObject> {
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    return string
                }
            } catch {
                
            }
        }
        return ""
    }
}


