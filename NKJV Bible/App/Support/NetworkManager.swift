//
//  NetworkManager.swift
//  VCard
//
//  Created by Agna on 17/02/20.
//  Copyright © 2020 Agna. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
//import SwiftyJSON
 
@available(iOS 13.0, *)
class NetworkManager: NSObject {
    static let sharedInstance = NetworkManager()
    
    var receiptString:String = ""
    
    
    //MARK:- internet connection check
    func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }

    
    //MARK:- post api call method
//   func requestPOSTData(urlString:String, completion:@escaping (_ resultDictionary:Dictionary<String,AnyObject>?, _ error:Error?) -> ()) {
//
//    let headers = [ "Content-Type": "application/x-www-form-urlencoded" ]
//
//        let postData = NSMutableData(data: "catId=\(wallpaper_id)".data(using: String.Encoding.utf8)!)
//        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
//                                          cachePolicy: .useProtocolCachePolicy,
//                                          timeoutInterval: 60.0)
//        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = headers
//        request.httpBody = postData as Data
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            if (error != nil) {
//                print(error!)
//            } else {
//                let httpResponse = response as? HTTPURLResponse
//                print(httpResponse!)
//
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
//
//                    completion((json as! Dictionary<String, AnyObject>), nil)
//
//                } catch {
//                    print(error)
//                }
//
//            }
//        })
//
//        dataTask.resume()
//
//
//    }
    
   
    
    
    //MARK:- post api call method
   func requestPOSTGETData(urlString:String, params:Dictionary<String, AnyObject>, completion:@escaping (_ resultDictionary:Dictionary<String,AnyObject>?, _ error:Error?) -> ()) {
       
       let headers = [
                   "Content-Type": "application/x-www-form-urlencoded"
               ]
       
       let param = self.convertParams(toString: params)
       let postData = NSMutableData(data: param!.data(using: String.Encoding.utf8)!)
           let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
                                             cachePolicy: .useProtocolCachePolicy,
                                             timeoutInterval: 60.0)
           request.httpMethod = "POST"
           request.allHTTPHeaderFields = headers
           request.httpBody = postData as Data

           let session = URLSession.shared
           let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
               if (error != nil) {
                   print(error!)
               } else {
                   let httpResponse = response as? HTTPURLResponse
                   print(httpResponse!)

                   do {
                       let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                       completion((json as! Dictionary<String, AnyObject>), nil)
                       
                   } catch {
                       print(error)
                   }

               }
           })

           dataTask.resume()
       
        
       }
    
    
    
    //MARK:- post api call method
    func requestPOSTTestData(urlString:String, params:Dictionary<String, AnyObject>, completion:@escaping ( _ resultDictionary:Dictionary<String,AnyObject>?,  _ error:Error?) -> ()) {

       let headers = [
                   "Content-Type": "application/x-www-form-urlencoded"
               ]
          
          guard let fileUrl = URL(string: urlString) else { return }
          
          
                 
       let param = self.convertParams(toString: params)
       let postData = NSMutableData(data: param!.data(using: String.Encoding.utf8)!)
          let request = NSMutableURLRequest(url: fileUrl as URL,
                                             cachePolicy: .useProtocolCachePolicy,
                                             timeoutInterval: 60.0)
           request.httpMethod = "POST"
           request.allHTTPHeaderFields = headers
           request.httpBody = postData as Data

           let session = URLSession.shared
           let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
               if (error != nil) {
                   print(error?.localizedDescription)
               } else {
                   let httpResponse = response as? HTTPURLResponse
                   print(httpResponse!)
               
                   do {
                       let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                       completion((json as! Dictionary<String, AnyObject>), nil)
                       
                   } catch {
          print(error)
                   }

               }
           })

           dataTask.resume()
       
        
       }
    
    
    //MARK:- post api payment method
        func requestUpdateDeviceToIOS(urlString:String,parameters:inout Dictionary<String,AnyObject>, completion:@escaping (_ resultDictionary:Dictionary<String,AnyObject>?, _ error:Error?) -> ()) {
            
                 
           let urlComponent = URLComponents(string: urlString)!
            let headers = [ "Content-Type": "application/json"]

           var request = URLRequest(url: urlComponent.url!)
           request.httpMethod = "POST"
           request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
           request.allHTTPHeaderFields = headers
            
            AF.request(request).responseJSON { response in
                        switch response.result {
                        case .success:
                            
                            if let JSON = response.result as? Dictionary<String,AnyObject> {
                                
                                completion(JSON, nil)
                            }
                            else {
                                completion(nil, response.error! as Error)
                            }
                        case .failure( _):
                            completion(nil, response.error! as Error)
                        }
                    }
            }
    

    
    
    
    
  
    
    

    
    
  
    
    //MARK:- post api payment method
        func requestBibleBooK(urlString:String, completion:@escaping (_ resultDictionary:Dictionary<String,AnyObject>?, _ error:Error?) -> ()) {
            
           let urlComponent = URLComponents(string: urlString)!
            let headers = [ "Content-Type": "application/json"]

           var request = URLRequest(url: urlComponent.url!)
           request.httpMethod = "POST"
           request.allHTTPHeaderFields = headers
            
            AF.request(request).responseJSON { response in
                
                
                        switch response.result {
                        case .success:
                            
                            if let JSONs = response.value as? Dictionary<String,AnyObject> {
                                   completion(JSONs, nil)
                                }
                            else {
                                completion(nil, response.error! as Error)
                            }
                        case .failure(let error):
                            completion(nil, response.error! as Error)
                        }
                    }
            
            }
    
    
    

    
    
    func convertParams(toString parameters: Dictionary<String, AnyObject>) -> String? {
    
        let cookieHeader = (parameters.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }) as Array).joined(separator: "&")
        
        
       return cookieHeader
    }
    
    
    
  
    
    func GetPay_History(url: String,completion:@escaping (_ resultDictionary:Dictionary<String,AnyObject>?, _ error:Error?) -> ()) {

        print("GetReceptKey.shared.ReceptId :",GetReceptKey.shared.ReceptId())
        print("SHARED_SECRET :",SHARED_SECRET)
        
        
        let recept = GetReceptKey.shared.ReceptId()
        let urlComponent = URLComponents(string: url)!
        let parameters = ["password":SHARED_SECRET,
                          "receipt-data": recept ] as [String : AnyObject]


            let headers = [ "Content-Type": "application/json"]
            var request = URLRequest(url: urlComponent.url!)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            request.allHTTPHeaderFields = headers

                      AF.request(request).responseJSON { response in

                          switch response.result {
                          case .success:

                              if let JSON = response.value as? Dictionary<String,AnyObject>{
                                completion(JSON, nil)
                              }
                              else {
                                  completion(nil, response.error! as Error)
                              }
                          case .failure(let error):
                              completion(nil, response.error! as Error)
                          }
                      }
           }
    
    
    
    
    
    
    //MARK: - Post Subscription Receipt Data
    
   func SubscriptionGetReceipt(urlString:String, params:Dictionary<String, AnyObject>, completion:@escaping (_ resultDictionary:Dictionary<String,AnyObject>?, _ error:Error?) -> ()) {
   
       let param = self.convertParams(toString: params)
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
                  print("error :",error?.localizedDescription)
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
   
    
    
    func SubscriptionInsertReceipt(urlString:String, params:Dictionary<String, AnyObject>, completion:@escaping (_ resultDictionary:Dictionary<String,AnyObject>?, _ error:Error?) -> ()) {
        
        
        let param = self.convertParams(toString: params)
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
                   print("error :",error?.localizedDescription)
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
    
    
    
    
    // =>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    // =>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    // =>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    
    
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
                   print("error :",error?.localizedDescription)
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

    
