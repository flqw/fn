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
    
    var setting : AppSetting!
    var controller : PreferencesWindow!
    
    override func awakeFromNib() {
        button.imageForSegment(1)?.size = NSSize(width: 17, height: 12)
    }
    
    @IBAction func buttonClicked(sender : NSSegmentedControl) {
        
        if (sender.selectedSegment == 0) {
            setting.setting = true
        } else {
            setting.setting = false
        }
        
        controller.persistState()
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
}
