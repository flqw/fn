//
//  PreferencesWindow.swift
//  fn
//
//  Created by Florian Wagner on 21/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa

func == (lhs: AppSetting, rhs: AppSetting) -> Bool {
    return lhs.bundle == rhs.bundle
}

class AppSetting: Equatable {
    let bundle : NSBundle
    var setting : Bool
    
    init(bundle: NSBundle, setting: Bool) {
        self.bundle = bundle
        self.setting = setting
    }
}

class PreferencesWindow: NSWindowController, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView : NSTableView!
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowWillLoad() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let apps = userDefaults.dictionaryForKey(GlobalConstants.FORCED_APPS_KEY) as? [String : Bool] {
            apps.forEach { id, setting in
                if let bundle = PreferencesWindow.applicationBundleFor(id) {
                    self.apps.append(AppSetting(bundle: bundle, setting: setting))
                }
            }
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
    }
    
    static func applicationBundleFor(bundleIdentifier: String) -> NSBundle? {
    
        if let path = NSWorkspace.sharedWorkspace().absolutePathForAppBundleWithIdentifier(bundleIdentifier),
            bundle = NSBundle(path: path)
        {
            return bundle
        }
    
        print("No Bundle found for \(bundleIdentifier)")
        return nil;
    
    }
    
    static func applicationNameFor(bundle : NSBundle) -> String {
        if let infoDictionary = bundle.infoDictionary {
            if let name = infoDictionary[kCFBundleNameKey as String] as? String {
                return name
            }
        }
        return (bundle.bundlePath as NSString).lastPathComponent
    }
    
    static func iconFor(bundle : NSBundle) -> NSImage {
        return NSWorkspace.sharedWorkspace().iconForFile(bundle.bundlePath)
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier("applicationCell", owner: self) as! ApplicationCellView
        
        let app = apps[row]
        
        view.imageView?.image = PreferencesWindow.iconFor(app.bundle)
        view.textField?.stringValue = PreferencesWindow.applicationNameFor(app.bundle)
        view.button.setSelected(true, forSegment: app.setting ? 0 : 1)
        
        view.setting = app
        view.controller = self
        
        return view;

    }

    var apps : [AppSetting] = []
    
    @IBOutlet weak var addMenu: NSMenu!
    
    func showRow(atIndex index: Int) {
        NSAnimationContext.runAnimationGroup({ context in
            context.allowsImplicitAnimation = true
            self.tableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
            self.tableView.scrollRowToVisible(index)
        }, completionHandler: nil)
    }
    
    func addApplication(menuItem : ApplicationMenuItem) {
        
        if let bundle = PreferencesWindow.applicationBundleFor(menuItem.bundleIdentifier) {
            
            if let index = apps.indexOf(AppSetting(bundle: bundle, setting: true)) {
                showRow(atIndex: index)
            } else {
                apps.append(AppSetting(bundle: bundle, setting: true))
                persistState()
                let index = apps.count - 1
                tableView.insertRowsAtIndexes(NSIndexSet(index: index), withAnimation: .EffectFade)
                showRow(atIndex: index)
            }
            
        }
        
    }
    
    @IBOutlet weak var buttons: NSSegmentedControl!
    
    @IBAction func buttonClicked(sender: NSSegmentedControl) {
    
        if (sender.selectedSegment == 0) {
            // Add
            
            let event = NSApplication.sharedApplication().currentEvent!
            
            addMenu.removeAllItems()
            let runningAppBundles = runningApplicationBundles()
            
            addMenu.addItemWithTitle("Running Applications", action: "", keyEquivalent: "") // TODO Translate
            
            runningAppBundles.forEach { bundle in
                addMenu.addItem(ApplicationMenuItem(forBundle: bundle, action: "addApplication:"))
            }
            
            NSMenu.popUpContextMenu(addMenu, withEvent: event, forView: sender)
            
        
        } else if (sender.selectedSegment == 1) {
            // Remove
            if let cell = getSelectedCell() {
                let index = tableView.rowForView(cell)
                tableView.removeRowsAtIndexes(NSIndexSet(index: index), withAnimation: .EffectFade)
                apps.removeAtIndex(index)
                persistState()
                
                if (apps.count > index) {
                    showRow(atIndex: index)
                } else {
                    showRow(atIndex: apps.count - 1)
                }
                
            }
        }
        
    }
    
    func runningApplicationBundles() -> [NSBundle] {
        return NSWorkspace.sharedWorkspace().runningApplications
            .filter { app in app.activationPolicy == .Regular }
            .map { app in app.bundleIdentifier }
            .flatMap { $0 }
            .map { id in PreferencesWindow.applicationBundleFor(id) }
            .flatMap { $0 }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return apps.count
    }
    
    func getSelectedCell() -> ApplicationCellView? {
        if (tableView.selectedRow == -1) {
            return nil
        }
        return tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: false) as? ApplicationCellView
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if (tableView.selectedRow == -1) {
            buttons.setEnabled(false, forSegment: 1) // Disable the remove button
        } else {
            buttons.setEnabled(true, forSegment: 1) // Enable the remove button
        }
    }
    
    func persistState() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        var settings = [String : Bool]()
        for app in apps {
            settings[app.bundle.bundleIdentifier!] = app.setting
        }
        
        userDefaults.setValue(settings, forKey: GlobalConstants.FORCED_APPS_KEY)
        userDefaults.synchronize()
    }
    
}
