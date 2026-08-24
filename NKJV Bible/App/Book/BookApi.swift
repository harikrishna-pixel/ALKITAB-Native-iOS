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
    
    func GetBookCatagory() {
        
        if UserDefaults.standard.integer(forKey: "book_ads_app_id") > 0 {
            let parameters:Dictionary<String, AnyObject> = ["book_app_id": UserDefaults.standard.integer(forKey: "book_ads_app_id") as AnyObject]
            
            
            if NetworkManager.sharedInstance.isConnectedToInternet() {
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
                        // Safely extract category IDs - skip invalid ones
                        let categoryId:[String] = BookApiDictionary.compactMap({$0["categoryId"] as? String})
                        if !categoryId.isEmpty {
                            self.GetBooksLink(book_cat_id_List: categoryId)
                        } else {
                            print("⚠️ [BookApi] No valid category IDs found in response")
                        }
                    } else {
                        print("⚠️ [BookApi] Failed to get book categories or empty response: \(error?.localizedDescription ?? "Invalid response format")")
                    }
                })
            }
        }
    }
    
    
    func GetBooksLink(book_cat_id_List:[String]) {
        
        DispatchQueue.main.async {
            self.BookDictionary.removeAll()
            CoreDataModel.sharedInstance.deleteAllData(CDMoreBookApi)
            self.DeleteAllImages(Folder: "BookImageS")
        }
        
        // NEW CODE - Handle empty category list
        guard !book_cat_id_List.isEmpty else {
            // No categories, call SaveAllData with empty array
            self.SaveAllData(BookDictionary: [], completion: {bookThumbURL,_  in
                self.SaveimageInDirectory(bookThumbURL: bookThumbURL, Folder: "BookImageS")
            })
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
                    })
                } else if LoopPosition < book_cat_id_List.count {
                    // Continue with next category
                    BookLoop()
                }
            })
        }
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
            
            DispatchQueue.main.async {
                CoreDataModel.sharedInstance.deleteAllData(CDMoreBookApi)
                self.DeleteAllImages(Folder: "BookImageS")
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) {
                // OLD CODE - CRASHED ON MISSING FIELDS:
                // for item in BookDictionary {
                //     let imagePath = (item["bookThumbURL"] as! String).components(separatedBy: "/")  // CRASHED IF bookThumbURL WAS NIL
                //     CoreDataModel.sharedInstance.MoreBookShare(CDMoreBookApi,
                //                                                appdelegate: appdelegate,
                //                                                managedContext: managedContext,
                //                                                bookThumbURL: imagePath[imagePath.count-1],
                //                                                book_age: Int16(item["book_age"] as! String)!,  // CRASHED IF book_age WAS NIL/INVALID
                //                                                book_description: item["book_description"] as! String,  // CRASHED IF NIL
                //                                                book_id: Int16(item["book_id"] as! String)!,  // CRASHED IF book_id WAS NIL/INVALID
                //                                                book_name: item["book_name"] as! String,
                //                                                book_published_by: item["book_published_by"] as! String,
                //                                                book_url: item["book_url"] as? String,
                //                                                storeTitle: item["storeTitle"] as? String)
                // }
                // completion(BookDictionary.map({$0["bookThumbURL"] as! String}), nil)  // CRASHED IF ANY ITEM MISSING bookThumbURL
                
                // NEW CODE - SAFELY VALIDATES ALL FIELDS BEFORE PROCESSING:
                var validBookThumbURLs: [String] = []
                
                for item in BookDictionary {
                    // Safely unwrap all required fields - skip items with missing data
                    guard let bookThumbURL = item["bookThumbURL"] as? String,
                          !bookThumbURL.isEmpty,
                          let bookAgeString = item["book_age"] as? String,
                          let bookAge = Int16(bookAgeString),
                          let bookDescription = item["book_description"] as? String,
                          let bookIdString = item["book_id"] as? String,
                          let bookId = Int16(bookIdString),
                          let bookName = item["book_name"] as? String,
                          let bookPublishedBy = item["book_published_by"] as? String,
                          let bookUrl = item["book_url"] as? String,
                          let storeTitle = item["storeTitle"] as? String else {
                        // Skip items with missing required fields instead of crashing
                        print("⚠️ [BookApi] Skipping book item due to missing/invalid required fields: \(item)")
                        continue
                    }
                    
                    let imagePath = bookThumbURL.components(separatedBy: "/")
                    guard !imagePath.isEmpty else {
                        print("⚠️ [BookApi] Invalid image path for book: \(bookName)")
                        continue
                    }
                    
                    CoreDataModel.sharedInstance.MoreBookShare(CDMoreBookApi,
                                                               appdelegate: appdelegate,
                                                               managedContext: managedContext,
                                                               bookThumbURL: imagePath[imagePath.count-1],
                                                               book_age: bookAge,
                                                               book_description: bookDescription,
                                                               book_id: bookId,
                                                               book_name: bookName,
                                                               book_published_by: bookPublishedBy,
                                                               book_url: bookUrl,
                                                               storeTitle: storeTitle)
                    
                    validBookThumbURLs.append(bookThumbURL)
                }
                
                completion(validBookThumbURLs, nil)
            }
        }
    
    }
    
    
    
    
    
    
    func SaveimageInDirectory(bookThumbURL:[String], Folder:String) {
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

