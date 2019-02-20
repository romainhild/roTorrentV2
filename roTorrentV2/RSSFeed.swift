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
    var link: URL
    var lastUpdate: Date
    var items: [RSSItem]
    
    init?(title t: String, link l: URL) {
        title = t
        link = l
        lastUpdate = Date()
        items = [RSSItem]()
        
        super.init()
        
        if update() == nil { return nil }
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as! String
        link = aDecoder.decodeObject(forKey: "link") as! URL
        lastUpdate = aDecoder.decodeObject(forKey: "lastUpdate") as! Date
        items = [RSSItem]()
        
        super.init()
        
        update()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(link, forKey: "link")
        aCoder.encode(lastUpdate, forKey: "lastUpdate")
    }
    
    func update() -> Bool? {
        if let parser = RSSParser(contentsOfURL: link) {
            lastUpdate = Date()
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
