//
//  YouTubeInMP3ClientTests.swift
//  YouTubeInMP3ClientTests
//
//  Created by Miles Hollingsworth on 5/11/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import XCTest
@testable import YouTubeInMP3Client

class YouTubeInMP3ClientTests: XCTestCase {
    let client = YouTubeInMP3Client.sharedClient
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetMP3URLWithAPIExample() {
        let expectation = expectationWithDescription("Calling getMP3URL with API example ID")
        
        client.getMP3URL("i62Zjga8JOM") { (downloadURL) in
            print("Download URL: " + downloadURL)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { error in
            print(error)
        }
    }
    
    func testCheckStatusWithAPIExample() {
        let expectation = expectationWithDescription("Calling checkStatus with API example ID")
        
        client.getMP3URL("i62Zjga8JOM") { (downloadURL) in
            self.client.checkStatus(downloadURL, completion: { (finished) in
                expectation.fulfill()
                XCTAssertTrue(finished, "Example video hasn't finished conversion (???)")
            })
        }

        waitForExpectationsWithTimeout(10) { error in
            print(error)
        }
    }

    func testScrapeDownloadURWithAPIExampleL() {
        let expectation = expectationWithDescription("Calling scrapeDownloads with API example ID")
        
        client.scrapeDownloadURL("i62Zjga8JOM") { (downloadURL) in
            print(downloadURL)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60) { error in
            print(error)
        }
    }
}
