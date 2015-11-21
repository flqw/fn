//
//  AppDelegate.swift
//  fn
//
//  Created by Florian Wagner on 21/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

//    let notificationCenter = NSWorkspace.sharedWorkspace().notificationCenter
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
//        notificationCenter.addObserver(self, selector: "switchedApplication", name:NSWorkspaceDidActivateApplicationNotification, object: nil);
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
//        notificationCenter.removeObserver(self);
    }
    
}

