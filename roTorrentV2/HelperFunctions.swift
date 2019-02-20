//
//  HelperFunctions.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

func documentsDirectory() -> NSString {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
}

func localFilePathForUrl(_ previewUrl: String) -> URL? {
    let documentsPath = documentsDirectory()
    if let url = URL(string: previewUrl), let lastPathComponent = url.lastPathComponent {
        let fullPath = documentsPath.appendingPathComponent(lastPathComponent)
        return URL(fileURLWithPath:fullPath)
    }
    return nil
}

func prefPath() -> String {
    return (documentsDirectory() as NSString).appendingPathComponent("pref.plist")
}

