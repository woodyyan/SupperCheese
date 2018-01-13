//
//  ConsoleViewController.swift
//  SuperCheese
//
//  Created by Songbai Yan on 13/01/2018.
//  Copyright © 2018 Songbai Yan. All rights reserved.
//

import Cocoa

class ConsoleViewController: NSViewController {
    
    @IBOutlet weak var answer3Label: NSTextField!
    @IBOutlet weak var answer2Label: NSTextField!
    @IBOutlet weak var answer1Label: NSTextField!
    @IBOutlet weak var questionLabel: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        statusLabel.stringValue = "点击截图框开始搜索"
    }
    
}
