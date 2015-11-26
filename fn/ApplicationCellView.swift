//
//  ApplicationCellView.swift
//  fn
//
//  Created by Florian Wagner on 22/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa

class ApplicationCellView: NSTableCellView {

    @IBOutlet weak var button: NSSegmentedControl!
    
    var app : App!
    var controller : PreferencesWindow!
    
    override func awakeFromNib() {
        button.imageForSegment(1)?.size = NSSize(width: 17, height: 12)
    }
    
    @IBAction func buttonClicked(sender : NSSegmentedControl) {
        
        if (sender.selectedSegment == 0) {
            app.setting = true
        } else {
            app.setting = false
        }
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
}
