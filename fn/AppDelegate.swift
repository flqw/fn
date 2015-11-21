//
//  AppDelegate.swift
//  fn
//
//  Created by Florian Wagner on 21/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa

/*

TODO

- Preferences
- Start on boot

*/

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let notificationCenter = NSWorkspace.sharedWorkspace().notificationCenter
    let menu = NSMenu()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        menu.addItem(NSMenuItem(title: "PREFERENCES".localized, action: "openPreferences:", keyEquivalent: ""))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "QUIT".localized, action: "terminate:", keyEquivalent: ""))
        
        if let button = statusItem.button {
            button.title = "fn"
            button.action = "clickedStatusItem"
            button.appearsDisabled = true
        }
        
        notificationCenter.addObserver(self, selector: "switchedApplication", name:NSWorkspaceDidActivateApplicationNotification, object: nil);
        
    }
    
    func openPreferences() {
        
    }
    
    func toggleMenu() {
        statusItem.popUpStatusItemMenu(menu)
    }
    
    func toggleState() {
        if let button = statusItem.button {
            button.appearsDisabled = !button.appearsDisabled
            setFnMode(button.appearsDisabled)
        }
    }
    
    /**
     Set the F-Key Mode with IOKit.
     */
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
        toggleState()
    }
    
    func switchedApplication() {
        //toggleState()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        notificationCenter.removeObserver(self);
    }
    
}
