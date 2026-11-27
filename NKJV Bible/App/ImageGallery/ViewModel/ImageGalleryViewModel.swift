//
//  ImageGalleryViewModel.swift
//  Smart Bible
//
//  Created by ajayprasanth on 25/07/23.
//

import UIKit

class ImageGalleryViewModel {
     
    static let sharedInstance = ImageGalleryViewModel()

//    static func getRequest(with url: URL, callback: @escaping (Any?) -> Swift.Void) -> Void {
//
//        let defaultConfigObject = URLSessionConfiguration.default
//        defaultConfigObject.timeoutIntervalForRequest = 30.0
//        defaultConfigObject.timeoutIntervalForResource = 60.0
//
//        let session = URLSession.init(configuration: defaultConfigObject, delegate: nil, delegateQueue: nil)
//
//        var urlRequest = URLRequest(url: url as URL)
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        urlRequest.addValue("Authorization", forHTTPHeaderField: "q88siVeO32ziWijVSn0mW8JylPVeVJSYuA38gTJGLwpVzWZe9MIrGMIt")
//
//        urlRequest.httpMethod = "GET"
//        session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
//
//            guard    let httpResponse: HTTPURLResponse = response as? HTTPURLResponse
//                else {
//                    print("Error: did not receive data")
//                    return
//                  }
//
//            var response : (Any)? = nil
//
//            if httpResponse.statusCode == 200 {
//                print(httpResponse)
//
//                guard let responseData = data else {
//                    print("Error: did not receive data")
//                    return
//                }
//
//                do {
//                    let responseData = try JSONSerialization.jsonObject(with: responseData, options: [JSONSerialization.ReadingOptions.allowFragments])
//
//                      response = responseData
//
//                    print("response :",response)
//
//                     callback(response)
//                }
//                catch _ as NSError {
//
//                    let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//                    callback(responseString)
//                    return
//                }
//            }
//            else {
//                print(httpResponse)
//
//                guard error == nil else {
//                    print("error calling GET on /todos/1")
//                    print(error ?? "error")
//                    callback(response!)
//                    return
//                }
//
//            }
//        }).resume()
//    }
    
    
    
    static func getRequest(search:String,completion:@escaping (_ resultDictionary:Array<Dictionary<String,AnyObject>?>, _ error:Error?) -> ()) {
         
        
        var urlRequest = URLRequest(url: URL(string: "https://api.pexels.com/v1/search/?page=1&per_page=60&query=\(search)")!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("q88siVeO32ziWijVSn0mW8JylPVeVJSYuA38gTJGLwpVzWZe9MIrGMIt", forHTTPHeaderField: "Authorization")
        
        urlRequest.httpMethod = "GET"

        URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error -> Void in
            do {
                let responseData = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.allowFragments]) as! Dictionary<String, AnyObject>
                                
                let photosData = responseData["photos"] as! Array<Dictionary<String,AnyObject>>
                let src1 = photosData.map({$0["src"] as! Dictionary<String,AnyObject>})
                
                completion(src1, nil)
                
            } catch {
                print("JSON Serialization error")
            }
        }).resume()
        
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
