//
//  AppSettings.swift
//  Sharkle
//
//  Created by Luis Finke on 12/4/24.
//  Copyright © 2024 Peter Wunder. All rights reserved.
//


class AppSettings {
    @available(*, unavailable) private init() {}
    
    public class PreferenceItem<T> {
        public typealias ValueGetter = (_ prefItem: PreferenceItem<T>) -> T
        public typealias ValueSetter = (_ value: T, _ prefItem: PreferenceItem<T>, _ initializing: Bool) -> Bool
        public typealias ChangeCallback = (_ value: T) -> Void
        
        private struct Observer {
            public let key: AnyHashable
            public let callback: ChangeCallback
        }
        
        public let prefKey: String
        public let getValue: ValueGetter
        public let setValue: ValueSetter
        private var observers: [Observer] = []
        
        public init(
            prefKey: String,
            getValue: @escaping ValueGetter,
            setValue: @escaping ValueSetter)
        {
            self.prefKey = prefKey
            self.getValue = getValue
            self.setValue = setValue
        }
        
        public convenience init(prefKey: String, defaultValue: T) {
            self.init(
                prefKey: "animateWhenOccluded",
                getValue: { (prefItem) in
                    return prefItem.prefValue ?? defaultValue
                },
                setValue: { (value, prefItem, initializing) in
                    return true
                })
        }
        
        public var prefValue: T? {
            get { UserDefaults.standard.object(forKey: self.prefKey) as? T }
            set { UserDefaults.standard.set(newValue, forKey: self.prefKey) }
        }
        
        public func initialize() {
            if let val = self.prefValue {
                let result = self.setValue(val, self, true)
                if !result {
                    NSLog("Failed to initialize preference \"\(self.prefKey)\"")
                }
            }
        }
        
        @discardableResult
        public func set(_ value: T) -> Bool {
            let result = self.setValue(value, self, false)
            if result {
                self.prefValue = value
                let observersList = self.observers
                for observer in observersList {
                    observer.callback(value)
                }
            }
            return result
        }
        
        public func get() -> T {
            return self.getValue(self)
        }
        
        public func observe(_ key: AnyHashable, _ callback: @escaping ChangeCallback) {
            if let _ = observers.firstIndex(where: { $0.key == key }) {
                // already observing
                NSLog("\(key) is already observing pref key \"\(self.prefKey)\"")
                return
            }
            observers.append(Observer(key: key, callback: callback))
        }
        
        public func unobserve(_ key: AnyHashable) {
            if let index = observers.firstIndex(where: { $0.key == key }) {
                observers.remove(at: index)
            }
        }
    }
    
    
    
    public static let isShownInDock = PreferenceItem<Bool>(
        prefKey: "isShownInDock",
        getValue: { prefItem in
            return (NSApplication.shared.activationPolicy() == .regular)
        },
        setValue: { (value, prefItem, initializing) in
            let newPolicy: NSApplication.ActivationPolicy = value ? .regular : .accessory
            let app = NSApplication.shared
            if app.activationPolicy() == newPolicy {
                return true
            }
            let frontWindow = app.keyWindow
            let wasActive = app.isActive
            app.setActivationPolicy(newPolicy)
            // refocus the key window if disabling the setting
            if !initializing && !value && wasActive, let frontWindow = frontWindow  {
                app.activate(ignoringOtherApps: true)
                frontWindow.makeKeyAndOrderFront(nil)
            }
            return true
        }
    )
    
    
    
    public static func initialize() {
        self.isShownInDock.initialize()
    }
}
