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
    
    override func awakeFromNib() {
        preferencesWindow = PreferencesWindow()

        if let button = statusItem.button {
            button.title = "fn"
            button.action = Selector("clickedStatusItem")
            button.target = self
            button.appearsDisabled = true
        }
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    func toggleMenu() {
        statusItem.popUpStatusItemMenu(statusMenu)
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
    
}
