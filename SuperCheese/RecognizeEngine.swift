//
//  RecognizeEngine.swift
//  SuperCheese
//
//  Created by Songbai Yan on 12/01/2018.
//  Copyright © 2018 Songbai Yan. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

class RecognizeEngine {
    var delegate:RecoginizeEngineDelegate?
    
    func recognizeImage(imageData:Data?){
        if let strBase64 = imageData?.base64EncodedString(options: .lineLength64Characters){
            
            print("START:")
            sendRequest(imageBase64String: strBase64)
        }
    }
    
    private func sendRequest(imageBase64String:String){
        let body = translate(data: imageBase64String)
        ApiClient_ocr.instance().recoganize(body) { (data, response, error) in
            
            if let realError = error{
                print("ERROR:")
                print(realError.localizedDescription)
            } else{
                let dataJson = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                print(dataJson)
                if let dict = dataJson as? [String: Any]{
                    if let rets = dict["ret"] as? NSArray{
                        var sentences = [String]()
                        for ret in rets{
                            //TODO:过滤开头的数字
                            let retDict = ret as! [String: Any]
                            let word = retDict["word"] as! String
                            sentences.append(word)
                            print(word)
                        }
                        self.delegate?.recoginizeEngine(sentences: sentences)
                    }
                }
            }
        }
    }
    
    private func sendRequestToAliyun(imageBase64String:String){
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
    
    private func signature() -> String{
        let path = "/api/predict/ocr_general"
        let url = path
        
        let stringToSign = "POST" + "\n" + "" + "\n" + "" + "\n" + "" + "\n" + "" + "\n" + "" + url
        
        let sign = stringToSign.hmacsha1(key: "79144b7457ea1be8a9d55fad60848bd7")
        let signString = sign.base64EncodedString()
        return signString
    }
    
    private func translate(data: String) -> Data {
        let dict = [
            "image": data,
            "configure": [
                "min_size" : 16,
                "output_prob" : true
            ]
            ] as [String : Any]
        
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }
}

protocol RecoginizeEngineDelegate {
    func recoginizeEngine(sentences:[String])
}
