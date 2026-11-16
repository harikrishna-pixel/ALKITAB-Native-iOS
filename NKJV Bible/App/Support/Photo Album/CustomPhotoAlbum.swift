//
//  CustomPhotoAlbum.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 11/03/21.
//

import UIKit
import Photos

class CustomPhotoAlbum {

    static let albumName = APPNAME
    static let sharedInstance = CustomPhotoAlbum()
    
    var photo: UIImage!
    var photoPHAsset: Array<Any> = []
    var photoPHAssetArray: Array<PHAsset> = []
    var assetCollection: PHAssetCollection!
    var images:Array<UIImage> = []
    private let savedHashDefaultsKey = "CustomPhotoAlbumSavedHashes"
    private var pendingHashes: [UInt64] = []
    private let hashLock = NSLock()

    init() {
        
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            
            if let firstObject: AnyObject = collection.firstObject {
                return (collection.firstObject!)
            }

            return nil
        }

        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }

    func saveImage(image: UIImage, completion: ((Bool) -> Void)? = nil) {

        if assetCollection == nil {
            completion?(false)
            return   // If there was an error upstream, skip the save.
        }

        let imageToSave = image
        DispatchQueue.global(qos: .userInitiated).async {
            // One saved picture stays one Photos item. A second save of the same image is skipped.
            guard let incoming = self.averageHash(for: imageToSave) else {
                self.performSave(imageToSave, completion: completion)
                return
            }
            self.hashLock.lock()
            let alreadySaving = self.pendingHashes.contains(where: { self.hamming($0, incoming) <= 6 })
            if !alreadySaving {
                self.pendingHashes.append(incoming)
            }
            self.hashLock.unlock()
            if alreadySaving || self.albumAlreadyContains(imageToSave) {
                self.hashLock.lock()
                self.pendingHashes.removeAll { self.hamming($0, incoming) <= 6 }
                self.hashLock.unlock()
                self.storeHash(incoming)
                DispatchQueue.main.async { completion?(true) }
                return
            }
            self.performSave(imageToSave) { success in
                self.hashLock.lock()
                self.pendingHashes.removeAll { self.hamming($0, incoming) <= 6 }
                self.hashLock.unlock()
                if success {
                    self.storeHash(incoming)
                }
                completion?(success)
            }
        }
    }

    private func performSave(_ image: UIImage, completion: ((Bool) -> Void)?) {
        // BUG FIX 1 (DUPLICATE IMAGES): OLD CODE - No completion handler, async save not tracked
        /*
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceholder] as NSFastEnumeration)
        }, completionHandler: nil)
        */
        // Problem: Save is ASYNC but no way to know when it completes. If you fetch images
        // immediately after save, you get OLD photos (before save finishes), causing duplicates
        
        // BUG FIX 1 (DUPLICATE IMAGES): NEW CODE - Added completion handler to track save
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset,
                  let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) else {
                return
            }
            albumChangeRequest.addAssets([assetPlaceholder] as NSFastEnumeration)
        }, completionHandler: { success, error in
            if let error = error {
                print("Error saving image: \(error.localizedDescription)")
                completion?(false)
            } else if success {
                print("Image saved successfully")
                completion?(true)
            } else {
                completion?(false)
            }
        })
    }
    
    

    // MARK:- Delete Album
    func deleteAlbum(albumName: String) {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", albumName)
        let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)

        // check if album is available
        if album.firstObject != nil {

            // request to delete album
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.deleteAssetCollections(album)
        }, completionHandler: { (success, error) in
            if success {
                print(" \(albumName) removed successfully")
            } else if error != nil {
                print("request failed. please try again")
            }
        })
        } else {
            print("requested album \(albumName) not found in photos")
        }
    }
    
  
    

    func deleteSelectedPhotoFromGallery(ImageIndex:Int) {
       PHPhotoLibrary.shared().performChanges({
          guard let request = PHAssetCollectionChangeRequest(for: self.assetCollection) else {
                return
            }
           // BUG FIX 8: OLD CODE - Used AND (&&) operator which was wrong logic
           // if ImageIndex < 0 && ImageIndex >= self.photoPHAssetArray.count {
           // Problem: Both conditions can't be true at same time! So check never worked
           // Example: ImageIndex=15, array.count=10 -> (15<0)=false AND (15>=10)=true = FALSE (no return!)
           
           // BUG FIX 8: NEW CODE - Use OR (||) for proper boundary checking
           if ImageIndex < 0 || ImageIndex >= self.photoPHAssetArray.count {
               return
           }
        let asset:PHAsset = self.photoPHAssetArray[ImageIndex]
        
        // BUG FIX 8: OLD CODE - Used IndexSet with wrong index, caused crash with >10 images
        // request.removeAssets(at: IndexSet([ImageIndex]))
        // Problem: IndexSet expected position in collection, not array index
        
        // BUG FIX 8: NEW CODE - Use asset directly which is safer
        request.removeAssets([asset] as NSArray)
        }) { (result, error) in
            // BUG FIX 8: OLD CODE - No error handling, silent failures
            // (empty completion handler)
            
            // BUG FIX 8: NEW CODE - Added error logging
            if let error = error {
                print("Error deleting asset: \(error.localizedDescription)")
            }
        }
        
    }
    
    
    

    
    func fetchCustomAlbumPhotos()
    {
        // BUG FIX 3 (DUPLICATE IMAGES): OLD CODE - Arrays not cleared before fetching
        // (No removeAll() calls here)
        // Problem: Each time fetchCustomAlbumPhotos() called, it APPENDED to existing arrays
        // Result: First save shows all images, second save shows only new image (arrays finally cleared somewhere else)
        
        // BUG FIX 3 (DUPLICATE IMAGES): NEW CODE - Clear all arrays before fetching
        self.images.removeAll()
        self.photoPHAsset.removeAll()
        self.photoPHAssetArray.removeAll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        // No album yet (first launch / save still creating it) — avoid force-cast on empty collection.
        guard let assetCollection = collection.firstObject else { return }

        let photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        let imageManager = PHCachingImageManager()
        var seenLocalIdentifiers = Set<String>()
        var keptHashes: [UInt64] = []
        let extraCopies = NSMutableArray()
        photoAssets.enumerateObjects { (asset, _, _) in
            // Same asset must appear only once (Photos may call the handler more than once).
            guard seenLocalIdentifiers.insert(asset.localIdentifier).inserted else { return }

            let imageSize = CGSize(width: max(asset.pixelWidth, 1),
                                   height: max(asset.pixelHeight, 1))

            /* For faster performance, and maybe degraded image */
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
//                options.deliveryMode = .fastFormat
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true
            imageManager.requestImage(for: asset,
                                      targetSize: imageSize,
                                      contentMode: .aspectFit,
                                      options: options,
                                      resultHandler: { (image, info) -> Void in
                // Photos can return nil (degraded cancel / iCloud / limited access) — never force-unwrap.
                guard let image = image else { return }
                // Skip intermediate/degraded callbacks so one asset does not append twice.
                if let degraded = info?[PHImageResultIsDegradedKey] as? Bool, degraded {
                    return
                }
                // Guard again in case a late callback races after a second fetch cleared arrays.
                if self.photoPHAssetArray.contains(where: { $0.localIdentifier == asset.localIdentifier }) {
                    return
                }
                // Collapse separately saved copies of the same wallpaper, including a slightly different render.
                guard let hash = self.averageHash(for: image) else { return }
                if keptHashes.contains(where: { self.hamming($0, hash) <= 6 }) {
                    extraCopies.add(asset)
                    return
                }
                keptHashes.append(hash)
                self.storeHash(hash)

                self.photo = image
                self.photoPHAssetArray.append(asset)
                self.photoPHAsset.append(asset)
                self.addImgToArray(uploadImage: image)
            })
        }
        deleteDuplicateAssets(extraCopies)
    }

    /// Removes extra Photos copies so the album keeps one of each saved picture.
    private func deleteDuplicateAssets(_ assets: NSArray) {
        guard assets.count > 0 else { return }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets)
        }, completionHandler: nil)
    }

    private func currentAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        return PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject ?? assetCollection
    }

    /// True when the album already holds this picture, so a second save is skipped.
    private func albumAlreadyContains(_ image: UIImage) -> Bool {
        guard let incoming = averageHash(for: image) else { return false }
        guard let collection = currentAlbum() else {
            return storedHashes().contains(where: { self.hamming($0, incoming) <= 6 })
        }
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        let manager = PHCachingImageManager()
        var found = false
        var unreadImages = 0
        assets.enumerateObjects { asset, _, stop in
            guard asset.mediaType == .image else { return }
            guard let thumb = self.imageForDuplicateCheck(asset, manager: manager),
                  let hash = self.averageHash(for: thumb) else {
                unreadImages += 1
                return
            }
            if self.hamming(incoming, hash) <= 6 {
                found = true
                stop.pointee = true
            }
        }
        if found { return true }
        // The old 64px fast thumbnail request failed with Photos error 3303, so a repeat save went through.
        if unreadImages > 0 {
            return storedHashes().contains(where: { self.hamming($0, incoming) <= 6 })
        }
        return false
    }

    /// Reads a real album photo. A fast 64px thumbnail is often missing and comes back as Photos error 3303.
    private func imageForDuplicateCheck(_ asset: PHAsset, manager: PHImageManager) -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.version = .current
        var loaded: UIImage?
        manager.requestImage(for: asset, targetSize: CGSize(width: 160, height: 160), contentMode: .aspectFit, options: options) { image, info in
            let degraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
            let cancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
            if degraded || cancelled { return }
            loaded = image
        }
        if loaded != nil { return loaded }
        manager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
            if let data = data {
                loaded = UIImage(data: data)
            }
        }
        return loaded
    }

    private func storedHashes() -> [UInt64] {
        let values = UserDefaults.standard.array(forKey: savedHashDefaultsKey) as? [String] ?? []
        return values.compactMap { UInt64($0) }
    }

    private func storeHash(_ hash: UInt64) {
        var hashes = storedHashes()
        if hashes.contains(where: { hamming($0, hash) <= 6 }) { return }
        hashes.append(hash)
        UserDefaults.standard.set(hashes.map { String($0) }, forKey: savedHashDefaultsKey)
    }

    /// 8×8 average hash. Copies of one picture stay close even when the render differs a little.
    private func averageHash(for image: UIImage) -> UInt64? {
        let side = 8
        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: nil, width: side, height: side, bitsPerComponent: 8, bytesPerRow: side, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue),
              let buffer = context.data else { return nil }
        context.interpolationQuality = .medium
        context.translateBy(x: 0, y: CGFloat(side))
        context.scaleBy(x: 1, y: -1)
        UIGraphicsPushContext(context)
        image.draw(in: CGRect(x: 0, y: 0, width: side, height: side))
        UIGraphicsPopContext()
        let bytes = buffer.bindMemory(to: UInt8.self, capacity: side * side)
        var total = 0
        for index in 0..<(side * side) { total += Int(bytes[index]) }
        let average = total / (side * side)
        var hash: UInt64 = 0
        for index in 0..<(side * side) {
            if Int(bytes[index]) >= average {
                hash |= 1 << UInt64(index)
            }
        }
        return hash
    }

    private func hamming(_ first: UInt64, _ second: UInt64) -> Int {
        (first ^ second).nonzeroBitCount
    }
    

    func addImgToArray(uploadImage:UIImage)
    {
        self.images.append(uploadImage)
    }
}



extension PHAsset {

    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

