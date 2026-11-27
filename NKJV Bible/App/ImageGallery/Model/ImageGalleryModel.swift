//
//  ImageGalleryModel.swift
//  Smart Bible
//
//  Created by ajayprasanth on 25/07/23.
//

import UIKit

class ImageGalleryModel {
    
    var original:String?
    var large2x:String?
    var large:String?
    var medium:String?
    var small:String?
    var portrait:String?
    var landscape:String?
    var tiny:String?
    
    init(original: String? = nil, large2x: String? = nil, large: String? = nil, medium: String? = nil, small: String? = nil, portrait: String? = nil, landscape: String? = nil, tiny: String? = nil) {
        self.original = original
        self.large2x = large2x
        self.large = large
        self.medium = medium
        self.small = small
        self.portrait = portrait
        self.landscape = landscape
        self.tiny = tiny
    }
    
}
