//
//  ApplicationMenuItem.swift
//  fn
//
//  Created by Florian Wagner on 22/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa

class ApplicationMenuItem: NSMenuItem {

    var bundleIdentifier : String

    init(forBundle bundle: NSBundle, action: Selector) {
        self.bundleIdentifier = bundle.bundleIdentifier!
        let title = PreferencesWindow.applicationNameFor(bundle)
        super.init(title: title, action: action, keyEquivalent: "")
        self.image = PreferencesWindow.iconFor(bundle)
        self.image?.size = NSSize(width: 20, height: 20)
    }
    
    init(title: String, action: Selector, bundleIdentifier: String) {
        self.bundleIdentifier = bundleIdentifier
        super.init(title: title, action: action, keyEquivalent: "")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        bundleIdentifier = ""
        super.init(coder: aDecoder)
    }


}
