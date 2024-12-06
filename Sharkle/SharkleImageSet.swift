//
//  SharkleImageSet.swift
//  Sharkle
//
//  Created by Luis Finke on 12/5/24.
//  Copyright © 2024 Peter Wunder. All rights reserved.
//

public class SharkleImageSet {
    public enum Kind: String, CaseIterable {
        case `default` = "default"
        case white = "white"
        case black = "black"
        
        var displayName: String {
            switch self {
            case .default:
                return "Default (Black Border / White Content)"
            case .white:
                return "White"
            case .black:
                return "Black"
            }
        }
    }
    
    let idleImages: [NSImage]
    let waveImages: [NSImage]
    let bubbleImages: [NSImage]
    
    public init(key: String) {
        idleImages = (0..<8).map {
            let imageName = NSImage.Name("sharkle\(key)_idle\($0)")
            return NSImage(named: imageName)!
        }
        waveImages = (0..<4).map {
            let imageName = NSImage.Name("sharkle\(key)_wave\($0)")
            return NSImage(named: imageName)!
        }
        bubbleImages = (0..<2).map {
            let imageName = NSImage.Name("sharkle\(key)_bubble\($0)")
            return NSImage(named: imageName)!
        }
    }
    
    public static let `default` = SharkleImageSet(key:"")
    public static let white = SharkleImageSet(key:"_white")
    public static let black = SharkleImageSet(key:"_black")
    
    public static func get(kind: Kind) -> SharkleImageSet {
        switch kind {
        case .default:
            return self.default
        case .white:
            return self.white
        case .black:
            return self.black
        }
    }
}
