//
//  GeneralSettingsViewController.swift
//  Sharkle
//
//  Created by Luis Finke on 12/4/24.
//  Copyright © 2024 Peter Wunder. All rights reserved.
//


class GeneralSettingsViewController: NSViewController, NSComboBoxDelegate {
    @IBOutlet weak var showInDockToggle: NSButton!
    @IBOutlet weak var imageSetDropdown: NSPopUpButton!
    private var observing = false
    
    deinit {
        removeObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showInDockToggle.state = AppSettings.isShownInDock.get() ? .on : .off
        imageSetDropdown.removeAllItems()
        imageSetDropdown.addItems(withTitles: SharkleImageSet.Kind.allCases.map { $0.displayName })
        self.selectedImageSetKind = AppSettings.imageSet.get()
        addObservers()
    }
    
    
    private func addObservers() {
        if observing {
            return
        }
        AppSettings.isShownInDock.observe(self) { (shown) in
            if shown != (self.showInDockToggle.state == .on) {
                self.showInDockToggle.state = shown ? .on : .off
            }
        }
        AppSettings.imageSet.observe(self) { (imageSetKind) in
            self.selectedImageSetKind = imageSetKind
        }
        self.imageSetDropdown.addObserver(self,
            forKeyPath: "selectedIndex",
            options: [.new],
            context: nil)
        observing = true
    }
    
    private func removeObservers() {
        AppSettings.isShownInDock.unobserve(self)
        self.imageSetDropdown.removeObserver(self, forKeyPath: "selectedIndex")
        observing = false
    }
    
    
    
    var selectedImageSetKind: SharkleImageSet.Kind? {
        get {
            let index = self.imageSetDropdown.indexOfSelectedItem
            let kinds = SharkleImageSet.Kind.allCases
            if index < 0 || index >= kinds.count {
                return nil
            }
            return kinds[index]
        }
        set {
            if let newValue = newValue, self.selectedImageSetKind != newValue,
               let newValueIndex = SharkleImageSet.Kind.allCases.firstIndex(of: newValue) {
                self.imageSetDropdown.selectItem(at: newValueIndex)
            }
        }
    }
    
    @IBAction func didChangeImageSetDropdownSelection(_ sender: Any) {
        if let imageSetKind = self.selectedImageSetKind {
            AppSettings.imageSet.set(imageSetKind)
        }
    }
    
    @IBAction func didToggleShowInDock(_ sender: Any) {
        AppSettings.isShownInDock.set(showInDockToggle.state == .on)
    }
}
