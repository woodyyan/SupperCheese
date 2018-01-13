//
//  SearchEngine.swift
//  SuperCheese
//
//  Created by Songbai Yan on 12/01/2018.
//  Copyright © 2018 Songbai Yan. All rights reserved.
//

import Foundation

class SearchEngine {
    func search(elements:[String]){
        var sentences = elements
        if sentences.count > 3{
            let result1 = sentences.remove(at: sentences.count-1)
            let result2 = sentences.remove(at: sentences.count-1)
            let result3 = sentences.remove(at: sentences.count-1)
            let anwsers = [result1, result2, result3]
            let question = sentences.joined()
            search(question: question, answers: anwsers)
        }else{
            
        }
    }
    
    private func search(question:String, answers:[String]){
        if let url = getUrl(question: question){
            print("question: \(question)")
            let request = URLRequest(url: url)
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let realError = error{
                    print("ERROR:")
                    print(realError.localizedDescription)
                }else {
                    if let data = data {
                        if let result = String(data:data,encoding:.utf8){
                            self.calculateCount(html: result, answers: answers)
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    private func calculateCount(html:String, answers:[String]){
        var htmlString = html
        for answer in answers{
            var count = 0
            var range = htmlString.range(of: answer)
            while range != nil {
                count += 1
                htmlString.removeFirst(range!.upperBound.encodedOffset)
                range = htmlString.range(of: answer)
            }
            print("\(answer): \(count)")
        }
    }
    
    private func getUrl(question:String) -> URL?{
        let urlString = "https://www.bing.com/search"
        let queryItem = URLQueryItem(name: "q", value: question)
        let urlComponents = NSURLComponents(string: urlString)!
        urlComponents.queryItems = [queryItem]
        return urlComponents.url
    }
}
