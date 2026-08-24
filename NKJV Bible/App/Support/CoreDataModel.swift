//
//  CoreDataModel.swift
//  VCard
//
//  Created by Agna on 17/02/20.
//  Copyright © 2020 Agna. All rights reserved.
//

import UIKit
import CoreData

@available(iOS 13.0, *)
class CoreDataModel: NSObject {
        
    
    @NSManaged public var color_id: String?
    @NSManaged public var note: String?
    
    var VerseInfo:Array<String>  = []
    var MP3_AudioStatus:Array<String>  = []
    var verseStrings:String = ""
    var verseBookName:String = ""
    var BasePath:String = ""
    var BasePathtype:String = "2"
    var copyright_name:String = ""
    var copyright_url:String = ""
    var PayDate:String = ""
    var GetallappInfo:String = ""
     
    var CardAry:Array<String> = []
    
    static let sharedInstance = CoreDataModel()
    
    //////////////////////////////////////////////////////////////////////////////////////////////////  Quiz  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // MARK: -  Get Card Ary
    func GetCardAry(entity:String) -> Array<String> {
        self.CardAry.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            print("result :",result)
                            
                            for data in result as! [NSManagedObject] {
                                let CardCoin = data.value(forKey: "cardCoins") as! Int64
                                let Cardtype = String(format: "%@",(data.value(forKey: "cartType") as? String ?? ""))
                                
                                print("\(CardCoin)_\(Cardtype)")
                                
                                self.CardAry.append("\(CardCoin)_\(Cardtype)")
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.CardAry
          }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    //MARK:  Delete data

    func deleteAllData(_ entity:String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            fetchRequest.returnsObjectsAsFaults = false
            do
            {
                let results = try managedContext.fetch(fetchRequest)
                for managedObject in results
                {

                    let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                    managedContext.delete(managedObjectData)
                }
            } catch let error as NSError {
                print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
            }
    }

    
    
    //MARK:  Delete Bookmark
    func coreDataDeleteBookMark(_ entity:String,bookVerse:String,Bookmark:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
            let predicate = NSPredicate(format: "bookVerse = %@", bookVerse)
           request.predicate = predicate
        
        do
        {
            let results =
                   try managedContext.fetch(request)
            
               let objectUpdate = results[0] as! NSManagedObject
                   objectUpdate.setValue(bookVerse, forKey: "bookVerse")
                   objectUpdate.setValue(Bookmark, forKey: "bookMarked")
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
        
       }
    
    
    
    //MARK: - Delete Note
    func coreDataDeleteNote(_ entity:String,bookVerse:String,notes:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
            let predicate = NSPredicate(format: "bookVerse = %@", bookVerse)
           request.predicate = predicate
        
        do
        {
            let results =
                   try managedContext.fetch(request)
            
               let objectUpdate = results[0] as! NSManagedObject
                   objectUpdate.setValue(bookVerse, forKey: "bookVerse")
                   objectUpdate.setValue(notes, forKey: "note")
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
        
       }
    
    
    
    //MARK: - Delete Color
    func coreDataDeleteColor(_ entity:String,bookVerse:String,color:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
            let predicate = NSPredicate(format: "bookVerse = %@", bookVerse)
           request.predicate = predicate
        
        do
        {
            let results =
                   try managedContext.fetch(request)
            
               let objectUpdate = results[0] as! NSManagedObject
                   objectUpdate.setValue(bookVerse, forKey: "bookVerse")
                   objectUpdate.setValue(color, forKey: "color_id")
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
        
       }
    
    
    
    //MARK: - Delete Color
    func coreDataDeleteUnderline(_ entity:String,bookVerse:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
            let predicate = NSPredicate(format: "bookVerse = %@", bookVerse)
           request.predicate = predicate
        
        do
        {
            let results =
                   try managedContext.fetch(request)
            
               let objectUpdate = results[0] as! NSManagedObject
                   objectUpdate.setValue(bookVerse, forKey: "bookVerse")
                   objectUpdate.setValue(false, forKey: "underLine")
            
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
        
       }
    
    
    
    
    
    
//    MARK: - Insert end-date
      func coreDataInsertEndDate(_ entity:String,endDate:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
            let predicate = NSPredicate(format: "endDate = %@", endDate)
           request.predicate = predicate
        do
        {
            let results =
                   try managedContext.fetch(request)
            if results.count != 0 {
               let objectUpdate = results[0] as! NSManagedObject
                   objectUpdate.setValue(endDate, forKey: "endDate")
             }
            else {
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    user.setValue(endDate, forKey: "endDate")
            }
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }


       }
    
    
    
    
    //MARK: - Insert App info
      func coreDataInsertAppInfo(_ entity:String,image_available:String,multicategory_available:String,quote_available:String,show_MP3_Audio:String,video_app:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
        do
        {
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    user.setValue(image_available, forKey: "image_available")
                    user.setValue(multicategory_available, forKey: "multicategory_available")
                    user.setValue(quote_available, forKey: "quote_available")
                    user.setValue(show_MP3_Audio, forKey: "show_MP3_Audio")
                    user.setValue(video_app, forKey: "video_app")
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
                
       }
    
    
    
    
    
    //MARK: - Insert BibleList
      func coreDataInsert_BibleList(_ entity:String,image_available:String,multicategory_available:String,quote_available:String,show_MP3_Audio:String,video_app:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
        do
        {
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    user.setValue(image_available, forKey: "image_available")
                    user.setValue(multicategory_available, forKey: "multicategory_available")
                    user.setValue(quote_available, forKey: "quote_available")
                    user.setValue(show_MP3_Audio, forKey: "show_MP3_Audio")
                    user.setValue(video_app, forKey: "video_app")
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
                
       }

    
    
    
    
//    langID  langName  langPitch  langRate
    
    //MARK: - Insert Speech Settings
    func coreDataInsertSpeechSettings(_ entity:String,langID:String,langName:String,langPitch:Float,langRate:Float) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
        do
        {
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    user.setValue(langID, forKey: "langID")
                    user.setValue(langName, forKey: "langName")
                    user.setValue(langPitch, forKey: "langPitch")
                    user.setValue(langRate, forKey: "langRate")
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
                
       }
    
    
    
    
    
    
    
    
    //MARK: - Insert data
      func coreDataInsert(_ entity:String,bookVerse:String,color:String,Verses:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
            let predicate = NSPredicate(format: "bookVerse = %@", bookVerse)  // gowtham
           request.predicate = predicate
        
        do
        {
            let results =
                   try managedContext.fetch(request)
            if results.count != 0 {
               let objectUpdate = results[0] as! NSManagedObject
                   objectUpdate.setValue(bookVerse, forKey: "bookVerse")
                   objectUpdate.setValue(color, forKey: "color_id")
                   objectUpdate.setValue(Verses, forKey: "verse")
             }
            else {
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    user.setValue(bookVerse, forKey: "bookVerse")
                    user.setValue(color, forKey: "color_id")
                    user.setValue(Verses, forKey: "verse")
            }
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
       }
    

    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    func coreDataInsert111(_ entity:String,bookVerse:String,color:String,Verses:String) {
          guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
          let managedContext = appdelegate.persistentContainer.viewContext
          let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
          let request = NSFetchRequest<NSFetchRequestResult>()
             request.entity = userEntity
          let predicate = NSPredicate(format: "bookVerse = %@", bookVerse)  // gowtham
         request.predicate = predicate
      
      do
      {
          let results =
                 try managedContext.fetch(request)
          if results.count != 0 {
             let objectUpdate = results[0] as! NSManagedObject
                 objectUpdate.setValue(bookVerse, forKey: "bookVerse")
                 objectUpdate.setValue(color, forKey: "color_id")
                 objectUpdate.setValue(Verses, forKey: "verse")
           }
          else {
              let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                  user.setValue(bookVerse, forKey: "bookVerse")
                  user.setValue(color, forKey: "color_id")
                  user.setValue(Verses, forKey: "verse")
          }
          do {
              try managedContext.save()
          } catch let error  as NSError {
              print("Could not save: \(error),\(error.userInfo)")
             }
          }
      catch
      {
          print(error)
      }
      
     }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    //MARK: - Insert data
      func coreDataInsertNotification(_ entity:String,book:String,verseDate:String,verse:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
        
        do
        {
            let results =
                   try managedContext.fetch(request)
 
            
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    user.setValue(book, forKey: "book")
                    user.setValue(verseDate, forKey: "verseDate")
                    user.setValue(verse, forKey: "verse")
            
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
       }
    
    
    
   //MARK: - More Book Share
   

     func MoreBookShare(_ entity:String, appdelegate: AppDelegate, managedContext: NSManagedObjectContext, bookThumbURL:String, book_age:Int16, book_description:String, book_id:Int16, book_name:String, book_published_by:String, book_url:String, storeTitle:String) {
         
           
           let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
         
       do
       {
           
               let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                   user.setValue(bookThumbURL, forKey: "bookThumbURL")
                   user.setValue(book_age, forKey: "book_age")
                   user.setValue(book_description, forKey: "book_description")
                   user.setValue(book_id, forKey: "book_id")
                   user.setValue(book_name, forKey: "book_name")
                   user.setValue(book_published_by, forKey: "book_published_by")
                   user.setValue(book_url, forKey: "book_url")
                   user.setValue(storeTitle, forKey: "storeTitle")
           
           do {
               try managedContext.save()
           } catch let error  as NSError {
               print("Could not save: \(error),\(error.userInfo)")
              }
           }
       catch
       {
           print(error)
       }
       
      }
   
   
   //MARK: - Get More Book Share
   func GetMoreBookShare(entity:String) -> Array<String> {
       
         self.VerseInfo.removeAll()
               let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
               let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                   request.returnsObjectsAsFaults = false
                       do {
                           let result = try context.fetch(request)
                           
                           for data in result as! [NSManagedObject] {
                               let MarkStatus = String(format: "%@####%i####%i####%@####%@####%@####%@", (data.value(forKey: "bookThumbURL") as? String ?? ""),(data.value(forKey: "book_age") as? Int16 ?? ""), (data.value(forKey: "book_id") as? Int16 ?? ""), (data.value(forKey: "book_name") as? String ?? ""), (data.value(forKey: "book_published_by") as? String ?? ""), (data.value(forKey: "book_url") as? String ?? ""), (data.value(forKey: "storeTitle") as? String ?? ""))
                               
                               self.VerseInfo.append(MarkStatus)
                            }
                       }
                   catch let err as NSError {
                       print(err.debugDescription)
                   }
           return  self.VerseInfo
         }
   
   
   
   
   
   
   
   //MARK: - More Book Share
   

   func MoreAppApi(_ entity:String, appdelegate: AppDelegate, managedContext: NSManagedObjectContext, appId:Int16, appName:String, apptype:String, appurl:String, developed_by:String, thumburl:String) {
         
           let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
         
       do
       {
               let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                   user.setValue(appId, forKey: "appId")
                   user.setValue(appName, forKey: "appName")
                   user.setValue(apptype, forKey: "apptype")
                   user.setValue(appurl, forKey: "appurl")
                   user.setValue(developed_by, forKey: "developed_by")
                   user.setValue(thumburl, forKey: "thumburl")
           do {
               try managedContext.save()
           } catch let error  as NSError {
               print("Could not save: \(error),\(error.userInfo)")
              }
           }
       catch
       {
           print(error)
       }
       
      }
   
   
   //MARK: - Get More Book Share
   func GetAppImageSave(entity:String) -> Array<String> {
         self.VerseInfo.removeAll()
               let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
               let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                   request.returnsObjectsAsFaults = false
                       do {
                           let result = try context.fetch(request)
                           
                           for data in result as! [NSManagedObject] {
                               let MarkStatus = String(format: "%i####%@####%@####%@####%@####%@",(data.value(forKey: "appId") as? Int16 ?? ""), (data.value(forKey: "appName") as? String ?? ""), (data.value(forKey: "apptype") as? String ?? ""), (data.value(forKey: "appurl") as? String ?? ""), (data.value(forKey: "developed_by") as? String ?? ""), (data.value(forKey: "thumburl") as? String ?? ""))
                               
                               self.VerseInfo.append(MarkStatus)
                            }
                       }
                   catch let err as NSError {
                       print(err.debugDescription)
                   }
           return  self.VerseInfo
         }
   
   
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func GetInsertNotification(entity:String) -> Array<String> {
        
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            for data in result as! [NSManagedObject] {
                                let MarkStatus = String(format: "%@_%@_%@",(data.value(forKey: "book") as? String ?? ""),
                                                        (data.value(forKey: "verseDate") as? String ?? ""),
                                                        (data.value(forKey: "verse") as? String ?? ""))
                                
                                self.VerseInfo.append(MarkStatus)
                             }
                        }
                    catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.VerseInfo
          }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///
    ///
    ///
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///
    //MARK: - Insert data Mark As Read
      func coreDataInsertMarkAsRead(_ entity:String,veresInfo:String) {
          
          guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
          let managedContext = appdelegate.persistentContainer.viewContext
          let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
          let request = NSFetchRequest<NSFetchRequestResult>()
             request.entity = userEntity
          let predicate = NSPredicate(format: "veresInfo = %@", veresInfo)  // gowtham
         request.predicate = predicate
      
      do
      {
          let results =
                 try managedContext.fetch(request)
          if results.count != 0 {
             let objectUpdate = results[0] as! NSManagedObject
              managedContext.delete(objectUpdate)
           }
          else {
              let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                user.setValue(veresInfo, forKey: "veresInfo")
          }
          do {
              try managedContext.save()
          } catch let error  as NSError {
              print("Could not save: \(error),\(error.userInfo)")
             }
          }
      catch
      {
          print(error)
      }
          
          
//            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//            let managedContext = appdelegate.persistentContainer.viewContext
//            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
//            let request = NSFetchRequest<NSFetchRequestResult>()
//               request.entity = userEntity
//
//        do
//        {
//            let results =
//                   try managedContext.fetch(request)
//
//                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
//                    user.setValue(veresInfo, forKey: "veresInfo")
//
//            do {
//                try managedContext.save()
//            } catch let error  as NSError {
//                print("Could not save: \(error),\(error.userInfo)")
//               }
//            }
//        catch
//        {
//            print(error)
//        }
//
       }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //MARK: - Insert data
      func coreDataInsertNote(_ entity:String,bookVerse:String,notes:String,Verses:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
            let predicate = NSPredicate(format: "bookVerse = %@", bookVerse)
           request.predicate = predicate
        
        do
        {
            let results =
                   try managedContext.fetch(request)
            if results.count != 0 {
               let objectUpdate = results[0] as! NSManagedObject
                   objectUpdate.setValue(bookVerse, forKey: "bookVerse")
                   objectUpdate.setValue(notes, forKey: "note")
                   objectUpdate.setValue(Verses, forKey: "verse")
             }
            else {
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    user.setValue(bookVerse, forKey: "bookVerse")
                    user.setValue(notes, forKey: "note")
                    user.setValue("#000000", forKey: "color_id")
                    user.setValue(Verses, forKey: "verse")
            }
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
        
       }
    
    
    
    //MARK: - Insert data
      func coreDataInsertBookmarked(_ entity:String,bookVerse:String,Bookmark:String,Verses:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
            let predicate = NSPredicate(format: "bookVerse = %@", bookVerse)
           request.predicate = predicate
          
        do
        {
            let results =
                   try managedContext.fetch(request)
            if results.count != 0 {
               let objectUpdate = results[0] as! NSManagedObject
                   objectUpdate.setValue(bookVerse, forKey: "bookVerse")
                   objectUpdate.setValue(Bookmark, forKey: "bookMarked")
                   objectUpdate.setValue(Verses, forKey: "verse")
             }
            else {
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    user.setValue(bookVerse, forKey: "bookVerse")
                    user.setValue(Bookmark, forKey: "bookMarked")
                    user.setValue("#000000", forKey: "color_id")
                    user.setValue(false, forKey: "underLine")
                    user.setValue(Verses, forKey: "verse")
            }
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
        
       }
    
    
    
    
    //MARK: - Insert UnderLine
    func coreDataInsertUnderLine(_ entity:String,bookVerse:String,Bookmark:String,Verses:String,Underlinestatus:Bool) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
            let predicate = NSPredicate(format: "bookVerse = %@", bookVerse)
           request.predicate = predicate
          
        do
        {
            let results =
                   try managedContext.fetch(request)
            if results.count != 0 {
               let objectUpdate = results[0] as! NSManagedObject
                   objectUpdate.setValue(bookVerse, forKey: "bookVerse")
                   objectUpdate.setValue(Underlinestatus, forKey: "underLine")
                   objectUpdate.setValue(Verses, forKey: "verse")
             }
            else {
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    user.setValue(bookVerse, forKey: "bookVerse")
                    user.setValue(Bookmark, forKey: "bookMarked")
                    user.setValue("#000000", forKey: "color_id")
                    user.setValue(Underlinestatus, forKey: "underLine")
                    user.setValue(Verses, forKey: "verse")
            }
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
        
       }
    
    
    
    
    
    
    
    //MARK: - Remove all data
      func coreDataRemoveAllData(_ entity:String,bookVerse:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
            let predicate = NSPredicate(format: "bookVerse = %@", bookVerse)
           request.predicate = predicate
          
        do
        {
            let results =
                   try managedContext.fetch(request)
            if results.count != 0 {
               let objectUpdate = results[0] as! NSManagedObject
                   objectUpdate.setValue("", forKey: "bookMarked")
                   objectUpdate.setValue("#000000", forKey: "color_id")
                   objectUpdate.setValue("", forKey: "note")
                   objectUpdate.setValue(false, forKey: "underLine")

             }
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
        
       }
    


    
    //MARK: - Insert data
    func coreDataInsertBookListAPI(_ entity:String, biblename:String, language_name:String, bibleContentURL:String, bibleCategoryId:String, isShowMP3Audio:String, language_code:String, is_voice_speech_audio:Int, speech_identifier:String, Audio_Basepath:String, Audio_Basepath_Type:Int, ads_google_banner_id_ios:String, ads_google_interstitial_id_ios:String, ads_google_openApp_id_ios: String, ads_google_reward_id_ios:String, ads_Type:String) {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appdelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
               request.entity = userEntity
        
        do
        {
                           
                let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                    user.setValue(biblename, forKey: "biblename")
                    user.setValue(language_name, forKey: "language_name")
                    user.setValue(bibleContentURL, forKey: "bibleContentURL")
                    user.setValue(bibleCategoryId, forKey: "bibleCategoryId")
                    user.setValue(isShowMP3Audio, forKey: "isShowMP3Audio")
                    user.setValue(language_code, forKey: "language_code")
                    user.setValue(is_voice_speech_audio, forKey: "is_voice_speech_audio_available")
                    user.setValue(speech_identifier, forKey: "speech_identifier")
                    user.setValue(Audio_Basepath, forKey: "app_Audio_Basepath")
                    user.setValue(Audio_Basepath_Type, forKey: "app_Audio_Basepath_Type")
                    user.setValue(copyright_name, forKey: "copyright_name")
                    user.setValue(copyright_url, forKey: "copyright_url")
                    user.setValue(ads_google_banner_id_ios, forKey: "ads_google_banner_id_ios")
                    user.setValue(ads_google_interstitial_id_ios, forKey: "ads_google_interstitial_id_ios")
                    user.setValue(ads_google_openApp_id_ios, forKey: "ads_google_openApp_id_ios")
                    user.setValue(ads_google_reward_id_ios, forKey: "ads_google_reward_id_ios")
                    user.setValue(Int(ads_Type), forKey: "ads_Type")
            
            
            
            do {
                try managedContext.save()
            } catch let error  as NSError {
                print("Could not save: \(error),\(error.userInfo)")
               }
            }
        catch
        {
            print(error)
        }
        
        
       }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func GetMarkasReadStatus(entity:String) -> Array<String> {
        
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            for data in result as! [NSManagedObject] {
                                let MarkStatus = String(format: "%@",(data.value(forKey: "veresInfo") as? String ?? ""))
                                self.VerseInfo.append(MarkStatus)
                             }
                        }
                    catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.VerseInfo
          }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    func GetSavedAppInfo(entity:String) -> String {
        
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            for data in result as! [NSManagedObject] {
                                self.GetallappInfo = String(format: "%@_%@_%@_%@_%@",(data.value(forKey: "image_available") as? String ?? ""),
                                    (data.value(forKey: "multicategory_available") as? String ?? ""),
                                    (data.value(forKey: "quote_available") as? String ?? ""),
                                    (data.value(forKey: "show_MP3_Audio") as? String ?? ""),
                                    (data.value(forKey: "video_app") as? String ?? ""))
                             }
                        }
                    catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.GetallappInfo
          }
    
    
    
    // MARK: - GetSpeech
    func GetSavedSpeechSettings(entity:String) -> String {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            if result.count > 0 {
                                for data in result as! [NSManagedObject] {
                                    self.GetallappInfo = String(format: "%@/%@/%f/%f",(data.value(forKey: "langID") as? String ?? ""),
                                        (data.value(forKey: "langName") as? String ?? ""),
                                        (data.value(forKey: "langPitch") as? Float ?? "1.0"),
                                        (data.value(forKey: "langRate") as? Float ?? "0.5"))
                                 }
                            } else {
                                self.GetallappInfo = "\(TSDefaultlanguage)/\(1.0)/\(0.5)"
                            }

                        }
                    catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.GetallappInfo
          }
    
    
    
    
    // get core data
    func AudioBibleVerse(entity:String,bookname:String) -> Array<String> {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            for data in result as! [NSManagedObject] {
                                
                                if (data.value(forKey: "bookVerse") as! String).contains(bookname) {
                                    let verseStr = String(format: "%@_%@_%@_%@_%@_\(data.value(forKey: "underLine") as? Bool ?? false)",data.value(forKey: "bookVerse") as! String,
                                                      (data.value(forKey: "color_id") as? String ?? ""),
                                                      (data.value(forKey: "note") as? String ?? ""),
                                                      (data.value(forKey: "verse") as? String ?? ""),
                                                      (data.value(forKey: "bookMarked") as? String ?? "")) //
                                                                        
                                self.VerseInfo.append(verseStr)
                             }
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.VerseInfo
          }
    
    
    
    
    // get core data
    func GetAllData(entity:String) -> Array<String> {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            for data in result as! [NSManagedObject] {
                                let verseStr = String(format: "%@_%@_%@_%@_%@_\(data.value(forKey: "underLine") as? Bool ?? false)",data.value(forKey: "bookVerse") as! String,
                                                      (data.value(forKey: "color_id") as? String ?? ""),
                                                      (data.value(forKey: "note") as? String ?? ""),
                                                      (data.value(forKey: "verse") as? String ?? ""),
                                                      (data.value(forKey: "bookMarked") as? String ?? "")) //
                                self.VerseInfo.append(verseStr)
                                
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.VerseInfo
          }
    
    
    
    //  get core data
    
    func GetAllNotificationData(entity:String) -> Array<String> {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            for data in result as! [NSManagedObject] {
                                
                                let verseStr = String(format: "%@_%@_%@",
                                                      (data.value(forKey: "book") as? String ?? ""),
                                                      (data.value(forKey: "verseDate") as? String ?? ""),
                                                      (data.value(forKey: "verse") as? String ?? "")) //
                                self.VerseInfo.append(verseStr)
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.VerseInfo
          }
    
    
    func GetAllNotificationDataTest(entity:String) -> Array<String> {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            for data in result as! [NSManagedObject] {
                                let verseStr = String(format: "%@",
                                                      (data.value(forKey: "verseDate") as? String ?? "")) //
                                self.VerseInfo.append(verseStr)
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.VerseInfo
          }
//
    
    
    
//    func GetAllNotificationData(entity:String) -> Array<String> {
//          self.VerseInfo.removeAll()
//                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//                    request.returnsObjectsAsFaults = false
//                        do {
//                            let result = try context.fetch(request)
//                            for data in result as! [NSManagedObject] {
//                                let verseStr = String(format: "%@**%@**%@",
//                                                      (data.value(forKey: "verseDate") as? String ?? ""), (data.value(forKey: "book") as? String ?? ""), (data.value(forKey: "verse") as? String ?? "")) //
//                                self.VerseInfo.append(verseStr)
//                        }
//                    } catch let err as NSError {
//                        print(err.debugDescription)
//                    }
//            return  self.VerseInfo
//          }
    
    
    
    
    
    
    
    func LastNotificationData(entity:String) -> String {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                                                    
                            for data in result as! [NSManagedObject] {
                                self.verseStrings = String(format: "%@_%@_%@",
                                                      (data.value(forKey: "book") as? String ?? ""),
                                                      (data.value(forKey: "verseDate") as? String ?? ""),
                                                      (data.value(forKey: "verse") as? String ?? ""))
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.verseStrings
          }
    
    
    
    // get core data
    func GetAllBookListAPIData(entity:String) -> Array<String> {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            
                            for data in result as! [NSManagedObject] {
                                let verseStr = String(format: "%@:::%@:::%@:::%@",(data.value(forKey: "biblename") as? String ?? ""),
                                                      (data.value(forKey: "language_name") as? String ?? ""),
                                                      (data.value(forKey: "bibleContentURL") as? String ?? ""),
                                                      (data.value(forKey: "bibleCategoryId") as? String ?? "")) //
                                self.VerseInfo.append(verseStr)
                                
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.VerseInfo
          }
    
    
    
    // get enddate
    func GetEndDate(entity:String) -> String {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            
                            for data in result as! [NSManagedObject] {
                                self.PayDate = String(format: "%@",(data.value(forKey: "endDate") as? String ?? "")) //
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.PayDate
          }
    
    
    
    
//    func GetAllBookListAPIDataAudioStatus(entity:String,Bookname:String) -> String {
//          self.VerseInfo.removeAll()
//                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//                    request.returnsObjectsAsFaults = false
//                        do {
//                            let result = try context.fetch(request)
//
//                            for data in result as! [NSManagedObject] {
//                                let verseStr = String(format: "%@", (data.value(forKey: "bibleCategoryId") as? String ?? ""))
//                                let isShowMP3Audio = String(format: "%@", (data.value(forKey: "isShowMP3Audio") as? String ?? ""))
//                                self.VerseInfo.append(verseStr)
//                                self.MP3_AudioStatus.append(isShowMP3Audio)
//                            }
//                            if APP_TYPE == "1" {
//                                self.verseBookName = "1"
//                            } else {
//                                if self.VerseInfo.count > 2 {
//                                    self.verseBookName = self.MP3_AudioStatus[self.VerseInfo.firstIndex(of: Bookname)!]
//                                } else {
//                                    self.verseBookName = "0"
//                              }
//                            }
//                    } catch let err as NSError {
//                        print(err.debugDescription)
//                    }
//            return self.verseBookName
//          }
    
    
    
//    app_Audio_Basepath
    func GetAllBookListAPIDataTS(entity:String,Bookname:String) -> (VoiceEnable: String,Basepath:String,BasePath_type:String,copyrightName:String,copyrightURL:String) {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                let predicate = NSPredicate(format: "bibleCategoryId = %@", Bookname)
                request.predicate = predicate
        
                        do {
                            let result = try context.fetch(request)
                            
                            for data in result as! [NSManagedObject] {
                                self.verseBookName = String(format: "%i",(data.value(forKey: "is_voice_speech_audio_available") as? Int)!)
                                self.BasePath = data.value(forKey: "app_Audio_Basepath") as! String
                                self.BasePathtype = String(format: "%i",(data.value(forKey: "app_Audio_Basepath_Type") as? Int)!)
                                self.copyright_name = data.value(forKey: "copyright_name") as! String
                                self.copyright_url = data.value(forKey: "copyright_url") as! String
                                
                            }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
        
            return (self.verseBookName,self.BasePath,self.BasePathtype,self.copyright_name,self.copyright_url)
          }
    
    
    
//    func GetSubScriBtionInfo(entity:String,Bookname:String) {
//          self.VerseInfo.removeAll()
//                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//                    request.returnsObjectsAsFaults = false
//                 let predicate = NSPredicate(format: "bibleCategoryId = %@", Bookname)
//                 request.predicate = predicate
//
//                        do {
//                            let result = try context.fetch(request)
//
//                            for data in result as! [NSManagedObject] {
//                                ONE_YEAR_AD_FREE =  data.value(forKey: "sub_identifier_oneyear") as! String
//                                LIFE_TIME_AD_FREE = data.value(forKey: "sub_identifier_lifetime") as! String
//                                SHARED_KEY = data.value(forKey: "sub_sharedsecret") as! String
//
//                                GOOGLE_ADS = data.value(forKey: "ads_google_banner_id_ios") as! String
//                                GOOGLE_ADS_INTERSTITIAL_ID  = data.value(forKey: "ads_google_interstitial_id_ios") as! String
//                                GOOGLE_ADS_REWARDED = data.value(forKey: "ads_google_reward_id_ios") as! String
//                                GOOGLE_ADS_APP_OPEN = data.value(forKey: "ads_google_openApp_id_ios") as! String
//                                GOOGLE_ADS_TYPE = String(format: "%i",(data.value(forKey: "ads_Type") as? Int)!)
//                            }
//                    } catch let err as NSError {
//                        print(err.debugDescription)
//                    }
//          }
    

    
    
    
    
    func GetAllBookListAPIDataAudio(entity:String,Bookname:String) -> String {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                    let predicate = NSPredicate(format: "bibleCategoryId = %@", Bookname)
                    request.predicate = predicate
        
                        do {
                            let result = try context.fetch(request)
                            
                            for data in result as! [NSManagedObject] {
                                self.verseBookName = String(format: "%@",(data.value(forKey: "language_code") as? String ?? ""))
                            }
                            
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
        
            return self.verseBookName
          }
    
    
    
    
    
    
    func GetMp3Status(entity:String) -> String {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            if result.count == 0 {
                                self.verseBookName = "0"
                            }
                            for data in result as! [NSManagedObject] {
                                self.verseBookName = String(format: "%@", (data.value(forKey: "show_MP3_Audio") as? String ?? "0"))
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
            return self.verseBookName
          }
    

    
    // get Bible From Online
    func get_BibleFromOnline(entity:String) -> Array<String> {
          self.VerseInfo.removeAll()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    request.returnsObjectsAsFaults = false
                        do {
                            let result = try context.fetch(request)
                            
                            for data in result as! [NSManagedObject] {
                                let verseStr = String(format: "%@:::%@:::%@:::%@",data.value(forKey: "bibleCategoryId") as! String,
                                                      (data.value(forKey: "bibleContentURL") as? String ?? ""),
                                                      (data.value(forKey: "biblename") as? String ?? ""),
                                                      (data.value(forKey: "language_name") as? String ?? "")) //
                                self.VerseInfo.append(verseStr)
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
            return  self.VerseInfo
          }
    
    
    
    
    // Split Codedata
    func seperateByArray(SeperateValue: String) -> Array<String> {
        let seperatedValue =  SeperateValue.components(separatedBy: "_")
        let color  = seperatedValue[1]
        let note  = seperatedValue[2]
        let verse  = seperatedValue[3]
        let bookmark  = seperatedValue[4]
        let underline  = seperatedValue[5]
        return [color,note,verse,bookmark,underline]
    }
    
    func seperateByArrayBook(SeperateValue: String) -> String {
        let seperatedValue =  SeperateValue.components(separatedBy: "_")
        let name  = seperatedValue[0]
        return name
    }
    
    
    
    
    // MARK: - Verse Explanation

    func saveVerseExplanation(bookVerse: String, bibleVersion: String, explanationText: String, verse: String) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        guard let userEntity = NSEntityDescription.entity(forEntityName: CDVerseExplanation, in: managedContext) else { return }

        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = userEntity
        request.predicate = NSPredicate(format: "bookVerse = %@ AND bibleVersion = %@", bookVerse, bibleVersion)

        do {
            let results = try managedContext.fetch(request)
            let record: NSManagedObject
            if let existing = results.first as? NSManagedObject {
                record = existing
            } else {
                record = NSManagedObject(entity: userEntity, insertInto: managedContext)
                record.setValue(bookVerse, forKey: "bookVerse")
                record.setValue(bibleVersion, forKey: "bibleVersion")
            }
            record.setValue(explanationText, forKey: "explanationText")
            record.setValue(verse, forKey: "verse")
            record.setValue(Date(), forKey: "savedAt")
            try managedContext.save()
        } catch {
            print(error)
        }
    }

    func GetAllExplanations(entity: String) -> Array<String> {
        self.VerseInfo.removeAll()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "savedAt", ascending: false)]

        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let bookVerse = data.value(forKey: "bookVerse") as? String ?? ""
                let bibleVersion = data.value(forKey: "bibleVersion") as? String ?? ""
                let explanationText = data.value(forKey: "explanationText") as? String ?? ""
                let verse = data.value(forKey: "verse") as? String ?? ""
                let savedAt = (data.value(forKey: "savedAt") as? Date ?? Date()).timeIntervalSince1970
                let record = [bookVerse, bibleVersion, explanationText, verse, String(savedAt)].joined(separator: ExplanationRecordDelimiter)
                self.VerseInfo.append(record)
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
        return self.VerseInfo
    }

    func deleteVerseExplanation(bookVerse: String, bibleVersion: String) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appdelegate.persistentContainer.viewContext
        guard let userEntity = NSEntityDescription.entity(forEntityName: CDVerseExplanation, in: managedContext) else { return }

        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = userEntity
        request.predicate = NSPredicate(format: "bookVerse = %@ AND bibleVersion = %@", bookVerse, bibleVersion)

        do {
            let results = try managedContext.fetch(request)
            for case let item as NSManagedObject in results {
                managedContext.delete(item)
            }
            try managedContext.save()
        } catch {
            print(error)
        }
    }

    func saveValidityDate(_ entity:String, Enddate:String, TransactionId:String, StartDate:String, product_id:String)  {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appdelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: entity, in: managedContext)
        let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
                       
        print("Enddate :",Enddate)
        
                user.setValue(Enddate, forKey: "endDate")
                user.setValue(TransactionId, forKey: "transactionId")
                user.setValue(StartDate, forKey: "startDate")
                user.setValue(product_id, forKey: "productId")
    
                do {
                    try managedContext.save()
            } catch let error  as NSError {
                    print("Could not save: \(error),\(error.userInfo)")
        }
    }
    

}



