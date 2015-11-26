//
//  StatusMenuController.swift
//  fn
//
//  Created by Florian Wagner on 21/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa


class StatusMenuController: NSObject {

    @IBOutlet weak var statusMenu: NSMenu!
    
    var preferencesWindow: PreferencesWindow!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    let notificationCenter = NSWorkspace.sharedWorkspace().notificationCenter
    
    static var instance : StatusMenuController? = nil
    
    let preferenceModel : PreferenceModel = PreferenceModel()
    
    var toggledDisabled = true
    
    override func awakeFromNib() {
        notificationCenter.addObserver(self, selector: "keyApplicationChanged:", name:NSWorkspaceDidActivateApplicationNotification, object: nil);
        
        let initialStatus = getInitialStatus()
        
        addSystemPreferencesObserver()
        
        StatusMenuController.instance = self
        
        toggledDisabled = initialStatus;
        
        preferencesWindow = PreferencesWindow()
        preferencesWindow.preferenceModel = preferenceModel

        if let button = statusItem.button {
            button.title = "fn"
            button.action = Selector("clickedStatusItem")
            button.target = self
            button.appearsDisabled = initialStatus
        }
    }
    
    func addSystemPreferencesObserver() {
        let center = CFNotificationCenterGetDistributedCenter()
        let callback: @convention(c) (CFNotificationCenter!, UnsafeMutablePointer<Void>, CFString!, UnsafePointer<Void>, CFDictionary!) -> Void = {
            (center, observer, name, object, userInfo) in
            
            let dict = userInfo as Dictionary
            
            let newState = dict["state"] as! Bool
            
            StatusMenuController.instance?.statusItem.button?.appearsDisabled = !newState
            
        }
        
        CFNotificationCenterAddObserver(center, nil, callback, "com.apple.keyboard.fnstatedidchange", nil, .DeliverImmediately)
    }
    
    /**
        Get the initial fn key status by reading from the system preferences.
     */
    func getInitialStatus() -> Bool {
       
        let value = getFnMode()
        
        return value
    }
    
    deinit {
        notificationCenter.removeObserver(self);
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func keyApplicationChanged(notification : NSNotification) {
        if let
            userInfo = notification.userInfo,
            appKey = userInfo[NSWorkspaceApplicationKey] as? NSRunningApplication,
            bundleIdentifier = appKey.bundleIdentifier
        {
            if let forcedState = preferenceModel.settingFor(bundleIdentifier) {
                forceState(!forcedState) // Inversion necessary
            } else {
                backToToggledMode()
            }

        }
    }

    func toggleMenu() {
        statusItem.popUpStatusItemMenu(statusMenu)
    }
    
    func switchToggle() {
        if let button = statusItem.button {
            button.appearsDisabled = !button.appearsDisabled
            toggledDisabled = button.appearsDisabled
            setFnMode(button.appearsDisabled)
        }
    }
    
    func backToToggledMode() {
        if let button = statusItem.button {
            if button.appearsDisabled != toggledDisabled {
                button.appearsDisabled = toggledDisabled
                setFnMode(toggledDisabled)
            }
        }
    }
    
    func forceState(state : Bool) {
        if let button = statusItem.button {
            
            if (state != button.appearsDisabled) {
                button.appearsDisabled = state
                setFnMode(state)
            }
            
        }
    }

    func getFnMode() -> Bool {
        
        var connect : io_connect_t = 0
        
        let classToMatch = IOServiceMatching(kIOHIDSystemClass)
        
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, classToMatch)
        
        IOServiceOpen(service, mach_task_self_, UInt32(kIOHIDParamConnectType), &connect)
        
        let value = UnsafeMutablePointer<UInt32>.alloc(1)
        let actualSize = UnsafeMutablePointer<UInt32>.alloc(1)
        
        IOHIDGetParameter(connect, kIOHIDFKeyModeKey, 1, value, actualSize);
        
        IOServiceClose(connect)
        
        return value.memory == 0
    }
    
    func setFnMode(enabled : Bool) {
        
        // 0 = Apple Mode
        // 1 = F Mode
        var setting = enabled ? UInt32(0) : UInt32(1);
        
        var connect : io_connect_t = 0
        
        let classToMatch = IOServiceMatching(kIOHIDSystemClass)
        
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, classToMatch)
        
        IOServiceOpen(service, mach_task_self_, UInt32(kIOHIDParamConnectType), &connect)
        
        IOHIDSetParameter(connect, kIOHIDFKeyModeKey, &setting, 1)
        
        IOServiceClose(connect)
    }
    
    func clickedStatusItem() {
                
        let event = NSApplication.sharedApplication().currentEvent
        
        if let modifierFlags = event?.modifierFlags {
            if modifierFlags.contains(.AlternateKeyMask) {
                toggleMenu()
                return;
            }
        }
        switchToggle()
    }
    
}
