//
//  AppDelegate.swift
//  Sharkle
//
//  Created by Peter Wunder on 20.04.17.
//  Copyright © 2017 Peter Wunder. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    public static var shared: AppDelegate {
        get { NSApp.delegate as! AppDelegate }
    }
	
	weak var sharkleController: SharkleWindowController!
    
    @IBOutlet weak var aboutMenuItem: NSMenuItem!
    @IBOutlet weak var settingsMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppSettings.initialize()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

	@IBAction func resetSharklePosition(_ sender: NSMenuItem) {
		if let window = self.sharkleController.window {
			window.setFrameOrigin(NSPoint(x: 24, y: 24))
		}
	}
	
    
    
    private func clickMenuItemToOpenWindow(_ menuItem: NSMenuItem) {
        NSApp.sendAction(menuItem.action!, to: menuItem.target, from: aboutMenuItem)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func showAboutWindow() {
        clickMenuItemToOpenWindow(aboutMenuItem)
    }
    
    public func showSettingsWindow() {
        clickMenuItemToOpenWindow(settingsMenuItem)
    }
}
