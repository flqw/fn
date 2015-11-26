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
        let sliced = Array(pathComponents[1...pathComponents.count - 4])
        let path = NSString.pathWithComponents(sliced)
        NSWorkspace.sharedWorkspace().launchApplication(path)
        NSApp.terminate(nil)
    }

}

