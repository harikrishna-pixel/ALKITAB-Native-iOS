//
//  ImageFilterVar.swift
//  ScannerNew
//
//  Created by Axeraan Technologies on 30/07/21.
//

import UIKit

class ImageFilterVar: NSObject {

    var previewImage: UIImage!
    var thumbnailImageAry: [CIImage]!
    var thumbnailImage: CIImage!
    var thumbnailImages: [UIImage] = []
    var previewedPhotoIndexPath: IndexPath!
    var ciContext = CIContext(options: nil)
    var SubPopup:UIView?
    
    
    var FilterTitle = ["Original","Color1","Color2","Color3","Color4","Color5","Color6","Color7","Color8","Color9","Color10","Color11","Color12","Color13","Color14","Color15"]
    
    
    
    
    let filters: [(name: String, applier: FilterApplierType?)] = [
        (name: "Original",
         applier: nil),
        (name: "Nashville",
         applier: ImageHelper.applyNashvilleFilter),
        (name: "Toaster",
         applier: ImageHelper.applyToasterFilter),
        (name: "1977",
         applier: ImageHelper.apply1977Filter),
        (name: "Clarendon",
         applier: ImageHelper.applyClarendonFilter),
        (name: "HazeRemoval",
         applier: ImageHelper.applyHazeRemovalFilter),
        (name: "Chrome",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectChrome")),
        (name: "Fade",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectFade")),
        (name: "Instant",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectInstant")),
//        (name: "Mono",
//         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectMono")),
//        (name: "Noir",
//         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectNoir")),
        (name: "Process",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectProcess")),
        (name: "Tonal",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectTonal")),
        (name: "Transfer",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectTransfer")),
        (name: "Tone",
         applier: ImageHelper.createDefaultFilterApplier(name: "CILinearToSRGBToneCurve")),
        (name: "Linear",
         applier: ImageHelper.createDefaultFilterApplier(name: "CISRGBToneCurveToLinear")),
        (name: "Tonal",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectTonal")),
        (name: "Black2",
         applier: ImageHelper.BlackFilter2),
        (name: "Black3",
         applier: ImageHelper.BlackFilter3),
        (name: "Black4",
         applier: ImageHelper.BlackFilter4),
        (name: "Black4",
         applier: ImageHelper.BlackFilter5),
        (name: "Mono",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectMono")),
        (name: "Noir",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectNoir")),
        (name: "Black1",
         applier: ImageHelper.BlackFilter1),
        (name: "Original",
         applier: ImageHelper.OriGinalImage),
        (name: "Nashville",
         applier: ImageHelper.applyNashvilleFilter),
        (name: "SepiaTone",
         applier: ImageHelper.SepiaTone),
        (name: "1977",
         applier: ImageHelper.apply1977Filter),
        (name: "Process",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectProcess")),
        (name: "Transfer",
         applier: ImageHelper.createDefaultFilterApplier(name: "CIPhotoEffectTransfer")),
        (name: "Fade1",
         applier: ImageHelper.FadeFilter1),
        (name: "Filter1",
         applier: ImageHelper.Filter1),
        (name: "Filter2",
         applier: ImageHelper.Filter2),
        (name: "Filter3",
         applier: ImageHelper.Filter3),
        (name: "Filter4",
         applier: ImageHelper.Filter4)
                
        
    ]
     
    
    
    
    // MARK: Filter
    func applyFilter(
        applier: FilterApplierType?, ciImage: CIImage) -> UIImage {
        let outputImage: CIImage? = applier!(ciImage)
        
        let outputCGImage = self.ciContext.createCGImage(
            (outputImage)!,
            from: (outputImage?.extent)!)
        return UIImage(cgImage: outputCGImage!)
    }
    
    func applyFilter(
        applier: FilterApplierType?, image: UIImage) -> UIImage {
        let ciImage: CIImage? = CIImage(image: image)
        return applyFilter(applier: applier, ciImage: ciImage!)
    }
    
    func applyFilter(at: Int, image: UIImage) -> UIImage {
        let applier: FilterApplierType? = self.filters[at].applier
        return applyFilter(applier: applier, image: image)
    }

}
