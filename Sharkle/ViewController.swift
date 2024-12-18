//
//  ViewController.swift
//  Sharkle
//
//  Created by Peter Wunder on 20.04.17.
//  Copyright © 2017 Peter Wunder. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var sharkleIdleView: NSView!
    @IBOutlet weak var sharkleWaveView: NSView!
    @IBOutlet weak var sharkleBubbleView: NSView!
    
    // Global AVAudioPlayer variable, gets set in mouseDown event
    var players: [AVAudioPlayer] = []
    
    let idleAnimDuration = 0.666
    let waveAnimDuration = 0.4
    let waveRepeatCount = 2.5
    let bubbleAnimDuration = 0.8
    var imageSet: SharkleImageSet!
    
    let sharkleSounds: [URL] = (0..<8).map({ URL(fileURLWithPath: Bundle.main.path(forResource: "hey_\($0)", ofType: "m4a")!) })
    var lastSharkleSoundIndex: Int = -1
    
    private var observing = false
    
    deinit {
        removeObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateImageSet()
        
        for soundURL in sharkleSounds {
            do {
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.prepareToPlay()
                player.volume = 1.4
                
                self.players.append(player)
            } catch {
                // This should never happen
                // famouslastwords.swift
                print("Error loading audio file \(soundURL)")
            }
        }
        
        playIdleAnimations()
        
        addObservers()
    }
    
    private func addObservers() {
        AppSettings.imageSet.observe(self) { imageSetKind in
            self.updateImageSet()
            self.updateCurrentAnimations()
        }
        AppSettings.tintColorEnabled.observe(self) { tintColorEnabled in
            self.updateImageSet()
            self.updateCurrentAnimations()
        }
        AppSettings.tintColor.observe(self) { tintColor in
            self.updateImageSet()
            self.updateCurrentAnimations()
        }
    }
    
    private func removeObservers() {
        AppSettings.imageSet.unobserve(self)
        AppSettings.tintColorEnabled.unobserve(self)
        AppSettings.tintColor.unobserve(self)
    }
    
    
    func updateImageSet() {
        var imageSet = SharkleImageSet.get(kind: AppSettings.imageSet.get())
        if AppSettings.tintColorEnabled.get() {
            imageSet = imageSet.withTintColor(AppSettings.tintColor.get())
        }
        self.imageSet = imageSet
    }
    
    func playIdleAnimations(beginTime: CFTimeInterval? = nil) {
        sharkleWaveView.stopAnimating()
        sharkleBubbleView.stopAnimating()
        sharkleIdleView.animate(withImages: self.imageSet.idleImages, andDuration: self.idleAnimDuration)
    }
    
    func playGreetingAnimations(beginTime: CFTimeInterval? = nil) {
        sharkleIdleView.stopAnimating()
        sharkleWaveView.animate(withImages: self.imageSet.waveImages, andDuration: waveAnimDuration, beginTime: beginTime)
        sharkleBubbleView.animate(withImages: self.imageSet.bubbleImages, andDuration: bubbleAnimDuration, repeatTimes: 2.5, beginTime: beginTime)
    }
    
    func updateCurrentAnimations() {
        if self.animationIsPlaying {
            self.playGreetingAnimations(beginTime: self.sharkleWaveView.getAnimationBeginTime())
        } else {
            self.playIdleAnimations(beginTime: self.sharkleIdleView.getAnimationBeginTime())
        }
    }
    
    func playRandomGreetingSound() {
        var randomSoundIndex = Int.random(in: 0..<self.players.count)
        if randomSoundIndex == self.lastSharkleSoundIndex {
            randomSoundIndex += 1
            if randomSoundIndex >= self.players.count {
                randomSoundIndex = 0
            }
        }
        self.players[randomSoundIndex].play()
        self.lastSharkleSoundIndex = randomSoundIndex
    }
    
    
    var animationIsPlaying = false
    override func mouseDown(with event: NSEvent) {
        if animationIsPlaying {
            // Sharkle is currently waving, don't interrupt him
            return
        }
        
        animationIsPlaying = true
        
        // Play random "hey" sound
        playRandomGreetingSound()
        // Start waving animation
        playGreetingAnimations()
        
        // Reset greeting after delay
        Timer.schedule(delay: waveAnimDuration * waveRepeatCount, handler: { timer in
            self.playIdleAnimations()
            self.animationIsPlaying = false
        })
    }
    
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        
        let menu = NSMenu(title:"Context Menu")
        menu.addItem(contextMenuItem(
            title: "About",
            action: #selector(didSelectAbout(_:))))
        menu.addItem(contextMenuItem(
            title: "Settings",
            action: #selector(didSelectSettings(_:))))
        menu.addItem(contextMenuItem(
            title: "Close",
            action: #selector(didSelectClose(_:))))
        NSMenu.popUpContextMenu(menu, with: event, for: self.view)
    }
    
    private func contextMenuItem(title: String, action: Selector) -> NSMenuItem {
        let menuItem = NSMenuItem(
            title: title,
            action: action,
            keyEquivalent: "")
        menuItem.target = self
        return menuItem
    }
    
    @objc func didSelectAbout(_ sender: Any?) {
        AppDelegate.shared.showAboutWindow()
    }
    
    @objc func didSelectSettings(_ sender: Any?) {
        AppDelegate.shared.showSettingsWindow()
    }
    
    @objc func didSelectClose(_ sender: Any) {
        NSApplication.shared.terminate(nil)
    }
}
