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
    @IBOutlet weak var tintColorToggle: NSButton!
    @IBOutlet weak var tintColorPicker: NSColorWell!
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
        tintColorToggle.state = AppSettings.tintColorEnabled.get() ? .on : .off
        tintColorPicker.color = AppSettings.tintColor.get()
        
        addObservers()
    }
    
    
    private func addObservers() {
        if observing {
            return
        }
        AppSettings.isShownInDock.observe(self) { (shown) in
            if (self.showInDockToggle.state == .on) != shown {
                self.showInDockToggle.state = shown ? .on : .off
            }
        }
        AppSettings.imageSet.observe(self) { (imageSetKind) in
            if self.selectedImageSetKind != imageSetKind {
                self.selectedImageSetKind = imageSetKind
            }
        }
        AppSettings.tintColorEnabled.observe(self) { tintColorEnabled in
            if (self.tintColorToggle.state == .on) != tintColorEnabled {
                self.tintColorToggle.state = tintColorEnabled ? .on : .off
            }
        }
        AppSettings.tintColor.observe(self) { tintColor in
            if self.tintColorPicker.color != tintColor {
                self.tintColorPicker.color = tintColor
            }
        }
        tintColorPicker.addObserver(self, forKeyPath: "color", options: [.new], context: nil)
        observing = true
    }
    
    private func removeObservers() {
        AppSettings.isShownInDock.unobserve(self)
        AppSettings.imageSet.unobserve(self)
        AppSettings.tintColorEnabled.unobserve(self)
        AppSettings.tintColor.unobserve(self)
        tintColorPicker.removeObserver(self, forKeyPath: "color", context:nil)
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
            if let newValue = newValue,
               let newValueIndex = SharkleImageSet.Kind.allCases.firstIndex(of: newValue) {
                self.imageSetDropdown.selectItem(at: newValueIndex)
            }
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "color",
           let colorPicker = object as? NSColorWell,
           colorPicker === self.tintColorPicker,
           let color = change?[.newKey] as? NSColor {
            didChangeTintColorSelection(color)
        }
    }
    
    @IBAction func didChangeImageSetDropdownSelection(_ sender: Any) {
        if let imageSetKind = self.selectedImageSetKind {
            AppSettings.imageSet.set(imageSetKind)
        }
    }
    
    @IBAction func didToggleTintColorEnabled(_ sender: Any) {
        AppSettings.tintColorEnabled.set(tintColorToggle.state == .on)
    }
    
    func didChangeTintColorSelection(_ color: NSColor) {
        AppSettings.tintColor.set(color)
    }
    
    @IBAction func didToggleShowInDock(_ sender: Any) {
        AppSettings.isShownInDock.set(showInDockToggle.state == .on)
    }
}
