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
    
    let recognizeEngine = RecognizeEngine()
    
    var captureController:CaptureWindowController? = nil
    
    var captureViewController:ViewController? = nil
    
    var captureSession:AVCaptureSession!
    var stillImageOutput:AVCaptureStillImageOutput!
    
    @IBOutlet weak var statusLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recognizeEngine.delegate = self
    }
    
    override func mouseDown(with event: NSEvent) {
        self.prepareCaptureWindow()
        self.captureScreen()
    }
    
    override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        
        prepareCaptureWindow()
        captureScreen()
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
                    self.recognizeEngine.recognizeImage(imageData: imageDataJpeg)
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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController : RecoginizeEngineDelegate{
    func recoginizeEngine(sentence: String) {
        openBaidu(sentence: sentence)
    }
    
    private func openBaidu(sentence:String){
        let urlString = "https://www.baidu.com/s"
        let queryItem = URLQueryItem(name: "wd", value: sentence)
        let queryItem1 = URLQueryItem(name: "ie", value: "utf-8")
        let urlComponents = NSURLComponents(string: urlString)!
        urlComponents.queryItems = [queryItem, queryItem1]
        if let regURL = urlComponents.url {
            print(regURL)
            let result = NSWorkspace.shared.open(regURL)
            print(result)
        }
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
    
    func hmacsha1(key: String) -> Data {
        
        let dataToDigest = self.data(using: String.Encoding.utf8)
        let keyData = key.data(using: String.Encoding.utf8)
        
        let digestLength = Int(CC_SHA1_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<Any>.allocate(capacity: digestLength)
        
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), (keyData! as NSData).bytes, keyData!.count, (dataToDigest! as NSData).bytes, dataToDigest!.count, result)
        
        return Data(bytes: UnsafePointer(result), count: digestLength)
    }
}

