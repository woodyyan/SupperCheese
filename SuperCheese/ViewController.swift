//
//  ViewController.swift
//  SuperCheese
//
//  Created by Songbai Yan on 08/01/2018.
//  Copyright © 2018 Songbai Yan. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    let ocrEngine = OcrEngine()
    
    var captureController:CaptureWindowController? = nil
    
    var captureViewController:ViewController? = nil
    
    var captureSession:AVCaptureSession!
    var stillImageOutput:AVCaptureStillImageOutput!
    lazy var consoleViewController = (NSApplication.shared.delegate as? AppDelegate)?.consoleViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ocrEngine.delegate = self
    }
    
    override func mouseUp(with event: NSEvent) {
        consoleViewController?.statusLabel.stringValue = "开始搜索..."
        consoleViewController?.questionLabel.stringValue = ""
        consoleViewController?.answer1Label.stringValue = ""
        consoleViewController?.answer2Label.stringValue = ""
        consoleViewController?.answer3Label.stringValue = ""
        consoleViewController?.answer1Label.textColor = NSColor.black
        consoleViewController?.answer2Label.textColor = NSColor.black
        consoleViewController?.answer3Label.textColor = NSColor.black
        self.prepareCaptureWindow()
        self.captureScreen()
    }
    
    func prepareCaptureWindow(){
        if captureViewController == nil {
            let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let viewController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CaptureViewController")) as! ViewController
            captureViewController = viewController
        }
        
        if captureController == nil {
            let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let windowController = storyBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CaptureWindowController")) as! CaptureWindowController
            captureController = windowController
        }
        
        if let windowInfo = WindowInfoManager.topWindowInfo() {
            let frame = windowInfo.frame
            captureController?.window?.setFrame(frame, display: true, animate: true)
        }
    }
    
    func captureScreen(){
        stillImageOutput = AVCaptureStillImageOutput()
        
        let captureInput = AVCaptureScreenInput(displayID: currentDisplayID)
        captureSession = AVCaptureSession()
        
        if captureSession.canAddInput(captureInput) {
            captureSession.addInput(captureInput)
        }
        
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        // Start running the session
        captureSession.startRunning()

        if let frame = captureController?.window?.frame {
            
            let mainDisplayBounds = CGDisplayBounds(CGMainDisplayID())
            let quartzScreenFrame = CGDisplayBounds(currentDisplayID)
            let x = frame.origin.x - quartzScreenFrame.origin.x
            let y = frame.origin.y - (mainDisplayBounds.height - quartzScreenFrame.origin.y - quartzScreenFrame.height)
            
            // cropping
            let differencialValue = cropViewLineWidth
            let optimizeFrame = NSRect(
                x: x + differencialValue,
                y: y + differencialValue,
                width: frame.width - differencialValue * 2.0,
                height: frame.height - differencialValue * 2.0
            )
            
            captureInput.cropRect = optimizeFrame
            
            // start recording
            if let videoConnection = stillImageOutput.connection(with: AVMediaType.video){
                stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (imageBuffer, error) in
                    let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer!)
                    self.ocrEngine.recognize(imageData: imageDataJpeg)
                    //self.saveImage(imageData: imageDataJpeg)
                })
            }
        }
    }
    
    func saveImage(imageData:Data?){
        do {
            let path = "/Users/sbyan/Downloads/a.jpg"
            try imageData?.write(to: URL(fileURLWithPath: path))
        } catch let error {
            print(error)
        }
    }
}

extension ViewController : OcrEngineDelegate{
    func ocrEngine(sentences: [String]) {
        let searchEngine = SearchEngine()
        searchEngine.search(elements: sentences)
    }
}

extension ViewController {
    var currentDisplayID: CGDirectDisplayID {
        guard let screen = captureController?.window?.screen else {
            fatalError("Can not find screen info")
        }
        
        guard let displayID = screen.deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID else {
            fatalError("Can not find screen device description")
        }
        
        return displayID
    }
}

extension String {
    func urlencode() -> String {
        let stringToEncode = self.replacingOccurrences(of: " ", with: "+")
        return stringToEncode.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}

