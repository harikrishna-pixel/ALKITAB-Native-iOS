//
//  WallpaperQuots.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 19/06/24.
//

import UIKit

class WallpaperQuots: NSObject {
    
    
static let sharedInstance = WallpaperQuots()
    
    func Get_Image_Cat_list () {
        let parameters:Dictionary<String, AnyObject> = ["app_id": quote_app_id as AnyObject,
                                                         "device_type": dev_id_type as AnyObject,
                                                         "package_name": bundleID as AnyObject,
                                                        "app_version": appVersion as AnyObject]


        self.ImageFromGallery(urlString: GET_IMAGE_CAT_LIST_BY_APP_ID, params: parameters, completion: {(resultDictionary, error) -> () in

            if resultDictionary != nil {
                                
                let data = resultDictionary!["data"] as! Dictionary<String, AnyObject>
                let img_list = data["category_list"]! as! Array<Dictionary<String, AnyObject>>
                
                
                let Gallerytitle = img_list.map { ($0["category_name"] as? String)! }
                let category_id = img_list.map { ($0["category_id"] as? String)! }
                let Gallary_Api = img_list.map { ($0["cat_thumb_img_url"] as? String)! }

            }
        })
    }
    
    
    func Gallary_Api(category_id:String, completion:@escaping (_ resultDictionary:[String], _ error:Error?) -> ()) {
        
        let parameters:Dictionary<String, AnyObject> = ["category_id": category_id as AnyObject,
                                                         "device_type": dev_id_type as AnyObject,
                                                         "package_name": bundleID as AnyObject,
                                                         "app_version": appVersion as AnyObject,
                                                         "page_limit": "0" as AnyObject]


        self.ImageFromGallery(urlString: IMAGEGALLERY_API, params: parameters, completion: {(resultDictionary, error) -> () in

            if resultDictionary != nil {

                let data = resultDictionary!["data"] as! Dictionary<String, AnyObject>
                let img_list = data["img_list"]! as! Array<Dictionary<String, AnyObject>>
                
                let mediumApi = img_list.map { ($0["image_url"] as? String)! }
                
                completion(mediumApi, nil)
                
            } else {
                completion([], error)
            }
        })
    }
    
    
    
    
    
    func ImageFromGallery(urlString:String, params:Dictionary<String, AnyObject>, completion:@escaping (_ resultDictionary:Dictionary<String,AnyObject>?, _ error:Error?) -> ()) {
        
        
        let param = NetworkManager.sharedInstance.convertParams(toString: params)
        let postData = NSMutableData(data: param!.data(using: String.Encoding.utf8)!)
        
        let headers = [
                    "Content-Type": "application/x-www-form-urlencoded"
                ]
        
           guard let serviceUrl = URL(string: urlString) else { return }
           var request = URLRequest(url: serviceUrl)
           request.httpMethod = "POST"
          request.allHTTPHeaderFields = headers
           request.httpBody = postData as Data
           
           let session = URLSession.shared
           session.dataTask(with: request) { (data, response, error) in
               if error != nil {
                   completion(nil, error)
               }
               if let response = response {
                   print(response)
               }
               if let data = data {
                   do {
                       let json = try JSONSerialization.jsonObject(with: data, options: [])
                       completion((json as! Dictionary<String, AnyObject>), nil)
                   } catch {
                       print(error)
                   }
               }
           }.resume()
     }
    
    
    
}

