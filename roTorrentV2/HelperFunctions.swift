//
//  HelperFunctions.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

func documentsDirectory() -> NSString {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
}

func localFilePathForUrl(previewUrl: String) -> NSURL? {
    let documentsPath = documentsDirectory()
    if let url = NSURL(string: previewUrl), lastPathComponent = url.lastPathComponent {
        let fullPath = documentsPath.stringByAppendingPathComponent(lastPathComponent)
        return NSURL(fileURLWithPath:fullPath)
    }
    return nil
}

func prefPath() -> String {
    return (documentsDirectory() as NSString).stringByAppendingPathComponent("pref.plist")
}

