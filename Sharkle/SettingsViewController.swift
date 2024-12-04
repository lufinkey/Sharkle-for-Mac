//
//  SettingsViewController.swift
//  Sharkle
//
//  Created by Luis Finke on 12/4/24.
//  Copyright © 2024 Peter Wunder. All rights reserved.
//


class SettingsViewController: NSViewController {
    @IBOutlet weak var showInDockToggle: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showInDockToggle.state = AppSettings.isShownInDock ? .on : .off
    }
    
    @IBAction func didToggleShowInDock(_ sender: Any) {
        let showInDock = showInDockToggle.state == .on ? true : false
        AppSettings.setShownInDock(showInDock, refocusFrontWindow: true)
    }
    
    
    public static func instantiate() -> SettingsViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "Settings") as! SettingsViewController
    }
    
    public static func showInNewWindow() {
        let window = NSWindow(contentViewController: instantiate())
        window.title = "Sharkle Settings"
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }
}
