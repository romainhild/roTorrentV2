//
//  RSSParser.swift
//  roTorrentV2
//
//  Created by Romain Hild on 20/05/2016.
//  Copyright © 2016 Romain Hild. All rights reserved.
//

import Foundation

class RSSParser: NSObject, NSXMLParserDelegate {
    
    let parser: NSXMLParser
    
    var rssItems = [RSSItem]()
    
    var isInItem = false
    var isTitle = false
    var isLink = false
    var isDate = false
    var isDesc = false
    var titleTmp: String?
    var linkTmp: NSURL?
    var dateTmp: NSDate?
    var descTmp: String?
    
    init?(contentsOfURL url: NSURL) {
        if let parser = NSXMLParser(contentsOfURL: url) {
            self.parser = parser
            super.init()
            parser.delegate = self
        } else {
            return nil
        }
    }
    
    func parse() -> Bool {
        return parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "item":
            isInItem = true
            titleTmp = nil
            linkTmp = nil
            dateTmp = nil
            descTmp = nil
        case "title":
            isTitle = isInItem
        case "link":
            isLink = isInItem
        case "pubDate":
            isDate = isInItem
        case "description":
            isDesc = isInItem
        default:
            break
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if isInItem {
            if isTitle {
                titleTmp = string
            } else if isLink {
                linkTmp =
                    NSURL(dataRepresentation: string.dataUsingEncoding(NSUTF8StringEncoding)!, relativeToURL: nil)
            } else if isDate {
                let dateFormatter = DateFormatterSingleton.sharedInstance
                dateTmp = dateFormatter.dateFromString(string)
            }else if isDesc {
                descTmp = string
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "item":
            isInItem = false
            if let t = titleTmp, let l = linkTmp, let d = dateTmp {
                rssItems.append(RSSItem(title: t, link: l, date: d, description: descTmp))
            }
        case "title":
            isTitle = false
        case "link":
            isLink = false
        case "pubDate":
            isDate = false
        case "description":
            isDesc = false
        default:
            break
        }
    }
}