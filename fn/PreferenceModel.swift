//
//  Settings.swift
//  fn
//
//  Created by Florian Wagner on 26/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa

func == (lhs: App, rhs: App) -> Bool {
    return lhs.bundle == rhs.bundle
}

class App: Equatable {
    
    private let model : PreferenceModel
    
    let bundle : NSBundle
    var setting : Bool {
        didSet {
            model.persistState()
        }
    }
    
    var icon : NSImage {
        return NSWorkspace.sharedWorkspace().iconForFile(bundle.bundlePath)
    }
    
    var name : String {
        if let infoDictionary = bundle.localizedInfoDictionary {
            if let name = infoDictionary["CFBundleDisplayName"] as? String {
                return name
            }
            if let name = infoDictionary[kCFBundleNameKey as String] as? String {
                return name
            }
        }
        if let infoDictionary = bundle.infoDictionary {
            if let name = infoDictionary[kCFBundleNameKey as String] as? String {
                return name
            }
        }
        return (bundle.bundlePath as NSString).lastPathComponent
    }
    
    private init(bundle: NSBundle, setting: Bool, model : PreferenceModel) {
        self.bundle = bundle
        self.setting = setting
        self.model = model
    }
}

class PreferenceModel: NSObject {
    
    private let FORCED_APPS_KEY = "forcedApps"
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private(set) var apps : [App] = []

    var runningApps: [App] {
        return NSWorkspace.sharedWorkspace().runningApplications
            .filter { $0.activationPolicy == .Regular }
            .map { $0.bundleIdentifier }
            .flatMap { $0 }
            .map { bundleFor($0) }
            .filter { $0 != nil }
            .map { App(bundle: $0!, setting: true, model: self) }
            .flatMap { $0 }
    }
    
    override init() {
        super.init()
        loadPreferences();
    }
    
    private func loadPreferences() {
        if let apps = userDefaults.dictionaryForKey(FORCED_APPS_KEY) as? [String : Bool] {
            apps.forEach { id, setting in
                if let bundle = bundleFor(id) {
                    self.apps.append(App(bundle: bundle, setting: setting, model: self))
                }
            }
        }
    }
    
    func settingFor(bundleIdentifier : String) -> Bool? {
        return apps.filter { $0.bundle.bundleIdentifier == bundleIdentifier }
                   .map { app in app.setting }
                   .first
    }
    
    func removeApp(atIndex index: Int, didRemove: (app: App) -> Void = { _ in }) {
        let app = apps.removeAtIndex(index)
        persistState()
        didRemove(app: app)
    }

    func addApp(app : App, alreadyExists: (atIndex : Int) -> Void, didAdd: (atIndex: Int) -> Void) {
        
        if let index = apps.indexOf(app) {
            alreadyExists(atIndex: index)
        } else {
            apps.append(app)
            persistState()
            let index = apps.count - 1
            didAdd(atIndex: index)
        }
        
    }
    
    private func persistState() {
        
        print("Persisting state...")
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        var settings = [String : Bool]()
        for app in apps {
            settings[app.bundle.bundleIdentifier!] = app.setting
        }
        
        userDefaults.setValue(settings, forKey: FORCED_APPS_KEY)
        userDefaults.synchronize()
    }
    
    private func bundleFor(bundleIdentifier: String) -> NSBundle? {
        
        if let path = NSWorkspace.sharedWorkspace().absolutePathForAppBundleWithIdentifier(bundleIdentifier),
            bundle = NSBundle(path: path)
        {
            return bundle
        }
        
        print("No Bundle found for \(bundleIdentifier)")
        return nil;
        
    }
    
}
