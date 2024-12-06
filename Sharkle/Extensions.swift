//
//  AnimatedView.swift
//  Sharkle
//
//  Created by Peter Wunder on 21.04.17.
//  Copyright © 2017 Peter Wunder. All rights reserved.
//

import Cocoa

extension NSView {
    // This makes an NSView loop through an Array of NSImages for x seconds and y times and optionally executes a completion block afterwards
    func animate(withImages images: [NSImage], andDuration duration: Double, repeatTimes repeats: Float = Float.infinity, beginTime: CFTimeInterval? = nil) {
        self.layer = CALayer()
        self.wantsLayer = true
        
        let animLayer = CALayer()
        animLayer.name = "animation"
        animLayer.borderColor = NSColor.red.cgColor
        let keyPath = "contents"
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.calculationMode = CAAnimationCalculationMode.discrete
        
        animation.duration = duration
        animation.repeatCount = repeats
        
        animation.values = images
        if let beginTime = beginTime {
            animation.beginTime = beginTime
        }
        
        let layerRect = CGRect(origin: .zero, size: self.frame.size)
        animLayer.frame = layerRect
        animLayer.contentsGravity = .resizeAspect
        
        animLayer.add(animation, forKey: keyPath)
        
        self.layer?.addSublayer(animLayer)
    }
    
    private func getAnimationLayer() -> CALayer? {
        return self.layer?.sublayers?.first(where: { $0.name == "animation" })
    }
    
    private func getAnimation() -> CAKeyframeAnimation? {
        return getAnimationLayer()?.animation(forKey: "contents") as? CAKeyframeAnimation
    }
    
    func getAnimationBeginTime() -> CFTimeInterval? {
        return getAnimation()?.beginTime
    }
    
    // Cheap way of making a previously set animation stop
    func stopAnimating() {
        self.layer = CALayer()
    }
    
}

extension Timer {
    class func schedule(delay: TimeInterval, handler: @escaping (Timer?) -> Void) {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, .commonModes)
    }
}

extension String {
    func fullNSRange() -> NSRange {
        return NSMakeRange(0, NSString(string: self).length)
    }
    
    func hyperlink(with url: URL) -> NSAttributedString {
        let stringRange = self.fullNSRange()
        let attrString = NSMutableAttributedString(string: self)
        
        attrString.addAttribute(NSAttributedString.Key.link, value: url, range: stringRange)
        
        return attrString
    }
}

extension NSImage {
    // from https://github.com/gloubibou/NSImage-HHTint
    func image(withTintColor tintColor: NSColor) -> NSImage? {
        // Create a color generator filter
        guard let colorGenerator = CIFilter(name: "CIConstantColorGenerator") else {
            return nil
        }
        let color = CIColor(color: tintColor)
        colorGenerator.setValue(color, forKey: kCIInputColorKey)
        
        // Create a color controls filter
        guard let colorFilter = CIFilter(name: "CIColorControls") else {
            return nil
        }
        colorFilter.setValue(colorGenerator.outputImage, forKey: kCIInputImageKey)
        colorFilter.setValue(3.0, forKey: kCIInputSaturationKey)
        colorFilter.setValue(0.35, forKey: kCIInputBrightnessKey)
        colorFilter.setValue(1.0, forKey: kCIInputContrastKey)
        
        // Create a monochrome filter
        guard let monochromeFilter = CIFilter(name: "CIColorMonochrome"),
              let imageData = self.tiffRepresentation,
              let baseImage = CIImage(data: imageData) else {
            return nil
        }
        monochromeFilter.setValue(baseImage, forKey: kCIInputImageKey)
        monochromeFilter.setValue(CIColor(red: 0.75, green: 0.75, blue: 0.75), forKey: kCIInputColorKey)
        monochromeFilter.setValue(1.0, forKey: kCIInputIntensityKey)
        
        // Create a compositing filter
        guard let compositingFilter = CIFilter(name: "CIMultiplyCompositing") else {
            return nil
        }
        compositingFilter.setValue(colorFilter.outputImage, forKey: kCIInputImageKey)
        compositingFilter.setValue(monochromeFilter.outputImage, forKey: kCIInputBackgroundImageKey)
        
        // Get the final output image
        guard let outputImage = compositingFilter.outputImage else { return nil }
        
        // Determine image size and extent
        let extent = outputImage.extent
        let size = self.size
        let tintedImage = NSImage(size: size)
        
        // Render the output image into an NSImage
        tintedImage.lockFocus()
        if let contextRef = NSGraphicsContext.current?.cgContext {
            let ciContext = CIContext(cgContext: contextRef, options: [CIContextOption.useSoftwareRenderer: true])
            let rect = CGRect(origin: .zero, size: size)
            ciContext.draw(outputImage, in: rect, from: extent)
        }
        tintedImage.unlockFocus()
        
        return tintedImage
    }

}

extension NSColor {
    func toRGBHexString() -> String {
        return String(format: "%02X%02X%02X", arguments: [
            Int(self.redComponent * 0xFF),
            Int(self.greenComponent * 0xFF),
            Int(self.blueComponent * 0xFF)
        ])
    }
    
    static func fromRGBHexString(_ hexString: String) -> NSColor? {
        // Handle two types of literals: 0x and # prefixed
        var cleanedSubstring: Substring
        if hexString.hasPrefix("#") {
            cleanedSubstring = hexString[hexString.index(hexString.startIndex, offsetBy: 1)..<hexString.endIndex]
        } else if hexString.hasPrefix("0x") {
            cleanedSubstring = hexString[hexString.index(hexString.startIndex, offsetBy: 2)..<hexString.endIndex]
        } else {
            cleanedSubstring = hexString[..<hexString.endIndex]
        }
        // Ensure it only contains valid hex characters 0
        let cleanedString = String(cleanedSubstring)
        let validHexPattern = NSPredicate(format:"SELF MATCHES %@", "[a-fA-F0-9]+")
        if !validHexPattern.evaluate(with: cleanedString) {
            return nil
        }
        var theInt: UInt32 = 0
        let scanner = Scanner(string:cleanedString)
        scanner.scanHexInt32(&theInt)
        let red = CGFloat((theInt & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((theInt & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((theInt & 0xFF)) / 255.0
        return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
    }
}
