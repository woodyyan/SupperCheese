//
//  AppDelegate.swift
//  SuperCheese
//
//  Created by Songbai Yan on 08/01/2018.
//  Copyright © 2018 Songbai Yan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var consoleWindowController:ConsoleWindowController?
    var consoleViewController:ConsoleViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        showConsoleWindow()
    }
    
    func showConsoleWindow(){
        if consoleWindowController == nil{
            let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Console"), bundle: nil)
            let viewController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "consoleWindowController")) as! ConsoleWindowController
            consoleWindowController = viewController
            consoleWindowController?.showWindow(nil)
            consoleViewController = consoleWindowController?.contentViewController as? ConsoleViewController
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

