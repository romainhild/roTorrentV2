//
//  RSSFeed.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

class RSSFeed: NSObject, NSCoding {
    var title: String
    var link: NSURL
    var lastUpdate: NSDate
    var items: [RSSItem]
    
    init?(title t: String, link l: NSURL) {
        title = t
        link = l
        lastUpdate = NSDate()
        items = [RSSItem]()
        
        super.init()
        
        if update() == nil { return nil }
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("title") as! String
        link = aDecoder.decodeObjectForKey("link") as! NSURL
        lastUpdate = aDecoder.decodeObjectForKey("lastUpdate") as! NSDate
        items = [RSSItem]()
        
        super.init()
        
        update()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(link, forKey: "link")
        aCoder.encodeObject(lastUpdate, forKey: "lastUpdate")
    }
    
    func update() -> Bool? {
        if let parser = RSSParser(contentsOfURL: link) {
            lastUpdate = NSDate()
            if parser.parse() {
                items = parser.rssItems
                return true
            } else {
                items = [RSSItem]()
                return false
            }
        } else {
            return nil
        }
    }
}