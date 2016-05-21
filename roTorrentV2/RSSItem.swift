//
//  RSSItem.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

class RSSItem {
    var title: String
    var link: NSURL
    var pubDate: NSDate
    var desc: String?
    
    var hasBeenAdded = false
    
    init(title: String, link: NSURL, date: NSDate, description: String? = nil) {
        self.title = title
        self.link = link
        self.pubDate = date
        self.desc = description
    }
    
    func match(search: String) -> Bool {
        if !search.isEmpty {
            var searchAsRegex = search.stringByReplacingOccurrencesOfString(" ", withString: ".")
            searchAsRegex = searchAsRegex.stringByReplacingOccurrencesOfString("_", withString: ".")
            searchAsRegex = searchAsRegex.stringByReplacingOccurrencesOfString("-", withString: ".")
            let b = title.rangeOfString(searchAsRegex, options: [.RegularExpressionSearch, .CaseInsensitiveSearch])
            return (b != nil)
        } else {
            return true
        }
    }

}

func < (lhs: RSSItem, rhs: RSSItem) -> Bool {
    return lhs.pubDate.compare(rhs.pubDate) == .OrderedDescending
}
