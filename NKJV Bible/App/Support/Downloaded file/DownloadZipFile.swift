//
//  DownloadZipFile.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 22/03/21.
//

import UIKit


class DownloadZipFile: NSObject {
    
    
    
static let shared = DownloadZipFile()
    
    
    var ZipArrayString:Array<String>?
    var currDownload: Int64 = -1
    
    
    func DownloadZip(urlString:String) {
        
        let url = URL(string: urlString)
        let fileName = String((url!.lastPathComponent)) as NSString
        // Create destination URL
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
        //Create URL to the source file you want to download
        let fileURL = URL(string: urlString)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let request = URLRequest(url:fileURL!)
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                        
                }
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    do {
                        //Show UIActivityViewController to save the downloaded file
                        let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                        for indexx in 0..<contents.count {
                            if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
                                NotificationCenter.default.post(name: Notification.Name("DownloadCompleted"), object: nil)
                            }
                        }
                    }
                    catch (let err) {
                        print("error: \(err)")
                    }
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
            } else {
                print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
            }
        }
        task.resume()
    }
    
    
    
    func DeleteZip(FileNAme:String){
        let fileManager = FileManager.default
         let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first! as NSURL
         let documentsPath = documentsUrl.path

         do {
             if let documentPath = documentsPath
             {
                 let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                for fileNames in fileNames {
                     if (fileNames.hasSuffix(".zip"))
                     {
                         let filePathName = "\(documentPath)/\(FileNAme)"
                         try fileManager.removeItem(atPath: filePathName)
                     }
                 }

                 let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
             }

         } catch {}
    }
    
    
    func createAFolder(FolderName:String,page:String) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent(FolderName)
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        if page == "SelectBibleViewController" {
            NotificationCenter.default.post(name: Notification.Name("DownloadCompleted"), object: nil)
        } else {
            NotificationCenter.default.post(name: Notification.Name("DownloadFinish"), object: nil)
        }
    }
    
    
    func DownloadedArray() -> Array<String> {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            do {
                // Get the directory contents urls (including subfolders urls)
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
                let mp3Files = directoryContents.filter{ $0.pathExtension == "zip" }
                ZipArrayString = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
        
            } catch {
                print(error)
            }
        
        return ZipArrayString!
    }
    
    
    
    
    func VerifyCount(Foldername:String) -> [String]{
            var items: [String] = []

            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,      FileManager.SearchPathDomainMask.userDomainMask, true)
                let documentsDir = paths[0]
            let zipPath = (documentsDir as NSString).appendingPathComponent("\(Foldername)")
        
        do {
            items = try FileManager.default.contentsOfDirectory(atPath: zipPath)
        } catch {
        
        }
        
        return items
    }
}



extension DownloadZipFile : URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,
    totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) -> Void {
        let percentage = (Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)) * 100
            if Int64(percentage) != currDownload  {
                currDownload = Int64(percentage)
            }
        }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            print("\nFinished download at \(location.absoluteString)!")
      }
}

