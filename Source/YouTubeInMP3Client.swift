//
//  YouTubeInMP3Client.swift
//  Master Caster
//
//  Created by Miles Hollingsworth on 5/11/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import UIKit
import Alamofire
import WebKit

struct YouTubeInMP3Response {
    let title: String
    let duration: NSTimeInterval
    let link: NSURL
}

typealias YouTubeMP3Completion = (String) -> ()

class YouTubeInMP3Client {
    static let sharedClient = YouTubeInMP3Client()
    
    private let messageHandler = WebKitMessageHandler()
    
    private var savedCompletion: YouTubeMP3Completion?
    
    private let conversionQueue = NSOperationQueue()
    
    private lazy var webView: WKWebView! = {
        let bundle = NSBundle(forClass: YouTubeInMP3Client.self)
        if let conversionStarterPath = bundle.pathForResource("ConversionStarter", ofType: "js") {
            do {
                let conversionStarterSource = try String(contentsOfFile: conversionStarterPath)
                
                let conversionStarterScript = WKUserScript(
                    source: conversionStarterSource,
                    injectionTime: .AtDocumentEnd,
                    forMainFrameOnly: true
                )
                
                let contentController = WKUserContentController()
                contentController.addUserScript(conversionStarterScript)
                //                contentController.addUserScript(remoteConsoleScript)
                contentController.addScriptMessageHandler(self.messageHandler,
                                                          name: "result")
                
                let config = WKWebViewConfiguration()
                config.userContentController = contentController
                
                let webView = WKWebView(frame: CGRectZero,
                                        configuration: config)
                
                return webView
            } catch {
                print("ConversionStarter.js doesn't exist")
            }
        }
        print("Failed to create webView")
        return nil
    }()
    
    func getMP3URL(videoID: String, completion: YouTubeMP3Completion) {
        Alamofire.request(.GET, "https://www.youtubeinmp3.com/fetch/?format=JSON&video=http://www.youtube.com/watch?v=\(videoID)").responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                if let link = JSON.objectForKey("link") as? String {
                    completion(link)
                }
                
            case .Failure(let error):
                let htmlString = String(response.data)
                let YouTubeInMP3URL = NSURL(string: "https://www.youtubeinmp3.com")
                self.webView.loadHTMLString(htmlString, baseURL: YouTubeInMP3URL)
//                self.startConversion(videoID, completion: completion)
            }
        }
    }
    
    private func startConversion(videoID: String, completion: YouTubeMP3Completion) {
        conversionQueue.addOperationWithBlock {
            self.savedCompletion = completion
            let conversionURLString = "http://www.youtubeinmp3.com/download/?video=https://www.youtube.com/watch?v=\(videoID)"
            if let conversionURL = NSURL(string: conversionURLString) {
                let request = NSURLRequest(URL: conversionURL)
                self.webView.loadRequest(request)
            }
        }
    }
    
    private func checkStatus(downloadURLString: String, completion: (Bool) -> ()) {
        Alamofire.request(.GET, "downloadURLString" + "&checkStatus=1").responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                if let isFinished = JSON.objectForKey("finished")?.boolValue {
                    completion(isFinished)
                } else {
                    print("Error parsing conversion status")
                }
                
            case .Failure(let error):
                print(error)
            }
        }
    }
}

private class WebKitMessageHandler: NSObject, WKScriptMessageHandler {
    @objc func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let downloadURLString = message.body as? String {
//            let repeatBlock = {

//            }
        }
    }
}
