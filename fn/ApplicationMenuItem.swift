//
//  ApplicationMenuItem.swift
//  fn
//
//  Created by Florian Wagner on 22/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa

class ApplicationMenuItem: NSMenuItem {

    var app : App!

    init(forApp app: App, action: Selector) {
        self.app = app
        super.init(title: app.name, action: action, keyEquivalent: "")
        self.image = app.icon
        self.image?.size = NSSize(width: 20, height: 20)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
