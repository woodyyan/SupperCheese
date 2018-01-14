//
//  AccessTokenService.swift
//  SuperCheese
//
//  Created by Songbai Yan on 14/01/2018.
//  Copyright © 2018 Songbai Yan. All rights reserved.
//

import Foundation

class AccessTokenService {
    class func getAccessToken(completionHandler: @escaping (String) -> Swift.Void){
        let url = getUrl()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let realError = error{
                print(realError.localizedDescription)
            } else{
                let dataJson = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                print(dataJson)
                if let dict = dataJson as? [String: Any]{
                    if let token = dict["access_token"] as? String{
                        completionHandler(token)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    private class func getUrl() -> URL{
        let urlString = "https://aip.baidubce.com/oauth/2.0/token"
        let queryItem = URLQueryItem(name: "grant_type", value: "client_credentials")
        let queryItem1 = URLQueryItem(name: "client_id", value: "20zD4wVRA87Xkf2BpjEol9Xs")
        let queryItem2 = URLQueryItem(name: "client_secret", value: "us8yEtaQrKLIBRmOcrQQQG0icKDTRST4")
        let urlComponents = NSURLComponents(string: urlString)!
        urlComponents.queryItems = [queryItem, queryItem1, queryItem2]
        return urlComponents.url!
    }
}
