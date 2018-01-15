//
//  SearchEngine.swift
//  SuperCheese
//
//  Created by Songbai Yan on 12/01/2018.
//  Copyright © 2018 Songbai Yan. All rights reserved.
//

import Foundation
import Cocoa

class SearchEngine {
    lazy var consoleViewController = (NSApplication.shared.delegate as? AppDelegate)?.consoleViewController
    
    func search(elements:[String]) -> String{
        var sentences = elements
        var question = sentences.joined()
        if sentences.count > 3{
            let result1 = sentences.remove(at: sentences.count-1)
            let result2 = sentences.remove(at: sentences.count-1)
            let result3 = sentences.remove(at: sentences.count-1)
            let anwsers = [result1, result2, result3]
            question = sentences.joined()
            openBaidu(sentence: question)
            search(question: question, answers: anwsers)
        }else{
            
        }
        return question
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
        var count1 = 0
        var count2 = 0
        var count3 = 0
        for var answer in answers{
            answer = filterAnswer(answer: answer)
            var count = 0
            var range = htmlString.range(of: answer)
            while range != nil {
                count += 1
                htmlString.removeFirst(range!.upperBound.encodedOffset)
                range = htmlString.range(of: answer)
            }
            
            let result = "\(answer): \(count)"
            
            DispatchQueue.main.async {
                if self.consoleViewController?.answer1Label.stringValue == ""{
                    count1 = count
                    self.consoleViewController?.answer1Label.stringValue = result
                } else if self.consoleViewController?.answer2Label.stringValue == ""{
                    count2 = count
                    self.consoleViewController?.answer2Label.stringValue = result
                }else{
                    count3 = count
                    self.consoleViewController?.answer3Label.stringValue = result
                }
            }
            print(result)
        }
        DispatchQueue.main.async {
            if count1 == count2 && count2 == count3{
                
            } else{
                if count1 > count2{
                    if count1 > count3{
                        self.consoleViewController?.answer1Label.textColor = NSColor.red
                    }
                    else{
                        self.consoleViewController?.answer3Label.textColor = NSColor.red
                    }
                }else{
                    if count2 > count3{
                        self.consoleViewController?.answer2Label.textColor = NSColor.red
                    }else{
                        self.consoleViewController?.answer3Label.textColor = NSColor.red
                    }
                }
            }

            self.consoleViewController?.statusLabel.stringValue = "答案已出！"
        }
    }
    
    private func filterAnswer(answer:String) -> String{
        var filteredAnswer = answer
        if let range = filteredAnswer.range(of: "《"){
            filteredAnswer.removeSubrange(range)
        }
        if let range = filteredAnswer.range(of: "》"){
            filteredAnswer.removeSubrange(range)
        }
        return filteredAnswer
    }
    
    private func getUrl(question:String) -> URL?{
        let urlString = "https://www.bing.com/search"
        let queryItem = URLQueryItem(name: "q", value: question)
        let urlComponents = NSURLComponents(string: urlString)!
        urlComponents.queryItems = [queryItem]
        return urlComponents.url
    }
}
