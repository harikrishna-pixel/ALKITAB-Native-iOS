//
//  Image_Bright+Contrast.swift
//  ScannerNew
//
//  Created by Axeraan Technologies on 30/07/21.
//

import UIKit

class Image_Bright_Contrast: NSObject {

    var aCIImage = CIImage();
    var contrastFilter: CIFilter!;
    var brightnessFilter: CIFilter!;
    var context = CIContext();
    var outputImage = CIImage();
    var newUIImage = UIImage();
    var SignatureImg: UIImage!
    var BrightValue:Float = 0
    var ContrastValue:Float = 0
    var RotateValue:Float = 0
    

    
    // MARK: - Image set up
    func ImageSetup(EditImage:UIImage) {
        let aUIImage = EditImage
        let aCGImage = aUIImage.cgImage
        aCIImage = CIImage(cgImage: aCGImage!)
        context = CIContext(options: nil);
        contrastFilter = CIFilter(name: "CIColorControls");
        contrastFilter.setValue(aCIImage, forKey: "inputImage")
        brightnessFilter = CIFilter(name: "CIColorControls");
        brightnessFilter.setValue(aCIImage, forKey: "inputImage")
    }
    
    
    //  Change Bright
    func sliderBrightValueChanged(BrightValue:Float) -> UIImage {
        brightnessFilter.setValue(NSNumber(value: BrightValue), forKey: "inputBrightness");
        outputImage = brightnessFilter.outputImage!;
        let imageRef = context.createCGImage(outputImage, from: outputImage.extent)
        newUIImage = UIImage(cgImage: imageRef!)
        
       return newUIImage
    }
    
    //  Signature fileter
    
    func BlackandWhiteEffect(inputImage: UIImage) -> UIImage? {
           let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
           currentFilter!.setValue(CIImage(image: inputImage), forKey: kCIInputImageKey)
           let output = currentFilter!.outputImage
           let cgimg = self.context.createCGImage(output!,from: output!.extent)
           let processedImage = UIImage(cgImage: cgimg!)
        
           return processedImage
         }
    
    
     
    func ScanedEffect(inputImage: UIImage) -> UIImage? {
           self.ImageSetup(EditImage:inputImage)
           let currentFilter = CIFilter(name: "CIPhotoEffectChrome")
        currentFilter!.setValue(CIImage(image: sliderBrightValueChanged(BrightValue:0.012)), forKey: kCIInputImageKey)
           let output = currentFilter!.outputImage
           let cgimg = self.context.createCGImage(output!,from: output!.extent)
           let processedImage = UIImage(cgImage: cgimg!)
        
           return processedImage
         }
    
    
}


