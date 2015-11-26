//
//  PreferencesWindow.swift
//  fn
//
//  Created by Florian Wagner on 21/11/15.
//  Copyright © 2015 Florian Wagner. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView : NSTableView!
    
    @IBOutlet weak var addMenu: NSMenu!
    
    @IBOutlet weak var buttons: NSSegmentedControl!
    
    var preferenceModel : PreferenceModel!
    
    private var selectedCell : ApplicationCellView? {
        if (tableView.selectedRow == -1) {
            return nil
        }
        return tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: false) as? ApplicationCellView
    }
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowWillLoad() {
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier("applicationCell", owner: self) as! ApplicationCellView
        
        let app = preferenceModel.apps[row]
        
        view.imageView?.image = app.icon
        view.textField?.stringValue = app.name
        view.button.setSelected(true, forSegment: app.setting ? 0 : 1)
        
        view.app = app
        view.controller = self
        
        return view;

    }
    
    func showRow(atIndex index: Int) {
        NSAnimationContext.runAnimationGroup({ context in
            context.allowsImplicitAnimation = true
            self.tableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
            self.tableView.scrollRowToVisible(index)
        }, completionHandler: nil)
    }
    
    func addApp(menuItem : ApplicationMenuItem) {
        
        preferenceModel.addApp(menuItem.app, alreadyExists: { index in
            self.showRow(atIndex: index)
        }, didAdd: { index in
            self.tableView.insertRowsAtIndexes(NSIndexSet(index: index), withAnimation: .EffectFade)
            self.showRow(atIndex: index)
        })
        
    }
    
    @IBAction func buttonClicked(sender: NSSegmentedControl) {
    
        if (sender.selectedSegment == 0) {
            // Add
            let event = NSApplication.sharedApplication().currentEvent!
            
            addMenu.removeAllItems()
            
            addMenu.addItemWithTitle(NSLocalizedString("Running Applications", comment: ""), action: "", keyEquivalent: "")
            
            preferenceModel.runningApps.forEach { app in
                addMenu.addItem(ApplicationMenuItem(forApp: app, action: "addApp:"))
            }
            
            NSMenu.popUpContextMenu(addMenu, withEvent: event, forView: sender)
            
        } else if (sender.selectedSegment == 1) {
            // Remove
            if let cell = selectedCell {
                let index = tableView.rowForView(cell)
                tableView.removeRowsAtIndexes(NSIndexSet(index: index), withAnimation: .EffectFade)
                
                preferenceModel.removeApp(atIndex: index)
                
                if (preferenceModel.apps.count > index) {
                    showRow(atIndex: index)
                } else {
                    showRow(atIndex: preferenceModel.apps.count - 1)
                }
                
            }
        }
        
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return preferenceModel.apps.count
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if (tableView.selectedRow == -1) {
            buttons.setEnabled(false, forSegment: 1) // Disable the remove button
        } else {
            buttons.setEnabled(true, forSegment: 1) // Enable the remove button
        }
    }

    
}
