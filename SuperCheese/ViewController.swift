//
//  ViewController.swift
//  SuperCheese
//
//  Created by Songbai Yan on 08/01/2018.
//  Copyright © 2018 Songbai Yan. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
            self.keyDown(with: aEvent)
            return aEvent
        }
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
        print("aaa")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

