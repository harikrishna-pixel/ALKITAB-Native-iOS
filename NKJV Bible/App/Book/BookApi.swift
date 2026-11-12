//
//  BookApi.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 03/06/24.
//

import UIKit


class BookApi: NSObject {
    static let shared = BookApi()
    
    var BookDictionary: Array<Dictionary<String, AnyObject>> = []
    
    func GetBookCatagory(completion: (() -> Void)? = nil) {
        let appId = resolvedBookAdsAppId()
        guard appId > 0 else {
            completion?()
            return
        }
        let parameters: Dictionary<String, AnyObject> = ["book_app_id": appId as AnyObject]
            
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            completion?()
            return
        }
                NetworkManager.sharedInstance.ImageFromGallery(urlString: "https://saveigm.com/bookads/admin/api/book/book_cat_list_by_app", params: parameters, completion: {(resultDictionary, error) -> () in
                    
                    // OLD CODE - CRASHED IF data WAS NIL OR NOT AN ARRAY:
                    // if let Result:Dictionary<String, AnyObject> = resultDictionary {
                    //     let BookApiDictionary = Result["data"] as! Array<Dictionary<String, AnyObject>>
                    //     let categoryId:[String] =  BookApiDictionary.map({$0["categoryId"] as! String})
                    //     self.GetBooksLink(book_cat_id_List: categoryId)
                    // }
                    
                    // NEW CODE - SAFELY HANDLES MISSING/INVALID DATA:
                    if let Result:Dictionary<String, AnyObject> = resultDictionary,
                       let BookApiDictionary = Result["data"] as? Array<Dictionary<String, AnyObject>>,
                       !BookApiDictionary.isEmpty {
                        // String or number category IDs from the API.
                        let categoryId: [String] = BookApiDictionary.compactMap { self.stringValue(from: $0["categoryId"]) }
                        if !categoryId.isEmpty {
                            self.GetBooksLink(book_cat_id_List: categoryId, completion: completion)
                        } else {
                            print("⚠️ [BookApi] No valid category IDs found in response")
                            completion?()
                        }
                    } else {
                        print("⚠️ [BookApi] Failed to get book categories or empty response: \(error?.localizedDescription ?? "Invalid response format")")
                        completion?()
                    }
                })
    }
    
    
    func GetBooksLink(book_cat_id_List:[String], completion: (() -> Void)? = nil) {
        // Clear in-memory list only. Core Data is replaced after a valid save.
        BookDictionary.removeAll()
        
        // NEW CODE - Handle empty category list
        guard !book_cat_id_List.isEmpty else {
            completion?()
            return
        }
        
        // OLD CODE - HAD RACE CONDITION ISSUES:
        // var LoopPosition = 0
        // BookLoop()
        // 
        // func BookLoop() {
        //     GetBookLoop(book_cat_id:book_cat_id_List[LoopPosition])
        // }
        // 
        // func GetBookLoop(book_cat_id:String) {
        //     let parameters:Dictionary<String, AnyObject> = ["book_cat_id": book_cat_id as AnyObject]
        //     NetworkManager.sharedInstance.ImageFromGallery(urlString: "https://saveigm.com/bookads/admin/api/book/book_list_by_cat", params: parameters, completion: {(resultDictionary, error) -> () in
        //         if let Result:Dictionary<String, AnyObject> = resultDictionary {
        //             self.BookDictionary.append(contentsOf: Result["data"] as! Array<Dictionary<String, AnyObject>>)  // CRASHED IF data WAS NIL
        //             LoopPosition = LoopPosition+1
        //             if LoopPosition < book_cat_id_List.count {
        //                 BookLoop()
        //             } else if LoopPosition >= book_cat_id_List.count {
        //                 self.SaveAllData(BookDictionary: self.BookDictionary, completion: {bookThumbURL,_  in
        //                     self.SaveimageInDirectory(bookThumbURL: bookThumbURL, Folder: "BookImageS")
        //                 })
        //             }
        //         }
        //     })
        // }
        
        // NEW CODE - PROPERLY TRACKS COMPLETION AND HANDLES ERRORS:
        var LoopPosition = 0
        var completedRequests = 0
        let totalRequests = book_cat_id_List.count
        
        BookLoop()
        
        func BookLoop() {
            guard LoopPosition < book_cat_id_List.count else { return }
            GetBookLoop(book_cat_id:book_cat_id_List[LoopPosition])
        }
        
        func GetBookLoop(book_cat_id:String) {
            
            let parameters:Dictionary<String, AnyObject> = ["book_cat_id": book_cat_id as AnyObject]
            NetworkManager.sharedInstance.ImageFromGallery(urlString: "https://saveigm.com/bookads/admin/api/book/book_list_by_cat", params: parameters, completion: {(resultDictionary, error) -> () in
                
                LoopPosition = LoopPosition + 1
                completedRequests = completedRequests + 1
                
                // Safely handle the response
                if let Result:Dictionary<String, AnyObject> = resultDictionary,
                   let dataArray = Result["data"] as? Array<Dictionary<String, AnyObject>> {
                    // Only append if data exists and is valid
                    self.BookDictionary.append(contentsOf: dataArray)
                } else {
                    // Log error but don't crash - API might return empty data for some categories
                    print("⚠️ [BookApi] No data returned for category \(book_cat_id) or invalid response format")
                }
                
                // Check if all requests completed
                if completedRequests >= totalRequests {
                    // All requests done, save data (even if some failed or returned empty)
                    self.SaveAllData(BookDictionary: self.BookDictionary, completion: {bookThumbURL,_  in
                        self.SaveimageInDirectory(bookThumbURL: bookThumbURL, Folder: "BookImageS")
                        completion?()
                    })
                } else if LoopPosition < book_cat_id_List.count {
                    // Continue with next category
                    BookLoop()
                }
            })
        }
    }

    /// book_ads_app_id may be stored as Int or String from getAppInfo.
    private func resolvedBookAdsAppId() -> Int {
        let defaults = UserDefaults.standard
        let asInt = defaults.integer(forKey: "book_ads_app_id")
        if asInt > 0 { return asInt }
        if let text = defaults.string(forKey: "book_ads_app_id"), let value = Int(text), value > 0 {
            defaults.set(value, forKey: "book_ads_app_id")
            return value
        }
        let fallback = FallbackAppConfigConstants.bookAdsAppId
        if fallback > 0 {
            defaults.set(fallback, forKey: "book_ads_app_id")
        }
        return fallback
    }

    private func stringValue(from value: Any?) -> String? {
        if let text = value as? String {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        if let intValue = value as? Int {
            return String(intValue)
        }
        return nil
    }

    private func int16Value(from value: Any?) -> Int16? {
        if let text = value as? String, let parsed = Int16(text) {
            return parsed
        }
        if let number = value as? NSNumber {
            return number.int16Value
        }
        if let intValue = value as? Int {
            return Int16(intValue)
        }
        return nil
    }
    
        
    func SaveAllData(BookDictionary: Array<Dictionary<String, AnyObject>>, completion:@escaping (_ BookImgUrl:[String], _ error:Error?) -> ()) {
        
        DispatchQueue.main.async {
            // OLD CODE - CRASHED IF AppDelegate WAS NIL:
            // guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
            // NEW CODE - RETURNS ERROR INSTEAD OF SILENTLY FAILING:
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                completion([], NSError(domain: "BookApi", code: -1, userInfo: [NSLocalizedDescriptionKey: "AppDelegate not available"]))
                return
            }
            let managedContext = appdelegate.persistentContainer.viewContext

            // Parse first — only wipe/replace when at least one book is valid.
            var parsed: [(thumbURL: String, fileName: String, age: Int16, description: String, id: Int16, name: String, publishedBy: String, url: String, storeTitle: String)] = []
            for item in BookDictionary {
                guard let bookThumbURL = self.stringValue(from: item["bookThumbURL"]),
                      let bookAge = self.int16Value(from: item["book_age"]),
                      let bookId = self.int16Value(from: item["book_id"]),
                      let bookName = self.stringValue(from: item["book_name"]) else {
                    print("⚠️ [BookApi] Skipping book item due to missing/invalid required fields: \(item)")
                    continue
                }
                let imagePath = bookThumbURL.components(separatedBy: "/")
                guard let fileName = imagePath.last, !fileName.isEmpty else {
                    print("⚠️ [BookApi] Invalid image path for book: \(bookName)")
                    continue
                }
                parsed.append((
                    thumbURL: bookThumbURL,
                    fileName: fileName,
                    age: bookAge,
                    description: self.stringValue(from: item["book_description"]) ?? "",
                    id: bookId,
                    name: bookName,
                    publishedBy: self.stringValue(from: item["book_published_by"]) ?? "",
                    url: self.stringValue(from: item["book_url"]) ?? "",
                    storeTitle: self.stringValue(from: item["storeTitle"]) ?? ""
                ))
            }

            guard !parsed.isEmpty else {
                completion([], nil)
                return
            }

            CoreDataModel.sharedInstance.deleteAllData(CDMoreBookApi)
            self.DeleteAllImages(Folder: "BookImageS")

            var validBookThumbURLs: [String] = []
            for book in parsed {
                CoreDataModel.sharedInstance.MoreBookShare(CDMoreBookApi,
                                                           appdelegate: appdelegate,
                                                           managedContext: managedContext,
                                                           bookThumbURL: book.fileName,
                                                           book_age: book.age,
                                                           book_description: book.description,
                                                           book_id: book.id,
                                                           book_name: book.name,
                                                           book_published_by: book.publishedBy,
                                                           book_url: book.url,
                                                           storeTitle: book.storeTitle)
                validBookThumbURLs.append(book.thumbURL)
            }
            completion(validBookThumbURLs, nil)
        }
    
    }
    
    
    
    
    
    
    func SaveimageInDirectory(bookThumbURL:[String], Folder:String) {
        guard !bookThumbURL.isEmpty else {
            self.GetMorApp(completion: {AppImgUrl,_ in
                self.SaveMorAppimageInDirectory(bookThumbURL: AppImgUrl, Folder: "AppimageS")
            })
            return
        }
        var LoopPosition = 0
                
        DownloadImage(ImagePosition: LoopPosition)
        
        func DownloadImage(ImagePosition:Int) {
            DispatchQueue.main.async {
                if let imageURL:URL = URL(string: bookThumbURL[ImagePosition]) {
                    ImageLoader.image(for: imageURL) { image in
                        if self.saveImageInDocsDir(ImageNAme: imageURL.lastPathComponent, image: image!, Folder: Folder) {
                            LoopPosition = LoopPosition+1
                            if LoopPosition < bookThumbURL.count {
                                DownloadImage(ImagePosition:LoopPosition)
                            } else {
                                self.GetMorApp(completion: {AppImgUrl,error in
                                    self.SaveMorAppimageInDirectory(bookThumbURL: AppImgUrl, Folder: "AppimageS")
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    //=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    //=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    
    
    
    
    func GetMorApp(completion:@escaping (_ AppImgUrl:[String], _ error:Error?) -> ()) {
        let parameters:Dictionary<String, AnyObject> = ["package_name": APPLE_ID as AnyObject]
        
        NetworkManager.sharedInstance.ImageFromGallery(urlString: GETMOREAPPLIST, params: parameters, completion: {(resultDictionary, error) -> () in
             
            
            if let Result:Dictionary<String, AnyObject> = resultDictionary {
                DispatchQueue.main.async {
                    CoreDataModel.sharedInstance.deleteAllData(CDMoreAppApi)
                    self.DeleteAllImages(Folder: "AppimageS")
                }
                let BookApiDictionary = Result["data"] as! Array<Dictionary<String, AnyObject>>
               
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) {
                    guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                    let managedContext = appdelegate.persistentContainer.viewContext
                    
                    
                    for item in BookApiDictionary {
                        let imagePath = (item["thumburl"] as! String).components(separatedBy: "/")
                        CoreDataModel.sharedInstance.MoreAppApi(CDMoreAppApi,
                                                                appdelegate: appdelegate,
                                                                managedContext: managedContext,
                                                                appId: Int16(item["appId"] as! String)!,
                                                                appName: item["appName"] as! String,
                                                                apptype: item["apptype"] as! String,
                                                                appurl: item["appurl"] as! String,
                                                                developed_by: item["developed_by"] as! String,
                                                                thumburl: imagePath[imagePath.count-1])
                    }
                    
                    completion(BookApiDictionary.map({$0["thumburl"] as! String}), nil)
                }
            }
        })
    }
    
    
    
    func DeleteAllImages(Folder: String) {
        
        let mainPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let folderPath = mainPath + "/\(Folder)/"

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: URL(string: folderPath)!,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs where fileURL.pathExtension == "jpg" {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch  { print(error) }
    }
    
    
    
    
    func SaveMorAppimageInDirectory(bookThumbURL:[String], Folder:String) {
        var LoopPosition = 0
        
        DownloadImage(ImagePosition: LoopPosition)
        
        func DownloadImage(ImagePosition:Int) {
            DispatchQueue.main.async {
                if bookThumbURL.count > ImagePosition {
                    if let imageURL:URL = URL(string: bookThumbURL[ImagePosition]) {
                        ImageLoader.image(for: imageURL) { image in
                            if self.saveImageInDocsDir(ImageNAme: imageURL.lastPathComponent, image: image!, Folder: Folder) {
                                LoopPosition = LoopPosition+1
                                if LoopPosition < bookThumbURL.count {
                                    DownloadImage(ImagePosition:LoopPosition)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    //=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    //=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    //=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
    

    
    func saveImageInDocsDir(ImageNAme:String, image: UIImage, Folder:String) -> Bool {
        var objCBool: ObjCBool = true
        let mainPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let folderPath = mainPath + "/\(Folder)/"

        let isExist = FileManager.default.fileExists(atPath: folderPath, isDirectory: &objCBool)
        if !isExist {
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageUrl = documentDirectory.appendingPathComponent("\(Folder)/\(ImageNAme)")
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: imageUrl)
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    
    
    
    
}

