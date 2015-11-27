//
//  AppDelegate.swift
//  fn Helper
//
//  Created by Florian Wagner on 26/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let pathComponents : [String] = (NSBundle.mainBundle().bundlePath as NSString).pathComponents
        let sliced = Array(pathComponents[0...pathComponents.count - 5])
        let path = NSString.pathWithComponents(sliced)
        NSLog("Trying to launch application \(path)")
        let success = NSWorkspace.sharedWorkspace().launchApplication(path)
        if (!success) {
            NSLog("Failed to launch application \(path)")
        } else {
            NSLog("Did successfully launch application \(path)")
        }
        NSApp.terminate(nil)
    }

}

