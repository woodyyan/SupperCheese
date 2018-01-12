//
//  CaptureWindow.swift
//  ScreenRecord
//
//  Created by nakajijapan on 2016/02/19.
//  Copyright © 2016 nakajijapan. All rights reserved.
//
import Foundation
import Cocoa
import CoreGraphics
import IOKit

class CaptureWindow: NSWindow {
    
    override init(contentRect: NSRect, styleMask aStyle: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        isReleasedWhenClosed = true
        displaysWhenScreenProfileChanges = true
        backgroundColor = NSColor.clear
        isOpaque = false
        hasShadow = false
        collectionBehavior = [.fullScreenPrimary]
        
        isMovable = true
        isMovableByWindowBackground = true
        
        // hide title bar
        styleMask = [NSWindow.StyleMask.borderless, NSWindow.StyleMask.resizable]
        ignoresMouseEvents = false
        
        setFrame(NSRect(x: 200, y: 200, width: 500, height: 170), display: true)
    }
    
    override func performKeyEquivalent(with theEvent: NSEvent) -> Bool {
        return false
    }
}

