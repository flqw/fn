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
            if setFnMode(button.appearsDisabled) {
                button.appearsDisabled = !button.appearsDisabled
                toggledDisabled = button.appearsDisabled
            }
        }
    }
    
    func backToToggledMode() {
        if let button = statusItem.button {
            if button.appearsDisabled != toggledDisabled {
                if setFnMode(toggledDisabled) {
                    button.appearsDisabled = toggledDisabled
                }
            }
        }
    }
    
    func forceState(state : Bool) {
        if let button = statusItem.button {
            if (state != button.appearsDisabled) {
                if setFnMode(state) {
                    button.appearsDisabled = state
                }
            }
            
        }
    }

    func getFnMode() -> Bool {
        
        var connect : io_connect_t = 0
        
        let classToMatch = IOServiceMatching(kIOHIDSystemClass)
        
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, classToMatch)
        
        var kern = IOServiceOpen(service, mach_task_self_, UInt32(kIOHIDParamConnectType), &connect)
    
        if (kern != kIOReturnSuccess) {
            NSLog("getFnMode() IOServiceOpen Kern \(returnCodeMap[kern])")
        }
        
        let value = UnsafeMutablePointer<UInt32>.alloc(1)
        let actualSize = UnsafeMutablePointer<UInt32>.alloc(1)
        
        kern = IOHIDGetParameter(connect, kIOHIDFKeyModeKey, 1, value, actualSize);
        
        if (kern != kIOReturnSuccess) {
            NSLog("getFnMode() IOHIDGetParameter Kern \(returnCodeMap[kern])")
        }
        
        kern = IOServiceClose(connect)
        
        if (kern != kIOReturnSuccess) {
            NSLog("getFnMode() IOServiceClose Kern \(returnCodeMap[kern])")
        }
        
        return value.memory == 0
    }
    
    func setFnMode(enabled : Bool) -> Bool {
        
        // 0 = Apple Mode
        // 1 = F Mode
        var setting = enabled ? UInt32(0) : UInt32(1);
        
        var connect : io_connect_t = 0
        
        let classToMatch = IOServiceMatching(kIOHIDSystemClass)
        
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, classToMatch)
        
        var kern = IOServiceOpen(service, mach_task_self_, UInt32(kIOHIDParamConnectType), &connect)
        
        var openKern = true, setKern = true, closeKern = true
        
        if (kern != kIOReturnSuccess) {
            NSLog("setFnMode(\(enabled)) IOServiceOpen Kern \(returnCodeMap[kern])")
            openKern = false
        }
        
        kern = IOHIDSetParameter(connect, kIOHIDFKeyModeKey, &setting, 1)
        
        if (kern != kIOReturnSuccess) {
            NSLog("setFnMode(\(enabled)) IOHIDSetParameter Kern \(returnCodeMap[kern])")
            setKern = false
        }
        
        kern = IOServiceClose(connect)
        
        if (kern != kIOReturnSuccess) {
            NSLog("setFnMode(\(enabled)) IOServiceClose Kern \(returnCodeMap[kern])")
            closeKern = false
        }
        
        return openKern && setKern && closeKern
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
