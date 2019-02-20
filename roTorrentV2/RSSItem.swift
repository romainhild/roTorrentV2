//
//  RSSItem.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

class RSSItem: NSObject {
    var title: String
    var link: URL
    var pubDate: Date
    var desc: String?
    
    var hasBeenAdded = false
    
    init(title: String, link: URL, date: Date, description: String? = nil) {
        self.title = title
        self.link = link
        self.pubDate = date
        self.desc = description
        super.init()
    }
    
    func match(_ search: String) -> Bool {
        if !search.isEmpty {
            var searchAsRegex = search.replacingOccurrences(of: " ", with: ".")
            searchAsRegex = searchAsRegex.replacingOccurrences(of: "_", with: ".")
            searchAsRegex = searchAsRegex.replacingOccurrences(of: "-", with: ".")
            let b = title.range(of: searchAsRegex, options: [.regularExpression, .caseInsensitive])
            return (b != nil)
        } else {
            return true
        }
    }

}

func < (lhs: RSSItem, rhs: RSSItem) -> Bool {
    return lhs.pubDate.compare(rhs.pubDate) == .orderedDescending
}
