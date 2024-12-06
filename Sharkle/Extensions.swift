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
