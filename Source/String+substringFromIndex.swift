//
//  String+substringFromIndex.swift
//  YouTubeInMP3Client
//
//  Created by Miles Hollingsworth on 5/12/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import Foundation

extension String
{
    func substringFromIndex(index: Int) -> String
    {
        if (index < 0 || index > self.characters.count)
        {
            print("index \(index) out of bounds")
            return ""
        }
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }
}