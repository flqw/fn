//
//  PreferencesWindow.swift
//  fn
//
//  Created by Florian Wagner on 21/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func windowWillClose(notification: NSNotification) {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setValue(cityTextField.stringValue, forKey: "city")
    }
    
}
