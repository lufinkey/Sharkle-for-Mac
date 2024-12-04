//
//  AppSettings.swift
//  Sharkle
//
//  Created by Luis Finke on 12/4/24.
//  Copyright © 2024 Peter Wunder. All rights reserved.
//


class AppSettings {
    @available(*, unavailable) private init() {}
    
    public struct PrefKeys {
        @available(*, unavailable) private init() {}
        
        public static let isShownInDock: String = "isShownInDock"
    }
    
    public static func initialize() {
        setShownInDock(self.isShownInDockPref, refocusFrontWindow: false, updatePrefsKey: false)
    }
    
    
    public static var isShownInDock: Bool {
        get { (NSApplication.shared.activationPolicy() != .accessory) }
    }
    
    public static func setShownInDock(_ shown: Bool, refocusFrontWindow: Bool, updatePrefsKey: Bool = true) {
        let newPolicy: NSApplication.ActivationPolicy = shown ? .regular : .accessory
        let app = NSApplication.shared
        if app.activationPolicy() != newPolicy {
            let frontWindow = app.keyWindow
            app.setActivationPolicy(newPolicy)
            if refocusFrontWindow {
                if !shown, let frontWindow = frontWindow {
                    app.activate(ignoringOtherApps: true)
                    frontWindow.makeKeyAndOrderFront(nil)
                }
            }
        }
        if updatePrefsKey {
            self.isShownInDockPref = shown
        }
    }
    
    private static var isShownInDockPref: Bool {
        get { UserDefaults.standard.bool(forKey: PrefKeys.isShownInDock) }
        set { UserDefaults.standard.set(newValue, forKey: PrefKeys.isShownInDock) }
    }
}
