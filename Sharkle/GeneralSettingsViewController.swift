//
//  GeneralSettingsViewController.swift
//  Sharkle
//
//  Created by Luis Finke on 12/4/24.
//  Copyright © 2024 Peter Wunder. All rights reserved.
//


class GeneralSettingsViewController: NSViewController {
    @IBOutlet weak var showInDockToggle: NSButton!
    
    deinit {
        removeObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showInDockToggle.state = AppSettings.isShownInDock.get() ? .on : .off
        addObservers()
    }
    
    
    private func addObservers() {
        AppSettings.isShownInDock.observe(self, didUpdateIsShownInDock(_:))
    }
    
    private func removeObservers() {
        AppSettings.isShownInDock.unobserve(self)
    }
    
    
    @IBAction func didToggleShowInDock(_ sender: Any) {
        AppSettings.isShownInDock.set(showInDockToggle.state == .on)
    }
    
    func didUpdateIsShownInDock(_ shown: Bool) {
        if shown != (showInDockToggle.state == .on) {
            showInDockToggle.state = shown ? .on : .off
        }
    }
}
