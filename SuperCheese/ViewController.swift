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
    
    var captureController:CaptureWindowController? = nil
    
    var captureViewController:ViewController? = nil
    
    var captureSession:AVCaptureSession!
    var stillImageOutput:AVCaptureStillImageOutput!

    override func viewDidLoad() {
        super.viewDidLoad()

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
            self.keyDown(with: aEvent)
            return aEvent
        }
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
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
                    self.recognizeImage(imageData: imageDataJpeg)
                    self.saveImage(imageData: imageDataJpeg)
                })
            }
        }
    }
    
    func recognizeImage(imageData:Data?){
        if let strBase64 = imageData?.base64EncodedString(options: .lineLength64Characters){
//            print("IMAGE DATA: \(strBase64)")
            
            print("START:")
            sendRequest(imageBase64String: strBase64)
        }
    }
    
    func sendRequest(imageBase64String:String){
        let body = translate(data: imageBase64String)
        ApiClient_ocr.instance().recoganize(body) { (data, response, error) in
            print("ERROR:")
            print(error ?? "")
            let dataJson = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            print(dataJson)
            let dict = dataJson as! [String: Any]
            let rets = dict["ret"] as! NSArray
            var sentence = ""
            for ret in rets{
                let retDict = ret as! [String: Any]
                let word = retDict["word"] as! String
                sentence += word
                print(word)
            }
            self.openBaidu(sentence: sentence)
        }
    }
    
    func openBaidu(sentence:String){
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
    
    func sendRequestToAliyun(imageBase64String:String){
        
        let url = URL(string: "https://tysbgpu.market.alicloudapi.com/api/predict/ocr_general")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = translate(data: imageBase64String)
        request.addValue("application/octet-stream; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("24762824", forHTTPHeaderField: "X-Ca-Key")
        request.addValue(signature(), forHTTPHeaderField: "X-Ca-Signature")
        
        let session = URLSession.shared
        print("Start task:")
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            print("ERROR:")
            print(error ?? "")
            print("RESPONSE:")
            print(response ?? "")
            print("DATA:")
            print(data ?? "")
            if let data = data {
                if let result = String(data:data,encoding:.utf8){
                    print(result)
                }
            }else {
                print(error!)
            }
        }
        dataTask.resume()
    }
    
    func signature() -> String{
        let path = "/api/predict/ocr_general"
        let url = path
        
        let stringToSign = "POST" + "\n" + "" + "\n" + "" + "\n" + "" + "\n" + "" + "\n" + "" + url
        
        let sign = stringToSign.hmacsha1(key: "79144b7457ea1be8a9d55fad60848bd7")
        let signString = sign.base64EncodedString()
        return signString
    }
    
    func translate(data: String) -> Data {
        let dict = [
            "image": data,
            "configure": [
                "min_size" : 16,
                "output_prob" : true
            ]
            ] as [String : Any]
        
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
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

