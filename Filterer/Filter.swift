//
//  Filter.swift
//  Filterer
//
//  Created by Paris Kapsouros on 12/4/16.
//  Copyright © 2016 UofT. All rights reserved.
//

import Foundation
import UIKit


protocol Filterable {
    func applyFilter(inout onPixel pixel: Pixel, withIntensity intensity: Int)
}

class Filter : Filterable {
    var intensity: Int
    
    init() {
        self.intensity = 20
    }
    
    init(withIntensity intensity: Int) {
        self.intensity = intensity
    }
    
    
    var intensityPercent : Double {
        get {
            return Double (intensity) / Double(100)
        }
        set {
            self.intensity = Int(newValue)
        }
        
    }
    
    func applyFilter(inout onPixel pixel: Pixel, withIntensity intensity: Int) {
    }
    
    func minMaxRGB(number: Int) -> Int{
        return Int(max(0, min(255, number)))
    }
    func minMaxRGB(number: Float) -> Int{
        return Int(max(0, min(255, number)))
    }
}

class ContrastFilter: Filter {
    
    override init() {
        //set default modifier
        super.init()
        self.intensity = 190
    }
    
    override init(withIntensity intensity: Int) {
        super.init(withIntensity: intensity)
    }
    
    override func applyFilter(inout onPixel pixel: Pixel, withIntensity intensity: Int) {
        super.applyFilter(onPixel: &pixel, withIntensity: intensity)
        
        //calculate the contrast factor found @ http://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/image-processing-algorithms-part-5-contrast-adjustment/
        
        let contrastFactor: Float = (259 * (20 + 255)) / (255 * (259 - 20))
        
        let redVal = Int(pixel.red)
        let blueVal = Int(pixel.blue)
        let greenVal = Int(pixel.green)
        
        //calculate the new RGB values
        var newRed   = contrastFactor * Float((redVal - 128)) + 128
        var newGreen = contrastFactor * Float((greenVal - 128)) + 128
        var newBlue  = contrastFactor * Float((blueVal - 128)) + 128
        
        newBlue = Float(minMaxRGB(newBlue))
        newRed = Float(minMaxRGB(newRed))
        newGreen = Float(minMaxRGB(newGreen))
        
        pixel.red = UInt8(newRed)
        pixel.green = UInt8(newGreen)
        pixel.blue = UInt8(newBlue)
        
    }
    
}

class GrayscaleFilter: Filter {
    
    override func applyFilter(inout onPixel pixel: Pixel, withIntensity intensity: Int) {
        super.applyFilter(onPixel: &pixel, withIntensity: intensity)
        
        //calculate values found @ http://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/image-processing-algorithms-part-3-greyscale-conversion/
        let grayScaleBlue = Float(pixel.blue) * 0.1140
        let grayScaleGreen = Float(pixel.green) * 0.5870
        let grayScaleRed = Float(pixel.red) * 0.2989
        let newPixelColor = UInt8(minMaxRGB(grayScaleRed)) + UInt8(minMaxRGB(grayScaleBlue)) + UInt8(minMaxRGB(grayScaleGreen))
        
        
        pixel.red = newPixelColor
        pixel.blue = newPixelColor
        pixel.green = newPixelColor
    }
}


class GreenFilter: Filter {
    override init() {
        //set default modifier
        super.init()
        self.intensity = 255
    }
    
    override init(withIntensity intensity: Int) {
        super.init(withIntensity: intensity)
    }
    
    override func applyFilter(inout onPixel pixel: Pixel, withIntensity intensity: Int) {
        super.applyFilter(onPixel: &pixel, withIntensity: intensity)
        
        pixel.green = UInt8(max(0, min(255, intensity)))
        
    }
}

class RedFilter: Filter {
    override init() {
        //set default modifier
        super.init()
        self.intensity = 25
    }
    
    override init(withIntensity intensity: Int) {
        super.init(withIntensity: intensity)
    }
    
    override func applyFilter(inout onPixel pixel: Pixel, withIntensity intensity: Int) {
        super.applyFilter(onPixel: &pixel, withIntensity: intensity)
        pixel.red = UInt8(max(0, min(255, intensity)))
        
    }
}

class BlueFilter: Filter {
    override init() {
        //set default modifier
        super.init()
        self.intensity = 145
    }
    
    override init(withIntensity intensity: Int) {
        super.init(withIntensity: intensity)
    }
    
    override func applyFilter(inout onPixel pixel: Pixel, withIntensity intensity: Int) {
        super.applyFilter(onPixel: &pixel, withIntensity: intensity)
        
        pixel.blue = UInt8(max(0, min(255, intensity)))
    }
}

class AlphaFilter: Filter {
    override init() {
        //set default modifier
        super.init()
        self.intensity = 15
    }
    
    override init(withIntensity intensity: Int) {
        super.init(withIntensity: intensity)
    }
    
    override func applyFilter(inout onPixel pixel: Pixel, withIntensity intensity: Int) {
        super.applyFilter(onPixel: &pixel, withIntensity: intensity)
        
        pixel.alpha = UInt8(max(0, min(255, intensity)))
        
    }
}


class ImageProcessor {
    
    var image: UIImage? = nil
    var rgbaImage: RGBAImage?
    
    let filtersByName: [String: Filter] = [
        "blue" : BlueFilter(),
        "red" : RedFilter(),
        "green" : GreenFilter(),
        "grayscale" : GrayscaleFilter(),
        "contrast" : ContrastFilter(),
        "alpha" : AlphaFilter(),
        ];
    var filters: [Filter]
    var stringFilters: [String]
    
    init(withImageNamed imageName:String) {
        self.image = UIImage(named: imageName)!
        if self.image != nil {
            self.rgbaImage = RGBAImage(image: self.image!)!
        }
        self.filters = []
        self.stringFilters = []
    }
    
    init(withUIImage image:UIImage) {
        self.image = image
        if self.image != nil {
            self.rgbaImage = RGBAImage(image: self.image!)!
        }
        self.filters = []
        self.stringFilters = []
    }
    
    func addFilter(aFilter: Filter) {
        self.filters.append(aFilter)
    }
    
    func addStringFilter(stringFilter: String) {
        self.stringFilters.append(stringFilter)
    }
    
    func applyFilters(filtersArr: [Filter]) {
        //check if the user used the predefined filters
        if self.stringFilters.count > 0 {
            for filter in self.stringFilters {
                self.filters.append(self.filtersByName[filter]!)
            }
        }
        
        for y in 0..<self.rgbaImage!.height {
            for x in 0..<self.rgbaImage!.width {
                
                let index = y * self.rgbaImage!.width + x
                var pixel = self.rgbaImage!.pixels[index]
                for filter in self.filters {
                    filter.applyFilter(onPixel: &pixel, withIntensity: filter.intensity)
                    self.rgbaImage!.pixels[index] = pixel
                }
                
            }
        }
    }
    
    func applySingleFilter(aFilter: Filter) {
        for y in 0..<self.rgbaImage!.height {
            for x in 0..<self.rgbaImage!.width {
                let index = y * self.rgbaImage!.width + x
                var pixel = self.rgbaImage!.pixels[index]
                aFilter.applyFilter(onPixel: &pixel, withIntensity: aFilter.intensity)
                self.rgbaImage!.pixels[index] = pixel
            }
        }
    }
}
