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
import Fuzi

typealias YouTubeMP3Completion = (String) -> ()

private let baseURL = "https://www.youtubeinmp3.com"

class YouTubeInMP3Client {
    static let sharedClient = YouTubeInMP3Client()

    func getMP3URL(videoID: String, completion: YouTubeMP3Completion) {
        Alamofire.request(.GET, baseURL+"/fetch/?format=JSON&video=http://www.youtube.com/watch?v="+videoID).responseJSON { response in
            switch response.result {
            case .Success(let JSON):
                if let link = JSON.objectForKey("link") as? String {
                    completion(link)
                }
                
            case .Failure:
                self.scrapeDownloadURL(videoID, completion: completion)
            }
        }
    }
    
    internal func scrapeDownloadURL(videoID: String, completion: YouTubeMP3Completion) {
        self.getProvisionalDownloadURL(videoID, completion: { (conversionURL) in
            self.getFinalDownloadURL(conversionURL, completion: completion)
        })
    }
    
    internal func getProvisionalDownloadURL(videoID: String, completion: YouTubeMP3Completion) {
        Alamofire.request(.GET, baseURL+"/download/?video=https://www.youtube.com/watch?v="+videoID).response { (request, response, data, error) in
            let xml = try! XMLDocument(data: data!)
            if let conversionURL = xml.firstChild(css: "#download")?.attr("href") {
                completion(baseURL + conversionURL)
            }
        }
    }
    
    internal func getFinalDownloadURL(conversionURL: String, completion: YouTubeMP3Completion) {
        checkStatus(conversionURL) { isFinished in
            if isFinished {
                completion(conversionURL)
            } else {
                Alamofire.request(.GET, conversionURL).response { (request, response, data, error) in
                    let xml = try! XMLDocument(data: data!)
                    if let downloadURL = xml.firstChild(css: "#metaURL")?.attr("content")?.substringFromIndex(7) {
                        completion("https:" + downloadURL)
                    }
                }
            }
        }
    }
    
    internal func checkStatus(downloadURLString: String, completion: (Bool) -> ()) {
        Alamofire.request(.GET, downloadURLString+"&checkStatus=1").responseJSON { response in
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
