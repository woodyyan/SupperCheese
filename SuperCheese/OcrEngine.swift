//
//  OcrEngine.swift
//  SuperCheese
//
//  Created by Songbai Yan on 13/01/2018.
//  Copyright © 2018 Songbai Yan. All rights reserved.
//

import Foundation

class OcrEngine {
    var delegate:OcrEngineDelegate?
    
    func recognize(imageData:Data?){
        if let strBase64 = imageData?.base64EncodedString(options: .lineLength64Characters){
            
            print("START RECOGNIZE:")
            sendRequest(imageBase64String: strBase64)
        }
    }
    
    private func sendRequest(imageBase64String:String){
        AccessTokenService.getAccessToken { (token) in
            print("###########################################")
            print(imageBase64String)
            print(token)
            
            let url = self.getUrl(token: token)
            var request = URLRequest(url: url)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = self.translate(data: imageBase64String)
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let realError = error{
                    print(realError.localizedDescription)
                } else{
                    let dataJson = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    print(dataJson)
                    if let dict = dataJson as? [String: Any]{
                        if let number = dict["words_result_num"] as? String{
                            print(number)
                        }
//                        if let results = dict["words_result"] as String{
//                            print(number)
//                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    private func getUrl(token: String) -> URL{
        let urlString = "https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic"
        let queryItem = URLQueryItem(name: "access_token", value: token)
        let urlComponents = NSURLComponents(string: urlString)!
        urlComponents.queryItems = [queryItem]
        return urlComponents.url!
    }
    
    private func translate(data: String) -> Data {
        let body = "image=\(URLEncode(string: data))"
        return body.data(using: String.Encoding.utf8)!
    }
    
    func URLEncode(string: String) -> String {
        let generalDelimiters = ":#[]@ " // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimiters = "!$&'()*+,;="
        
        let allowedCharacters = generalDelimiters + subDelimiters
        let customAllowedSet =  NSCharacterSet(charactersIn:allowedCharacters).inverted
        let escapedString = string.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
        
        return escapedString
    }
}

protocol OcrEngineDelegate {
    func ocrEngine(sentences:[String])
}
