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
        var seenContentFingerprints = Set<Int>()
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
                // Collapse separately saved copies of the same wallpaper (prior double-save bugs).
                let fingerprint = self.contentFingerprint(for: image)
                guard seenContentFingerprints.insert(fingerprint).inserted else { return }

                self.photo = image
                self.photoPHAssetArray.append(asset)
                self.photoPHAsset.append(asset)
                self.addImgToArray(uploadImage: image)
            })
        }
    }
    
    /// Tiny downscale hash so visually identical album copies are listed once.
    private func contentFingerprint(for image: UIImage) -> Int {
        let thumbSize = CGSize(width: 48, height: 48)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: thumbSize, format: format)
        let data = renderer.pngData { _ in
            image.draw(in: CGRect(origin: .zero, size: thumbSize))
        }
        return data.hashValue
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

